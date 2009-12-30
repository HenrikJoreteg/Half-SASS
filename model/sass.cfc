component {
	this.currentSelector = '';
	
	function sass2css(file){
		var result = '';
		var line_result = '';
		var unclosed = 0;
		var indent = 0;
		var prev_indent = 0;
		var selector_array = arrayNew(1);
		var current_selector = '';
		var array_len = 0;
		var i = 0;
		var j = 0;
		var x = '';
		var diff = 0;
		
		while(NOT FileisEOF(arguments.file)){ 
			x = FileReadLine(arguments.file);
			
			// if it's validly indented
			if(isValidIndent(x)){
				position = getIndent(x);
				if(position EQ 0){
					position = 1;
				}
				else{
					position = (position / 2) + 1;
				}
			}
			else{
				// TODO: throw indentation error
				writeDump(var="it thinks there's an invalid indent", abort=true);
			}
			
			// make sure it's not blank
			if(len(trim(x))){
				// is it a selector? 
				if(isSelector(x)){
					current_selector = trim(x);
					
					// if the indent is zero clear the array and add the current selector
					if(position EQ 1){
						ArrayClear(selector_array);
						selector_array[position] = current_selector;
					}
					else {
						// set current_selector in array
						selector_array[position] = current_selector;
						
						if(arrayLen(selector_array) GT position){
							diff = arrayLen(selector_array) - position;
							// delete everything after current in array
							for(k=1;k lte diff;k=k+1){
								ArrayDeleteAt(selector_array, k + position);
							}
						}
					}
					
					// write out current selector
					for(j=1; j lte arrayLen(selector_array); j=j+1){
						if(left(selector_array[j],1) EQ '&'){
							line_result = line_result & RemoveChars(selector_array[j],1,1);
						}
						else{
							if(j EQ 1){
								line_result = selector_array[j];
							}
							else {
								line_result = line_result & " " & selector_array[j];
							}
						}
					}
					
					// tack on the opening bracket and spacing count it
					line_result = RepeatString(" ", (position-1)*2) & line_result & "{";
					unclosed = unclosed + 1;
				
				} // end selector
				else {
					// this is a css rule, append semi-colon
					line_result = x & ";";
				}
			}
			else{
				// this is a blank line, close up the unclosed brackets
				if(unclosed gt 0){
					line_result = "}";
					unclosed = unclosed - 1;
				}
			}
					
			// add newline character and append to result
			result = result & "#line_result##CHR(13)#";
		} 
		
		// there may be unclosed brackets at the very end, we need to close those up
		while(unclosed gt 0){
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
		var i = 1;
		var result = false;
		
		for(i = 1; i lte listLen(arguments.line, ','); i=i+1){
			if(REFind("^([##\.a-zA-Z_-]|(& ?:)|(& ?>))[ ""'>=0-9a-zA-Z_\[\]\*\.\$\)\(\-]+(?!:)([ 0-9a-zA-Z_-]+)?$", trim(listGetAt(arguments.line,i)))){
				result = true;
			}
			else{
				result = false;
				break;
			}
		}
		
		return result;
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
