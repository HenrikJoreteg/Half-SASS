<cfscript>
/* 
Field Keys:
- *name
- id (defaults to name )
- type (defaults to text)
- class (defaults to empty)
- required (defaults to false)
- size (defaults to 0)
- validate (defaults to empty)
- xssClean (defaults to false)

* required

Field Types:
- text
- password
- email (automatic validation to email)
- textarea
- date (automatic validation to date)
- url (automatic validation to url)
- radiobutton
- checkbox

Validations (Can be a list):
- boolean
- date
- email
- eurodate
- exactLen-X
- numeric or float
- guid
- integer
- maxLen-X
- minLen-X
- range-1..4
- regex-{regexhere}
- sameAs-{fieldname}
- ssn
- string
- telephone
- URL
- uuid
- USdate: a U.S. date of the format mm/dd/yy, with 1-2 digit days and months, 1-4 digit years. 
- zipcode 5 or 9 digit format zip codes

Dynamic/Custom Validations
- udf-{UDF Method} (The UDF must accept a string and the form object and return boolean)
  ex: public Boolean function(str,theForm){}
- model-{name}.{method} (The model object to use for validation. The method must accept a string and the form object and return boolean)
- ioc-{name}.{method} (The ioc object to use for validation. The method must accept a string and the form object and return boolean)
*/

function booleanCheck(val,theForm){
	return isBoolean(val);
}

/* CF8 

forms["User"] = [
	{name='first_name', type='text', validate='maxLen:15'},
	{name='last_name', type='text', validate='maxLen:15'},
	{name='email_address', type='email'},
	{name='password', type='password', validate='minLen-6,string'},
	{name='test',type="text",validate=booleanCheck}
];
*/

/* JSON FOR ALL CF'S */
forms["User"] = '[
	{name:"first_name",type:"text",validate:"maxlen-15"},
	{name:"last_name",type:"text", validate:"maxlen-15"},
	{name:"email_address", type:"email"},
	{name:"password", type:"password", validate:"minlen-6,string"},
	{name:"test", type:"text", validate:"udf-booleanCheck"}
]';
	
</cfscript>