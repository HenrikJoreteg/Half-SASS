<cfcomponent>
<cfscript>
	instance = structNew();
	instance.definitions = structNew();
	instance.mixins = structNew();
	instance.delim = chr(13) & chr(10);
	
	function sass2css(file){
		var result = '';
		var line_result = '';
		var indent = 0;
		var prev_indent = 0;
		var selector_array = arrayNew(1);
		var partial_selector_array = arrayNew(1);
		var current_selector = '';
		var array_len = 0;
		var i = 0;
		var x = '';
		var var_name = '';
		var var_value = '';
		var j = 0;
		var ignore = false;
		var clean_file = '';
		var file_with_mixins = '';
		var previous_type = 0;
		var unclosed = false;
		var definitions_array = ArrayNew(1);
		var mixin_array = ArrayNew(1);
		
		// regular expressions
		var assignment_re = "(?m)^![0-9a-zA-Z_-]+ *= *[\S\t ]*";
		var mixin_re = "=[\S]*[#instance.delim#]+\n( +[\S\t ]+[#instance.delim#]+\n)*";
		
		// clean out comments (works for those on line by themselves or at end of line)
		clean_file = REReplace(file,"((?m)^\s*)?[ \t]*//[^#instance.delim#]*","","all");
		
		// grab definitions
		definitions_array = REMatch(assignment_re, clean_file);
		registerDefinitions(definitions_array);
		//dump(instance.definitions,1);
		
		// grab mixins
		mixins_array = REMatch(mixin_re, clean_file);
		registerMixIns(mixins_array);
		//dump(mixins_array,1);
		
		// clean out variable definitions and mixin definitions
		clean_file = REReplace(clean_file, assignment_re, "", "all");
		clean_file = REReplace(clean_file, mixin_re, "", "all");
		
		// insert mixins
		for(j=1;j lte listLen(clean_file,instance.delim);j=j+1){
			x = rtrim(listGetAt(clean_file,j,instance.delim));
			my_indent = getIndent(x);
			line_result = '';
			if(isMixin(x)){
				//dump(getMixinValue(getMixinName(x)),1);
				mixin_array = getMixinValue(getMixinName(x));
				
				// loop through lines of mixin and make sure they're indented properly
				for(x=1; x lte arrayLen(mixin_array); x=x+1){
					line_result = line_result & repeatString(" ", my_indent) & mixin_array[x] & instance.delim;
				}
				
				line_result = line_result;
			}
			else{
				line_result = x & instance.delim;
			}
			file_with_mixins = file_with_mixins & line_result;
		}
		
		//writeOutput(file_with_mixins);
		//abort();
		
		for(j=1;j lte listLen(file_with_mixins,instance.delim);j=j+1){
			x = rtrim(listGetAt(file_with_mixins,j,instance.delim));
			
			// these are our processing flags
			ignore = false;
			
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
				writeDump(var="It thinks there's an indentation error. Around line #j#", abort=true);
			}
			
			
			switch(whatIsIt(x)){
				case "selector":{
					// clear our working array
					ArrayClear(partial_selector_array);
					// loop through selectors in this line, in case there are multiple
					for(i=1; i lte listLen(x,','); i=i+1){
						current_selector = trim(listGetAt(x,i));
					
						// set the selector into the array
						selector_array = setSelectorInArray(selector_array, current_selector, position);
						
						// build selector string from array
						current_selector = buildSelectorString(selector_array);
						
						ArrayAppend(partial_selector_array, current_selector);
					}
					
					// tack on the opening bracket and spacing count it
					line_result = RepeatString(" ", (position-1)*2) & ArrayToList(partial_selector_array, ', ') & "{";
					
					if(unclosed){
						result = result & "}#instance.delim#";
						unclosed = false;
					}
					
					// set our unclosed flag
					unclosed = true;
					
					result = result & "#line_result##instance.delim#";
					break;
				}
				case "cssRule":{
					// look for variables... swap 'em out
					if(cssRuleContainsVar(x)){
						x = insertVariablesInRule(x);
					}
					// this is a css rule, append semi-colon
					result = result & "#x#;#instance.delim#";
					
					break;
				}
				case "blank":{
					break;
				}
			}
		} 
		
		// there will be an unclosed bracket at the very end, close it
		result = result & "}";
		
		/* remove all empty rules
		  this can happen if you nest selectors without any rules ie:
		  
		    span
		      a
		        background:blue
		*/
		result = REReplace(result,"#instance.delim#[^#instance.delim#]+{\s+}","","all");
		
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
	
	function cssRuleContainsVar(string){
		if(REFind("=( +)?!\S", arguments.string)){
			return true;
		}
		else{
			return false;
		}
	}
	
	function getDefinitionVarName(string){
		return removeChars(trim(listGetAt(arguments.string,1,"=")),1,1);
	}
	
	function getDefinitionVarValue(string){
		return stripQuotes(listGetAt(arguments.string,2,"="));
	}
	
	function getVarName(string){
		return removeChars(stripQuotes(listGetAt(arguments.string,2,"=")),1,1);
	}
	
	function getVarValue(string){
		if(structKeyExists(instance.definitions, arguments.string)){
			return instance.definitions[arguments.string];
		}
		else{
			// TODO: throw error
		}
	}
	
	function getMixinName(string){
		arguments.string = REReplace(arguments.string,"\([ \S\t]*\)","");
		return removeChars(trim(arguments.string),1,1);
	}
	
	function getMixinValue(string){
		if(structKeyExists(instance.mixins, arguments.string)){
			return instance.mixins[arguments.string];
		}
		else{
			// TODO: throw error
		}
	}
	
	function insertVariablesInRule(string){
		var left = listGetAt(arguments.string, 1, "=");
		var var_name = getVarName(arguments.string);
		
		return rtrim(left) & ": " & getVarValue(var_name);
	}
	
	function stripQuotes(string){
		var my_string = trim(arguments.string);
		var left = left(my_string,1);
		var right = right(my_string,1);
		var length = len(my_string);
		
		if((left EQ '"' and right EQ '"') or (left EQ "'" and right EQ "'")){
			return removeChars(removeChars(my_string,1,1),len(my_string)-1,1);
		}
		else{
			return my_string;
		}
	}
	
	function buildSelectorString(selector_array){
		var j = 1;
		var result = '';
		
		for(j=1; j lte arrayLen(arguments.selector_array); j=j+1){
			if(left(arguments.selector_array[j],1) EQ '&'){
				result = result & RemoveChars(arguments.selector_array[j],1,1);
			}
			else{
				if(j EQ 1){
					result = arguments.selector_array[j];
				}
				else {
					result = result & " " & arguments.selector_array[j];
				}
			}
		}
		
		return result;
	}
	
	function setSelectorInArray(selector_array, current_selector, position){
		var k = 1;
		var diff = 0;
		
		if(arguments.position EQ 1){
			ArrayClear(arguments.selector_array);
			arguments.selector_array[arguments.position] = arguments.current_selector;
		}
		else {
			// set current_selector in array
			arguments.selector_array[arguments.position] = arguments.current_selector;
			
			if(arrayLen(arguments.selector_array) GT position){
				diff = arrayLen(arguments.selector_array) - arguments.position;
				// delete everything after current in array
				for(k=1;k lte diff;k=k+1){
					ArrayDeleteAt(arguments.selector_array, k + arguments.position);
				}
			}
		}
		
		return arguments.selector_array;
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
		for(i=1; i lte len(arguments.string); i=i+1){
			if(mid(arguments.string, i, "1") EQ " "){
				count = count + 1;
			}
			else{
				break;
			}
		}
		return count;
	}
	
	// register mixins
	// this function receives an array of multi-line matches and registers mixins
	function registerMixIns(array){
		var x = 0;
		var i = 0;
		var name = 0;
		var reg_ex = "^\S+([ \S\t]+)?[#instance.delim#]\n";
		var working_array = arrayNew(1);
		var value = '';
		var has_args = false;
		
		// loop through array of matches and build mixins structure
		for(x=1; x lte arrayLen(arguments.array); x=x+1){
			name = REMatch(reg_ex,arguments.array[x]);
			name = trim(removeChars(name[1], 1,1));
			//if(REFind("",name)){
			value = REReplace(arguments.array[x], reg_ex, '');
			// trim extra blank lines if any
			value = rtrim(value);
			// clear working value
			ArrayClear(working_array);
				
			// loop through value and trim lines
			for(i=1; i lte listLen(value,instance.delim);i=i+1){
				arrayAppend(working_array, removeChars(listGetAt(value,i,instance.delim),1,2));
			}
			instance.mixins[name] = working_array;	
		}
		
	}
	
	// register definitions (variable assignments)
	function registerDefinitions(array){
		var x = 0;
		var name = 0;
		var value = 0;
		
		// loop through array of matches and build definitions structure
		for(x=1; x lte arrayLen(arguments.array); x=x+1){
			name = getDefinitionVarName(arguments.array[x]);
			value = getDefinitionVarValue(arguments.array[x]);
			instance.definitions[name] = value;	
		}
	}
	
	// tries to figure out what the line is
	function whatIsIt(line){
		if(isBlank(arguments.line)){
			return "blank";
		}
		if(isSelector(arguments.line)){
			return "selector";
		}
		if(isMixin(arguments.line)){
			return "mixin";
		}
		return "cssRule";
	}
	
	// blank test
	function isBlank(line){
		if(not len(trim(arguments.line))){
			return true;
		}
		return false;
	}
	
	// selector test
	function isSelector(line){
		var i = 1;
		var result = false;
		
		for(i = 1; i lte listLen(arguments.line, ','); i=i+1){
			if(REFind("^([##\.a-zA-Z_-]|(&:)|(&>)|(&\.)|(&##))([ ""'>=0-9a-zA-Z_\[\]\*\.\$\)\(\-]+)?(?!:)([ 0-9a-zA-Z_-]+)?$", trim(listGetAt(arguments.line,i)))){
				result = true;
			}
			else{
				result = false;
				break;
			}
		}
		
		return result;
	}
	
	// variable definition test
	function isAssignment(line){
		if(REFind("^![0-9a-zA-Z_-]+( +)?=( +)?\S", trim(arguments.line))){
			return true;
		}
		return false;
	}
	
	// mixin test
	function isMixin(line){
		if(REFind("^\+", trim(arguments.line))){
			return true;
		}
		return false;
	}
