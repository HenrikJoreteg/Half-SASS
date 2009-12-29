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
			var file = FileOpen("C:\ColdFusion9\wwwroot\FormDaddyDev\static\test.sass");
			
			writeOutput(sass.sass2css(file));
			
			$abort();
		}
		
	</cfscript>
</cfcomponent>