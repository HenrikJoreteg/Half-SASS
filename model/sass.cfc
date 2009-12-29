component {
	this.currentSelector = '';
	
	function sass2css(file){
		var result = '';
		var unclosed = 0;
		var indent = 0;
		var prev_indent = 0;
		var prev_selector = false;
		var curr_selector = '';
		var this_selector = '';
		
		while(NOT FileisEOF(arguments.file)){ 
			x = FileReadLine(arguments.file);
			
			// if it's validly indented
			if(isValidIndent(x)){
				indent = getIndent(x);
				indent = indent / 2;
			}
			if(len(trim(x))){
				// find selectors 
				if(isSelector(x)){
					// add open bracket and count it
					current_selector = trim(x);
					x = x & "{";
					unclosed = unclosed + 1;
					
					// if it's indented append it
					if(indent gt 0){
						current_selector = prev_selector & " " & trim(x);
						x = current_selector;
					}
					
					// set flag so we know previous row was selector
					prev_selector = current_selector;
				}
				else {
					x = x & ";";
				}
			}
			else{
				if(unclosed gt 0){
					x = x & "}";
					unclosed = unclosed - 1;
				}
			}
			
			// set previous indent value
			prev_indent = getIndent(x) / 2;
			
			// add newline character and append to result
			result = result & "#x##CHR(13)#";
		} 
		
		// close any remaining brackets
		while(unclosed GT 0){
			result = result & "}";
			unclosed = unclosed - 1;
		}
		
		return result;
	}
	
	function appendSelector(newSelector){
		if(len(this.currentSelector)){
			this.currentSelector = this.currentSelector & " " & arguments.newSelector;	
		}
		else {
			this.currentSelector = arguments.newSelector;
		}
		return this.currentSelector;
	}
	
	function isSelector(line){
		if(REFind("^([##\.a-zA-Z_-]|(& ?:)|(& ?>))[ ""'>=0-9a-zA-Z_\[\]\*\.\$\)\(-]+(?!:)([ 0-9a-zA-Z_-]+)?$", trim(arguments.line))){
			return true;
		}
		return false;
	}
	
	
	// test is indent value is allowed
	function isValidIndent(line){
		var count = getIndent(arguments.line);
		if(count EQ 0){
			return true;
		}
		if(count MOD 2 EQ 0){
			return true;
		}
		else {
			return false;
		}
	}
	
	// get indent of string
	function getIndent(string){
		var count = 0;
		for(i=1; i lte len(arguments.string); i++){
			if(mid(arguments.string, i, "1") EQ " "){
				count = count + 1;
			}
			else{
				break;
			}
		}
		return count;
	}
}
