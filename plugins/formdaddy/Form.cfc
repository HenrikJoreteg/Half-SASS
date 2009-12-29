<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2009 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano & Henrik Joreteg
Date        :	06/18/2009
Description :
	A FormDaddy Form object
----------------------------------------------------------------------->
<cfcomponent name="Form"
			 output="false"
			 hint="This object represents a FormDaddy form">
	
	<!----------------------------------------- CONSTRUCTOR ----------------------------------------->
	
	<cfscript>
		instance 			= structnew();
		instance.fieldPath 	= "field";
		instance.fields		= arrayNew(1);		
		instance.event		= "";
		instance.controller = "";
	</cfscript>
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="any" output="false" hint="Constructor">
		<cfargument name="name" 		type="any" required="true"  hint="Name of this form">
		<cfargument name="fields" 		type="any" required="false" hint="Fields for this form">
		<cfargument name="event" 		type="any" required="false" hint="The bounded request context">
		<cfargument name="controller"   type="any" required="true"  hint="The ColdBox controller"/>
		<cfscript>
			var i = 0;
			
			// Set ColdBox
			instance.controller = arguments.controller;
			
			// create field object array
			for(i=1;i lte arrayLen(arguments.fields);i=i+1){
				arrayAppend(instance.fields, createObject("component",instance.fieldPath).init(arguments.fields[i],instance.controller));
			}
			
			// is the form bound to data?
			if ( structKeyExists(arguments,"event") ){
				this.isBound = true;
				instance.event = arguments.event;
			}
			else {
				this.isBound = false;	
			}
			
			// method aliases
			this.$ = this.renderIt;
			this.$fields = this.getFields;
				
			return this;
		</cfscript>
	</cffunction>
	
	<!----------------------------------------- PUBLIC ----------------------------------------->
	
	<!--- renderIt --->
	<cffunction name="renderIt" access="public" returntype="any" output="false" hint="">
		<cfargument name="renderType" default="">
		<cfargument name="wrapIndividually" default="false">
		<cfargument name="outerWrapper" default="">
		<cfargument name="labelWrapper" default="">
		<cfargument name="fieldWrapper" default="">
		<cfscript>
			var form = "";
			var outerOpenTag = "";
			var outerCloseTag = "";
			var sep = chr(13);
			
			// set default render type if no arguments passed
			if (arguments.renderType EQ '' and 
				arguments.outerWrapper EQ '' and 
				arguments.labelWrapper EQ '' and 
				arguments.fieldWrapper EQ ''){
				
				arguments.renderType="as_list";
			}
			
			// set logical defaults based on renderType requested
			if (arguments.renderType NEQ ''){
				switch (arguments.renderType){
				case "as_list":
					if (arguments.wrapIndividually){
						arguments.outerWrapper = '';
						arguments.labelWrapper = 'li';
						arguments.fieldWrapper = 'li';
					}
					else {
						arguments.outerWrapper = 'li';
						labelWrapper = '';
						fieldWrapper = '';	
					}
					break;
				case "as_p":
					if (arguments.wrapIndividually){
						arguments.outerWrapper = '';
						arguments.labelWrapper = 'p';
						arguments.fieldWrapper = 'p';
					}
					else {
						arguments.outerWrapper = 'p';
						arguments.labelWrapper = '';
						arguments.fieldWrapper = '';
					}
					break;
				case "as_table":
					arguments.outerWrapper = 'tr';
					arguments.labelWrapper = 'th';
					arguments.fieldWrapper = 'td';
					// if they want to render as a table, this has to be true
					break;
				}
			}
			
				
			if (arguments.outerWrapper NEQ ''){
				outerOpenTag = '<#arguments.outerWrapper#>';
				outerCloseTag = '</#arguments.outerWrapper#>';
			}
					
			// we should have all our variables at this point, so we can render this stuff.
			// BTW Chr(13) is a new line character.
			for (i=1; i LTE arrayLen(instance.fields); i=i+1){
				form = "#form##outerOpenTag##sep#" & 
					   "#(instance.fields[i].$(fieldWrapper=arguments.fieldWrapper,labelWrapper=arguments.labelWrapper))##sep#" &
					   "#outerCloseTag##sep#";
			}
			
			
			return form;
		</cfscript>
	</cffunction>
	
	<!--- getFields --->
	<cffunction name="getFields" access="public" returntype="any" output="false" hint="">
		<cfscript>
			return instance.fields;
		</cfscript>
	</cffunction>
		
	<!----------------------------------------- PRIVATE ----------------------------------------->

	<!--- Get Controller --->
	<cffunction name="getcontroller" access="public" returntype="any" output="false" hint="Get the coldbox controller">
    	<cfreturn instance.controller>
    </cffunction>

	<!--- validate --->
	<cffunction name="validate" access="private" returntype="any" output="false" hint="">
		<cfargument name="event" hint="Coldbox Event">
		<cfscript>
			if (this.isBound){
				// loop through and call validate on each field
				for (i=1; i LTE arrayLen(instance.fields); i=i+1){
					instance.fields[i].validate();
				}
			}
			else {
				throw("Cannot Validate and Unbound Form",
					  "You can only validate a form that has been bound to a set of definitions",
					  "FormDaddy.CannotValidateUnboundFormException");
			}
		</cfscript>
	</cffunction>	
</cfcomponent>