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
			'input[type="checkbox"]'
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
		
	function test_sass2css(){
	
	}
}