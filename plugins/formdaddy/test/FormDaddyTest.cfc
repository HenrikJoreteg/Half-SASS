<cfcomponent name="FormDaddy" 
			 extends="shared.api.beta94.test.resources.BaseTest">
<cfscript>
this.loadColdbox = false;
	
function setup(){
	mockController = getMockBox().createMock(classname="shared.frameworks.coldbox_2_60.coldbox.system.controller",clearMethods=true);	
	mockConfig = getMockBox().createMock(className="beta2007.beta94.plugins.formdaddy.FormConfig",clearMethods=true,callLogging=true);
	mockConfig.$(method="init",returns=mockConfig,preserveReturnType=false);
	
	daddy = getMockBox().createMock(className="beta2007.beta94.plugins.formdaddy.FormDaddy",callLogging=true);
	daddy.$("setPluginName");
	daddy.$("setPluginVersion");
	daddy.$("setPluginDescription");
}

function testInit(){
	//1: No Config Found
	try{
		daddy.$("settingExists",false);
		daddy.init(mockController);
		fail("This should have failed");	
	}
	catch("FormDaddy.ConfigSettingNotFoundException" e){
		debug(e.message & e.detail);
	}
	catch(Any e){
		debug(e);
		fail(e.message & e.detail);
	}
	
	//2: Config Found
	mockConfig.$("parse");
	daddy.$("settingExists",true);
	daddy.$("getSetting").$args("FormDaddy_ConfigFile").$results("/beta2007/beta94/plugins/formdaddy/test/Forms.cfm");
	daddy.$("createConfig",mockConfig);
	daddy.init(mockController);
	assertTrue(structKeyExists(mockConfig.$callLog(),"parse"));
}

function testOnMissingMethod(){
	/* Mock Return */
	daddy.$("giveMe",true);
	
	//1: No event
	daddy.onMissingMethod("LuisForm",structnew());
	assertEquals(daddy.$callLog().giveMe[1].name, "LuisForm");
	
	//2: With Event
	arg = structnew();
	arg["event"] = "MockEvent";
	daddy.onMissingMethod("EventForm",arg);
	assertEquals(daddy.$callLog().giveMe[2].name, "EventForm");
	assertEquals(daddy.$callLog().giveMe[2].event, "MockEvent");
}

function testCreateForm(){
	makePublic(daddy,"createForm");
	test = daddy.createForm("TestForm",arrayNew(1));
}
function testCreateConfigObject(){
	makePublic(daddy,"createConfig");
	test = daddy.createConfig();
}

function testGiveMe(){
	/* Mock Config */
	daddy.$("getFormConfig",mockConfig);
	
	//1: Pre-defined definition
		//a1: Form exists, unbounded
		mockConfig.$("formExists",true);
		mockConfig.$("getForm",arrayNew(1));
		daddy.$("createForm","MockForm");
		daddy.giveMe(name:'UserForm');
		//debug(daddy.$callLog().createForm);
		assertEquals(daddy.$callLog().createForm[1].name,"UserForm");
		//a2: Form exists, bounded
		daddy.giveMe(name:'UserForm',event:'EventContext');
		//debug(daddy.$callLog().createForm);
		assertEquals(daddy.$callLog().createForm[2].event,"EventContext");
		
		//b: Form not defined
		mockConfig.$("formExists",false);
		mockConfig.$("getFormsDefined","None");
		try{
			daddy.giveMe(name:'TestForm');
		}
		catch("FormDaddy.InvalidFormNameException" e){ 
			//pass 
		}
		catch(Any e){
			fail(e.message & e.detail);
		}
		
	//2: New Def
	def = structnew();
	def.name = "PioForm";
	def.fields = arrayNew(1);
	/* Mocks */
	daddy.$("checkDefinition");
	mockConfig.$("addDefinition");
	mockConfig.$("formExists",true);
	mockConfig.$("getForm",arrayNew(1));
	/* Try it */
	daddy.giveMe(definition=def);	
	assertEquals(mockConfig.$callLog().addDefinition[1][1],"PioForm");
}

function testCheckDefinition(){
	def = structnew();
	makePublic(daddy,"checkDefinition");
	try{
		daddy.checkDefinition(def);
	}
	catch("FormDaddy.InvalidDefinitionException" e){}
	catch(Any e){ fail(e.message & e.detail); }
	
	try{
		def.name = "LuisForm";
		daddy.checkDefinition(def);
	}
	catch("FormDaddy.InvalidDefinitionException" e){}
	catch(Any e){ fail(e.message & e.detail); }
	
	try{
		def.name = "LuisForm";
		def.fields = "array NOT!!";
		daddy.checkDefinition(def);
	}
	catch("FormDaddy.InvalidFieldsException" e){}
	catch(Any e){ fail(e.message & e.detail); }
	
	def.fields = arrayNew(1);
	daddy.checkDefinition(def);
}

</cfscript>
</cfcomponent>