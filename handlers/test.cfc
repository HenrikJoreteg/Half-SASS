<cfcomponent name="test" extends="BaseHandler" output="false">
	<cfscript>
		function testForm(Event){
			var rc = event.getCollection();
			var fd = getMyPlugin("formdaddy.FormDaddy");
			
			
			rc.form = fd.giveMe("User");
			
			rc.fields = rc.form.getFields();
		}
		
		
		function testSass(Event){
			var rc = event.getCollection();
			var sass = getModel("sass");
			var file = FileRead("C:\ColdFusion9\wwwroot\FormDaddyDev\includes\css\test.sass");
			
			writeOutput(sass.sass2css(file));
			
			$abort();
		}
		
		function testCF7Style(event){
			var sass = getModel("sass");
			var file = FileRead("C:\ColdFusion9\wwwroot\FormDaddyDev\includes\css\test.sass");
			var delim = "#chr(10)##chr(13)#";
			
			for(i=1;i lte listLen(file,delim);i=i+1){
				writeOutput(listGetAt(file,i,delim));
			}
			$abort();
			
			writeOutput(sass.sass2css(file));
		}
		
		function testSassOnDirectory(Event){
			var rc = event.getCollection();
			var sass = getModel("sass");
			var directory = "C:/ColdFusion9/wwwroot/FormDaddyDev/includes/css";
			
			writeOutput(sass.processSASSFiles(directory) & "blah");
			
			$abort();
		}
		
	</cfscript>
</cfcomponent>