</cfscript>

<!---//////////////////////////////// Directory Functuions ////////////////////////////////////--->
<!--- processSASSFiles --->
<cffunction name="processSASSFiles" access="public" output="false">
	<cfargument name="directoryPath">
	<cfset var sassFiles = 0>
	<cfset var cssFiles = 0>
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var found = false>
	
	<cfdirectory action="list" directory="#arguments.directoryPath#" name="sassFiles" filter="*.sass">
	<cfdirectory action="list" directory="#arguments.directoryPath#" name="cssFiles" filter="*.css">
	<cfscript>
		for(i = 1; i lte sassFiles.recordcount; i = i + 1){
			
			if(cssFiles.recordcount){
				for(j = 1; j lte cssFiles.recordcount; j = j + 1){
					sassFileName = getFileName(sassFiles.name[i]);
					cssFileName = getFileName(cssFiles.name[j]);
					found = false;
					
					if(sassFileName EQ cssFileName){
						found = true;
						if(sassFiles.dateLastModified[i] GT cssFiles.dateLastModified[j]){
							processSassFile(sassFiles.name[i], arguments.directoryPath);
						}
						else{
							// stop inner loop because we've already found the file
							break;
						}
					}
					
					// if we reach the end and haven't found it... process the sass file
					if(j EQ cssFiles.recordcount and not found){
						processSassFile(sassFiles.name[i], arguments.directoryPath);
					}
				}
			}
			else {
				// there are no CSS files so process all SASS files
				processSassFile(sassFiles.name[i], arguments.directoryPath);
			}
		}
	</cfscript>
