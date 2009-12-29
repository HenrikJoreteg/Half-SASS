<cfcomponent name="FormDaddy" 
			 extends="shared.api.beta94.test.resources.BaseTest">
<cfscript>
this.loadColdbox = false;
	
function setup(){
	mockController = getMockBox().createMock(classname="shared.frameworks.coldbox_2_60.coldbox.system.controller",clearMethods=true);	
	json = createObject("component","shared.frameworks.coldbox_2_60.coldbox.system.plugins.json");
	mockController.$("getPlugin").$args("JSON").$results(json);
	
	config = getMockBox().createMock(className="beta2007.beta94.plugins.formdaddy.FormConfig",callLogging=true);
	config.init(mockController,'/beta2007/beta94/plugins/formdaddy/test/Forms.cfm');
}

function testInit(){
	debug(config.getForms());
}
function testGetFormsDefined(){
	assertTrue( len(config.getFormsDefined) );
}
function testAddDefinition(){
	config.addDefinition('mock',arrayNew(1));
	assertTrue( structKeyExists(config.getForms(),"mock") );
	
	config.$("parseJSON",arrayNew(1));
	config.addDefinition('mock','[{name:"firstname"]');
	assertEquals( config.$count('parseJSON'), 1);
}
function testFormExists(){
	assertFalse( config.formexists('none') );
	
	config.addDefinition('mock',arrayNew(1));
	assertTrue( config.formExists('mock') );
}
function testGetForm(){
	//exists
	config.addDefinition('mock',arrayNew(1));
	assertEquals( config.getForm('mock'), arrayNew(1) );
	
	//bad
	try{
		config.getForm('invalid');
	}
	catch("FormDaddy.FormConfig.FormNotFoundException" e){ }
	catch(any e){ fail(e.message & e.detail); }
}

function testParse(){
	
}
function testParseJSON(){
	makePublic(config,"parseJSON");
	//1: invalid JSON
	try{
		results = config.parseJSON("{invalid}+json");
		fail("this should have failed");
	}
	catch("FormDaddy.FormConfig.JSONException" e){}
	catch(any e){fail(e.message & e.detail);}
	
	//2: Not an array
	try{
		results = config.parseJSON("{mykey:'myvalue'}");
		fail("this should have failed");
	}
	catch("FormDaddy.FormConfig.InvalidJSONDefinitionException" e){}
	catch(any e){fail(e.message & e.detail);}
	
	//3: valid json, no udf
	def = arraynew(1);
	def[1]['name'] = 'first_name';
	results = config.parseJSON('[{name:"first_name"}]');
	assertEquals(results,def);
	
	//4:valid json, invalid UDF
	def[1]['validate'] = 'udf:invalid';
	try{
		results = config.parseJSON('[{name:"first_name",validate:"udf:invalid"}]');
		fail("should have failed");
	}
	catch("FormDaddy.FormConfig.UDFNotFoundException" e){}
	catch(any e){ fail("invalid exception");}
	
	//5:valid json, valid UDF
	def[1]['validate'] = variables.booleanCheck;
	config.booleanCheck = variables.booleanCheck;
	results = config.parseJSON('[{name:"first_name",validate:"udf:booleanCheck"}]');
	assertEquals(results,def);
}

function testvalidateFormDefinition(){
	makePublic(config,"validateFormDefinition");
	def = arrayNew(1);
	def[1] = "hello";
	
	// invalid struct
	try{
		config.validateFormDefinition("test",def);
		fail("invalid");
	}
	catch("FormConfig.InvalidFieldDefinition" e ){}
	catch(Any e){ fail(e.message & e.detail); }
	
	// name not found
	def[1] = structnew();
	try{
		config.validateFormDefinition("test",def);
		fail("invalid");
	}
	catch("FormConfig.InvalidFieldDefinition" e ){}
	catch(Any e){ fail(e.message & e.detail); }
	
	// invalid type
	def[1] = structnew();
	def[1].name = "name";
	def[1].type = "wahhh";
	try{
		config.validateFormDefinition("test",def);
		fail("invalid");
	}
	catch("FormConfig.InvalidFieldDefinition" e ){}
	catch(Any e){ fail(e.message & e.detail); }
	
	// invalid validations
	def[1] = structnew();
	def[1].name = "name";
	valids = "wahhh,sameAsX,minlen,exactlen-A,udf-,regex-,model-,model-cfc,ioc-,ioc-me-";
	for(x=1; x lte listlen(valids); x=x+1){
		def[1].validate = listGetAt(valids,x);
		try{
			test = config.validateFormDefinition("test",def);
			debug(test);
			fail("invalid #listGetAt(valids,x)#");			
		}
		catch("FormConfig.InvalidFieldDefinition" e ){ debug(e.detail); }
		catch(Any e){ fail(e.message & e.detail); }
	}
}
</cfscript>

<cffunction name="booleanCheck" access="private" returntype="boolean">
	<cfargument name="val" type="any" required="true"/>
	<cfreturn isBoolean(arguments.val)>
</cffunction>
</cfcomponent>