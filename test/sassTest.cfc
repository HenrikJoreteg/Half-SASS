component extends="coldbox.system.testing.BasePluginTest" {
	function setup(){
		// init my cfc
		sass = createObject("component","FormDaddyDev.model.sass");
		
		valid_selectors = [
			".heLLo-dude",
			"##hello-dude_this_rocks",
			"h1",
			"h3",
			"&:hover",
			"&> li  ",
			"h4",
			"div > ul",
			"##test-this_out",
			'div[class*="post"]',
			"div[class*='post']",
			'a[href$=".doc"]',
			"table.hl",
			".post",
			"&:lang(fr)",
			'input[type="checkbox"]',
			"    &:hover, &:active"
		];
		
		invalid_selectors = [
			"background-color: blue",
			"background:##ffffff url('img_tree.png') no-repeat top right"
		];
		
		
		valid_indents = [
			"test",
			"  test",
			"    test",
			"    my_test  "
		];
		
		invalid_indents = [
			" test",
			"   test",
			"   ",
			" 	",
			"   	"
		];
		
		valid_whitespace = [
			"   	",
			" ",
			"",
			"   ",
			"	"
		];
		
		invalid_whitespace = [
			"asdf",
			" a ",
			"	a"
		];
	}
	
	function test_getIndent(){
		a = arraynew(2);
		a[1] = [" test",1];
		a[2] = ["   test  ",3];
		a[3] = ["  test",2];
		a[4] = ["test  ",0];
		a[5] = ["",0];
		a[6] = ["	",0];
		a[7] = ["   	",3];
		
		for(i = 1; i LTE arrayLen(a); i++){
			debug("#a[i][1]# #a[i][2]#");
			
			assertEquals(sass.getIndent(a[i][1]),a[i][2]);		
		}
	}
	
	function test_isValidIndent(){
		var i = 0;
		
		for(i=1; i lte arrayLen(invalid_indents); i = i + 1){
			debug("""#invalid_indents[i]#"" #sass.getIndent(invalid_indents[i])# - #sass.isValidIndent(invalid_indents[i])#");
			assertFalse(sass.isValidIndent(invalid_indents[i]));
		}
		
		for(i=1; i lte arrayLen(valid_indents); i++){
			debug(valid_indents[i]);
			assertTrue(sass.isValidIndent(valid_indents[i]));
		}
	}
	
	
	
	function test_isSelector(){
		
		// test the valid ones
		for(i = 1; i LTE arrayLen(valid_selectors); i = i + 1){
			debug(valid_selectors[i]);
			assertTrue(sass.isSelector(valid_selectors[i]));		
		}
		
		// test the invalid ones
		for(i = 1; i LTE arrayLen(invalid_selectors); i = i + 1){
			debug(invalid_selectors[i]);
			assertFalse(sass.isSelector(invalid_selectors[i]));		
		}
		
	}
	
	function test_isAssignment(){
		var i = 1;
		var j = 1;
		var valid_vars = [
			"!_test = blah",
			"!test = 5",
			"!meeh=4"
		];
		
		var invalid_vars = [
			"test = blah",
			"  !test = ",
			"  !meeh: 4px"
		];
		
		// test the valid ones
		for(i = 1; i LTE arrayLen(valid_vars); i = i + 1){
			debug(valid_vars[i]);
			assertTrue(sass.isAssignment(valid_vars[i]));
		}
		
		// test the invalid ones
		for(j = 1; j LTE arrayLen(invalid_vars); j = j + 1){
			debug(invalid_vars[j]);
			assertFalse(sass.isAssignment(invalid_vars[j]));		
		}
	}
	
	function test_stripQuotes(){
		a = arraynew(2);
		a[1] = [" 'test' ","test"];
		a[2] = ['   "test"  ',"test"];
		a[3] = ["'test'","test"];
		a[4] = ['"test"',"test"];
		a[4] = ['te"st','te"st'];
		a[5] = ['test','test'];
		
		for(i = 1; i LTE arrayLen(a); i++){
			debug("#a[i][1]# #a[i][2]#");
			
			assertEquals(sass.stripQuotes(a[i][1]),a[i][2]);		
		}
	}
	
	function test_cssRuleContainsVar(){
		var i = 1;
		var j = 1;
		var valid_vars = [
			"font-size = !padding",
			"font-size=!padding",
			"font-size= !padding",
			"font-size =!padding"
		];
		
		var invalid_vars = [
			"text-align: right",
			"font-size: 26px",
			"text-align: right"
		];
		
		// test the valid ones
		for(i = 1; i LTE arrayLen(valid_vars); i = i + 1){
			debug(valid_vars[i]);
			assertTrue(sass.cssRuleContainsVar(valid_vars[i]));
		}
		
		// test the invalid ones
		for(j = 1; j LTE arrayLen(invalid_vars); j = j + 1){
			debug(invalid_vars[j]);
			assertFalse(sass.cssRuleContainsVar(invalid_vars[j]));		
		}
	}
		
	function test_sass2css(){
	
	}
}