</cffunction>

<!--- getFileName --->
<cffunction name="getFileName" access="public" output="false">
	<cfargument name="string">
	<cfif right(arguments.string,5) EQ ".sass">
		<cfreturn removeChars(arguments.string, len(arguments.string)-4,5)>
	</cfif>
	<cfif right(arguments.string,4) EQ ".css">
		<cfreturn removeChars(arguments.string, len(arguments.string)-3,4)>
	</cfif>
</cffunction>

<!--- processSassFile --->
<cffunction name="processSassFile" access="public" returntype="any" output="false" hint="">
	<cfargument name="SASSFile">
	<cfargument name="directoryPath">
	<cfset var file = ''>
	<cfset var css = ''>
	
	<cffile action="read" file="#arguments.directoryPath#\#arguments.SASSFile#" variable="file">
	<cfset css = sass2css(file)>
	<cffile action="write" output="#css#" file="#arguments.directoryPath#\#getFileName(arguments.SASSFile)#.css">
</cffunction>

<!--- dump --->
<cffunction name="dump" access="public" returntype="any" output="false">
	<cfargument name="myvar">
	<cfargument name="abort" default="false">
	<cfdump var="#arguments.myvar#"><cfif arguments.abort><cfabort></cfif>
</cffunction>

<!--- abort --->
<cffunction name="abort" access="public" returntype="any" output="false">
	<cfabort>
</cffunction>
</cfcomponent>
