<cfoutput>
	
<p>As Table</p>
	<table>
#rc.form.$(renderType="as_table")#
	</table>
	
<p>Looping through fields</p>
<ul>
<cfloop index="i" from="1" to="#arrayLen(rc.fields)#">
	<li>
		#rc.fields[i].renderLabel()#
		#rc.fields[i].renderWidget()#
	</li>
</cfloop>
</ul>
   
	
<p>As P</p>
#rc.form.$(renderType="as_p")#

<p>As P individually wrapped</p>
#rc.form.$(renderType="as_p", wrapIndividually=true)#

<p>No render type, wrapped in b tags</p>
#rc.form.$(outerWrapper="b")#

<p>No render type, outer wrapper and label passed in wrapped in b tags</p>
#rc.form.$(outerWrapper="li", labelWrapper="em")#

<p>Just wrap labels with a p tag</p>
#rc.form.$(labelWrapper="p")#

<p>Just render default</p>
#rc.form.$()#
</cfoutput>