<cfcomponent name="test" extends="BaseHandler" output="false">
	<cfscript>
		function testSass(Event){
			var rc = event.getCollection();
			var sass = getModel("sass");
			var file = FileRead("C:\ColdFusion9\wwwroot\FormDaddyDev\includes\css\test.sass");
			
			writeOutput(sass.sass2css(file));
			
			$abort();
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