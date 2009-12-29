<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	A FormDaddy configuration object.

Field Keys:
- *name
- id (defaults to name )
- type (defaults to text)
- class (defaults to empty)
- required (defaults to false)
- size (defaults to 0)
- validate (defaults to empty)
- xssClean (defaults to false)

*required 

Field Types:
- text
- password
- email (automatic validation to email)
- textarea
- date (automatic validation to date)
- url (automatic validation to url)
- radiobutton
- checkbox

Validations (Can be a list):
- boolean
- date
- email
- eurodate
- exactLen-X
- numeric
- guid
- integer
- maxLen-X
- minLen-X
- range-1..4
- regex-{regexhere}
- sameAs-{fieldname}
- ssn
- string
- telephone
- URL
- uuid
- USdate: a U.S. date of the format mm/dd/yy, with 1-2 digit days and months, 1-4 digit years. 
- zipcode 5 or 9 digit format zip codes

Dynamic/Custom Validations
- udf-{UDF Method} (The UDF must accept a string and the form object and return boolean)
  ex: public Boolean function(str,theForm){}
- model-{name}.{method} (The model object to use for validation. The method must accept a string and the form object and return boolean)
- ioc-{name}.{method} (The ioc object to use for validation. The method must accept a string and the form object and return boolean)

----------------------------------------------------------------------->
<cfcomponent name="FormConfig" 
			 output="false" 
			 hint="A FormDaddy configuration object"
			 extends="coldbox.system.frameworkSupertype">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		instance = structnew();
		// Constant Declarations
		instance.FIELD_TYPES = "text,password,email,textarea,date,url,radio,checkbox";
		instance.VALIDATION_TYPES = "boolean,date,email,eurodate,exactlen,numeric,guid,integer,maxlen,minlen,range,regex," &
									"sameas,ssn,string,telephone,url,uuid,usdate,zipcode,udf,model,ioc"; 
	</cfscript>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="FormConfig" hint="Constructor">
    	<cfargument name="controller" type="any" 	required="true" hint="ColdBox Application">
		<cfargument name="configPath" type="string" required="true" hint="The configuration file to include. This has to be an includable path"/>
    	<cfscript>
    		setController(arguments.controller);
			
			// Init form holder
			forms = structnew();
			
			 // Include & execute Config File
			try{
				$include(arguments.configPath);
			}
			catch(Any e){
				$throw("Error including FormDaddy config file: #e.message#",e.detail,"FormDaddy.ConfigFileException");
			}
			
    		return this;
    	</cfscript>
    </cffunction>

	<!--- parseConfig --->
    <cffunction name="parse" output="false" access="public" returntype="void" hint="Parse the configurations and get them ready.">
    	<cfscript>
    		var key = "";
			
			// Iterate via Forms for JSON formats, only done in < cf8
			for(key in forms){
				// Check if value is a string
				if( isSimplevalue(forms[key]) ){
					forms[key] = parseJSON(forms[key]);					
				}
				// Check if required fields are set.
				forms[key] = validateFormDefinition(key,forms[key]);
			}    	
    	</cfscript>
    </cffunction>
		
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<cffunction name="formExists" output="false" access="public" returntype="boolean" hint="Check if a form definition exists">
    	<cfargument name="name" type="string" required="true" hint="The name of the form definition"/>
    	<cfreturn structKeyExists(forms,arguments.name)>
    </cffunction>

	<cffunction name="getForm" access="public" returntype="array" output="false" hint="Get a form Definition by name. This is an array of field definitions">
		<cfargument name="name" type="string" required="true" hint="The name of the form definition to retrieve"/>
    	<cfif formExists(arguments.name)>
    		<cfreturn forms[arguments.name]>
		<cfelse>
			<cfthrow message="Form Definition not found"
					 detail="The form you requested #arguments.name# has not been defined. Valid form names are: #structKeyList(forms)#"
					 type="FormDaddy.FormConfig.FormNotFoundException">
		</cfif>
    </cffunction>
	
	<!--- addDefinition --->
    <cffunction name="addDefinition" output="false" access="public" returntype="void" hint="Add a new form definition. If the form already exists, this will override it.">
    	<cfargument name="name" 		type="string" required="true" hint="Name of the form"/>
		<cfargument name="definition" 	type="any" 	  required="true" hint="The array of fields defining this form or the JSON array definition for this form"/>
		<cfscript>
			var validDefinition = arguments.definition;
			
			// Parse And Defaults
			if( isSimpleValue(arguments.definition) ){
				validDefinition = parseJSON(arguments.definition);
			}
			// Validate Definition First
			validateFormDefinition(arguments.name,validDefinition);
			// Set it & Forget It
			forms[arguments.name] = validDefinition;
		</cfscript>
    </cffunction>
	
	<cffunction name="getFormsDefined" access="public" returntype="string" output="false" hint="Get a list of forms defined in this config object">
    	<cfreturn structKeyList(getForms())>
    </cffunction>
	
	<cffunction name="getForms" access="public" returntype="struct" output="false" hint="Get all the form definitions">
    	<cfreturn variables.forms>
    </cffunction>
    <cffunction name="setForms" access="public" returntype="void" output="false" hint="Override all of the form definitions">
    	<cfargument name="forms" type="struct" required="true">
    	<cfset variables.forms = arguments.forms>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- validateFormDefinition --->
    <cffunction name="validateFormDefinition" output="false" access="private" returntype="array" hint="Validates a form definition. Throws an exception if not valid">
   		<cfargument name="name" 		type="string" required="true" hint="Name of the form"/>
		<cfargument name="definition" 	type="any" 	  required="true" hint="The array of fields defining this form or the JSON array definition for this form"/>
		<cfscript>
   			var x=1;
   			var fields = arguments.definition;
			var fieldsLen = arrayLen(arguments.definition);
			var thisField = "";
			var validTypes = replace(instance.FIELD_TYPES,",","|","all");
			var validValidationTypes = replace(instance.VALIDATION_TYPES,",","|","all");
			var invalidValidation = false;
			var validationREGEX = "^(exactlen-[0-9]+|maxlen-[0-9]+|minlen-[0-9]+|sameas-.+|range-[0-9]+\.\.[0-9]+|regex-.+|udf-.+|(model|ioc)-[^-\.]+\.[^.]+)$";
			var dynamicValidators = "exactlen,maxlen,minlen,sameas,range,regex,udf,model,ioc";
			var y=1;
			var thisValidate = "";
			
			for( x=1; x lte fieldsLen; x=x+1 ){
				thisField = fields[x];
				invalidValidation = false;
				
				// Check if structure
				if( NOT isStruct(thisField) ){
					throw("Invalid Field Type on form #arguments.name#","The field definition must be a structure.","FormConfig.InvalidFieldDefinition");
				}
				
				// Check required keys
				if( NOT structKeyExists(thisField,"name") ){
					throw("Required Field Missing. Form #arguments.name#","The name key is missing in the field definition","FormConfig.InvalidFieldDefinition");
				}
				
				// Set the Field Defaults
				if( NOT structKeyExists(thisField,"id" ) ) { thisField.id = thisField.name; }
				if( NOT structKeyExists(thisField,"class" ) ) { thisField.class = ""; }
				if( NOT structKeyExists(thisField,"required" ) ) { thisField.required = false; }
				if( NOT structKeyExists(thisField,"size" ) ) { thisField.size = 0; }
				if( NOT structKeyExists(thisField,"xssClean" ) ) { thisField.xssClean = false; }
				if( NOT structKeyExists(thisField,"labelName" ) ) { thisField.labelName = thisField.name; }
				
				// Default Field Type Checks
				if( NOT structKeyExists(thisField,"type") ){
					thisField.type = "text";
				}
				else if( NOT reFindNoCase("^(#validTypes#)$",thisField.type) ){
					throw("Invalid Field Type. Form #arguments.name#","The type #thisField.type# is invalid. Valid types are #instance.FIELD_TYPES#","FormConfig.InvalidFieldDefinition");
				}
				
				// Check Validation Field
				if( NOT structKeyExists(thisField,"validate") ){
					// Do default validations for certain field types
					if( thisField.type eq "email" ){ thisField.validate = "email"; }
					else if( thisField.type eq "url" ){ thisField.validate = "url"; }
					else if( thisField.type eq "date" ){ thisField.validate = "date"; }
					else { thisField.validate = ""; }
				}
				// Validate if the validation is valid or not?
				else{
					for(y=1; y lte listLen(thisField.validate); y=y+1){
						thisValidate = listGetAt(thisField.validate,y);
						// super regex Check
						if( NOT reFindNoCase("^(#validValidationTypes#)$",trim(listFirst(thisValidate,"-"))) ){ 
							 throw("Invalid validation type. Form #arguments.name#","The validation #listFirst(thisValidate,"-")# is invalid. Valid types are #instance.VALIDATION_TYPES#","FormConfig.InvalidFieldDefinition");
						}
						// test dynamic regexs
						if( listFindNoCase(dynamicValidators,listFirst(thisValidate,"-")) AND NOT reFindNoCase(validationREGEX,thisValidate) ){ 
							throw("Invalid dynamic validation type. Form #arguments.name#","The dynamic validation #thisValidate# is invalid. Valid types are #instance.VALIDATION_TYPES#","FormConfig.InvalidFieldDefinition");
						}
					}
				}				
			}			 	
			
			return fields;
   		</cfscript>
    </cffunction>
	
	<!--- parseJSON --->
    <cffunction name="parseJSON" output="false" access="private" returntype="array" hint="Parse json form definitions">
    	<cfargument name="definition" type="string" required="true" hint="The form definition structure in JSON"/>
		<cfscript>
			/* Prepare TargetJSON */
			var targetJSON = trim(arguments.definition);
			var json = controller.getPlugin("JSON");
			var x=1;
			var field = "";
			var udfName = "";
			var def = "";
			
			/* Inflate JSON to Array Definition First*/
			try{
				def = json.decode(targetJSON);
			}
			catch(Any e){
				throw("Error inflating JSON form definition. Please check your definition.",
					   e.message & ' ' & e.detail,
					   "FormDaddy.FormConfig.JSONException");
			}
			/* Validate it is an Array */
			if( NOT isArray(def) ){
				throw("Definition is not an array",
					  "The decoded JSON was not a valid CF array, please check your definitions again: JSON = #targetJSON#",
					  "FormDaddy.FormConfig.InvalidJSONDefinitionException");
			}
			
			/* Loop through fields and try to find UDF declarations to inflate */
			for(x=1; x lte arrayLen(def); x=x+1){
				field = def[x];
				
				/* Discover a Validate UDF to set */
				if( structKeyExists(field,"validate") AND findNoCase("udf:",field.validate) ){
					/* Get UDF */
					udfName = listLast(field.validate,":");
					/* Verify UDF on public scope */
					if( structKeyExists(this,udfName) ){
						def[x].validate = this[udfName];
					}
					else{
						throw("UDF #udfName# could not be located in template.",
						       "Please check your name or that the access scope is public",
							   "FormDaddy.FormConfig.UDFNotFoundException");
					}
				}
			}
			
			return def;
		</cfscript>
    </cffunction>

</cfcomponent>