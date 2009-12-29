<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	A FormDaddy Field object
----------------------------------------------------------------------->
<cfcomponent name="field" 
		     output="false"
			 hint="A FormDaddy field object">
	
	<!----------------------------------------- CONSTRUCTOR ----------------------------------------->
	
	<cfscript>
		instance = structNew();
		instance.value = "";
		instance.controller = "";
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor">
		<cfargument name="arg" 			type="any" required="true" hint="The field definition">
		<cfargument name="controller" 	type="any" required="true" hint="The ColdBox Controller"/>
		<cfscript>
			var key = "";
			
			instance.controller = arguments.controller;
			
			for(key in arguments.arg){
				if( structKeyExists(arguments.arg,key) ){
					instance[key] = arguments.arg[key];
				}
			}	
			
			// aliases
			this.$ = this.renderIt;
			this.$errors = this.renderErrors;
			this.$label = this.renderLabel;
			this.$widget = this.renderWidget;
			
			return this;
		</cfscript>
	</cffunction>
	
	<!----------------------------------------- PUBLIC ----------------------------------------->
	
	<!--- getProperty --->
    <cffunction name="getProperty" output="false" access="public" returntype="any" hint="Get a field property or blank if not found.">
    	<cfargument name="key" type="string" required="true" hint="The property key to retrieve"/>
		<cfscript>
    		if( structKeyExists(instance,arguments.key) ){
				return instance[arguments.key];
			}
			
			return "";
    	</cfscript>
    </cffunction>
	
	<!--- renderIt --->
	<cffunction name="renderIt" access="public" returntype="any" output="false" hint="">
		<cfargument name="fieldWrapper" default="">
		<cfargument name="labelWrapper" default="">
		<cfargument name="value" type="any" required="false" hint="The field value to bind"/>
		<cfscript>
			var labelOpenTag = '';
			var labelCloseTag = '';
			var fieldOpenTag = '';
			var fieldCloseTag = '';
			
			// Value binding
			if( structKeyExists(arguments,"value") ){
				instance.value = arguments.value;
			}
			
			if (arguments.labelWrapper NEQ ''){
				labelOpenTag = '<#arguments.labelWrapper#>';
				labelCloseTag = '</#arguments.labelWrapper#>';
			}
			
			if (arguments.fieldWrapper NEQ ''){
				fieldOpenTag = '<#arguments.fieldWrapper#>';
				fieldCloseTag = '</#arguments.fieldWrapper#>';
			}
			
			return "#labelOpenTag##renderLabel()##labelCloseTag##Chr(13)##fieldOpenTag##renderWidget()##fieldCloseTag#";
		</cfscript>
	</cffunction>
	
	<!--- renderLabel --->
	<cffunction name="renderLabel" access="public" returntype="any" output="false" hint="">
		<cfargument name="class" type="string" required="false" hint="A custom class if sent"/>
		<cfscript>
			var css = "";
			
			if( structKeyExists(arguments,"class") ){ css = ' class="#arguments.class#"'; }
			
			return '<label for="id_#instance.name#"#css#>#makePretty(instance.labelName)#</label>';
		</cfscript>
	</cffunction>
	
	<!--- renderWidget --->
	<cffunction name="renderWidget" access="public" returntype="any" output="false" hint="">
		<cfargument name="value" type="any" required="false" hint="The field value to bind"/>
		<cfscript>
			// Value binding
			if( structKeyExists(arguments,"value") ){
				instance.value = arguments.value;
			}
			
			switch(instance.type){
				// text input
				case "text": case "email": case "url" :
					return renderText();					
					break;
				// textArea input
				case "textArea":
					return renderTextArea();				
					break;
				// password input
				case "password":
					return renderPassword();
					break;
				// radio 
				case "radio":
					return renderRadio();
					break;
				// checkbox
				case "checkbox":
					return renderCheckbox();
					break;
			}
		</cfscript>
	</cffunction>

	<!--- renderErrors --->
	<cffunction name="renderErrors" access="public" returntype="any" output="false" hint="">
		<cfscript>
			return "#instance.errors#";
		</cfscript>
	</cffunction>
	
	<!--- validate --->
	<cffunction name="validate" access="public" returntype="any" output="false" hint="">
		<cfscript>
			//
		</cfscript>
	</cffunction>	
	<!----------------------------------------- PRIVATE ----------------------------------------->
	
	<!--- renderText --->
	<cffunction name="renderText" access="private" returntype="any" output="false" hint="">
		<cfscript>
			return '<input type="text" id="id_#instance.name#" name="#instance.name#" value="#instance.value#" />';	
		</cfscript>
	</cffunction>
	
	<!--- renderTextArea --->
	<cffunction name="renderTextArea" access="private" returntype="any" output="false" hint="">
		<cfscript>
			return '<textarea id="id_#instance.name#" name="#instance.name#">#instance.value#</textarea>';	
		</cfscript>
	</cffunction>
	
	<!--- renderPassword --->
	<cffunction name="renderPassword" access="private" returntype="any" output="false" hint="">
		<cfscript>
			return '<input type="password" id="id_#instance.name#" name="#instance.name#" value="#instance.value#" />';	
		</cfscript>
	</cffunction>
	
	<!--- renderCheckbox --->
	<cffunction name="renderCheckbox" access="private" returntype="any" output="false" hint="">
		<cfscript>
			var checked = "";
			if( isBoolean(instance.value) and instance.value ){ 
				checked='checked="checked"'; 
			}
			return '<input type="checkbox" id="id_#instance.name#" name="#instance.name#" value="true" #checked#/>';	
		</cfscript>
	</cffunction>
	
	<!--- renderRadio --->
	<cffunction name="renderRadio" access="private" returntype="any" output="false" hint="">
		<cfscript>
			return '<input type="radio" id="id_#instance.name#" name="#instance.name#" value="#instance.value#" />';	
		</cfscript>
	</cffunction>
	
	<!--- makePretty --->
	<cffunction name="makePretty" access="public" returntype="any" output="false" hint="">
		<cfargument name="text">
		<cfscript>
			if(structKeyExists(instance, "labelText")){
				return instance.labelText;					
			}
			else{
				return ucase(left(arguments.text, 1)) & removeChars(lcase(replace(arguments.text, "_"," ")),1,1);
			}
		</cfscript>
	</cffunction>
	
	<!--- Dump facade --->
	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
</cfcomponent>