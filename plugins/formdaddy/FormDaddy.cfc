<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	The granddaddy of all form builders, validators and more.
----------------------------------------------------------------------->
<cfcomponent name="FormDaddy" 
			 extends="coldbox.system.plugin" 
			 output="false" 
			 hint="Our incredible Form Builder, Validator and overall Form Daddy!!"
			 cache="true"
			 cacheTimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfargument name="controller" type="any" required="true" hint="The coldbox daddy"/>
		<cfscript>
			super.init(argumentCollection=arguments);
			
			// Plugin Properties
			setPluginName("FormDaddy");
			setPluginVersion("1.0");
			setPluginDescription("Build, Model, Validate and Do it all with your Form Daddy");
			//setPluginAuthor("Luis Majano & Henrik Joreteg");
			//setPluginAuthorURL("http://coldbox.org,http://joreteg.com/");
			
			// Check config Path
			if( NOT settingExists("FormDaddy_ConfigFile") ){
				throw("Form Daddy Config File Setting Not Defined",
					   "The setting 'FormDaddy_ConfigFile' needs to be defined in your configuration file.
					   It must point to the configuration template you would like to load",
					   "FormDaddy.ConfigSettingNotFoundException");
			}
			instance.configPath = getSetting("FormDaddy_ConfigFile");
			
			// Create Config object
			instance.formConfig = createConfig().init(controller,instance.configPath);
			
			// Parse And Validate Configuration Definitions
			instance.formConfig.parse();
			
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- giveMe --->
    <cffunction name="giveMe" output="false" access="public" returntype="any" hint="Give me a bound, unbounded Form.  Forms are bound by passing in the event context object to them.">
    	<cfargument name="name" 		type="string" 	required="false" default="" hint="The name of the form to retrieve from the pre-defined form definitions. MUTEX with definition argument."/>
		<cfargument name="definition" 	type="struct" 	required="false" hint="A form definition if it has not been defined yet. Must have two keys: [name: name of the form][fields:array of fields structures]. Please see documentation in order to define a field structure."/>
		<cfargument name="event" 		type="any" 		required="false" hint="The coldbox request context. By passing it, you are binding and validating the form to this request context. coldbox.system.beans.RequestContext"/>
    	<cfscript>
    		var config = getFormConfig();
			var args = structnew();
			var oForm = "";
			
			/* Definition Checks */
			if ( structKeyExists(arguments,"definition") ){
				/* Definition Checks */
				checkDefinition(arguments.definition);
				/* Store Definition */
				config.addDefinition(arguments.definition.name,arguments.definition.fields);
				/* Bypass it */
				arguments.name = arguments.definition.name;
			}
    		
			/* Check if Form Definition Exists, else throw */
			if(config.formExists(arguments.name) ){
				/* Prepare Args */
				args.name = arguments.name;
				args.fields = config.getForm(arguments.name);
				args.controller = controller;
				if( structKeyExists(arguments,"event") ){ args.event = arguments.event; }
				/* Create Form */
				oForm = createForm(argumentCollection=args);
			}
			else{
				throw("Form #arguments.name# not defined",
					   "The form you requested was not found in the configuration. Available forms are: #config.getFormsDefined()#",
					   "FormDaddy.InvalidFormNameException");
			}			
			
			return oForm;
		</cfscript>
    </cffunction>
	
	<cffunction name="getFormConfig" access="public" returntype="any" output="false" hint="Get the forms configuration object">
    	<cfreturn instance.formConfig>
    </cffunction>
	
	<cffunction name="getConfigPath" access="public" returntype="string" output="false" hint="Get the config path used">
    	<cfreturn instance.configPath>
    </cffunction>
	
	<!--- onMissingMethod --->
    <cffunction name="onMissingMethod" output="true" access="public" returntype="any" hint="Handles Form Retrievals of pre-defined forms only">
    	<cfargument name="missingMethodName" 		type="string" required="true" hint="The form name requested"/>
    	<cfargument name="missingMethodArguments" 	type="struct" required="true" hint="The arguments"/>
    	<cfscript>
    		var args = structnew();
    		args.name = arguments.missingMethodName;
			
			// check event
			if( structKeyExists(arguments.missingMethodArguments,'1') ){
				args.event = arguments.missingMethodArguments[1];
			}
			else if( structKeyExists(arguments.missingMethodArguments,"event") ){
				args.event = arguments.missingMethodArguments["event"];
			}
			
			return giveMe(argumentCollection=args);
		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- checkDefinition --->
    <cffunction name="checkDefinition" output="false" access="private" returntype="void" hint="Validate a definition structure">
    	<cfargument name="definition" 	type="struct" 	required="false" hint="A form definition if it has not been defined yet. Must have two keys: [name: name of the form][fields:array of fields]"/>
		<cfscript>
    		if( NOT structKeyExists(arguments.definition,"name") ){
				throw("Invalid Form Definition",
					  "The definition structure needs a key called 'name' with the name of the form to represent",
					  "FormDaddy.InvalidDefinitionException");
			}
			if( NOT structKeyExists(arguments.definition,"fields") ){
				throw("Invalid Form Definition",
					  "The definition structure needs a key called 'fields' that has an array of structures defining the form fields",
					  "FormDaddy.InvalidDefinitionException");
			}
			if( structKeyExists(arguments.definition,"fields") AND
			    NOT isArray(arguments.definition.fields) ){
				throw("Invalid Fields Definition",
					  "The fields key MUST be an array of structures",
					  "FormDaddy.InvalidFieldsException");
			}    	
    	</cfscript>
    </cffunction>
	
	<!--- getConfigObject --->
    <cffunction name="createConfig" output="false" access="private" returntype="any" hint="Create a config object">
    	<cfreturn createObject("component","FormConfig")>
    </cffunction>

	<!--- getFormObject --->
    <cffunction name="createForm" output="false" access="private" returntype="any" hint="Create a new form object">
    	<cfargument name="name" 		type="string" 	required="true"  	hint="Name of the form to create"/>
    	<cfargument name="fields" 		type="array" 	required="true"  	hint="The fields' definition array"/>
		<cfargument name="event" 		type="any"	 	required="false" 	hint="The request context object to bind, if sent. coldbox.system.beans.RequestContext"/>
    	<cfargument name="controller" 	type="any" 		required="true" 	hint="The coldbox daddy"/>
		<cfreturn createObject("component","Form").init(argumentCollection=arguments)>
    </cffunction>
	
</cfcomponent>