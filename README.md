#HALF-SASS

This project is in no way affiliated with the original SASS project. I'm just a huge fan of using SASS for my non CF projects and wanted to have similar funcationality when workin in CF. Much props to the brilliant people who created SASS. In my humble opinion it is what CSS should have been and I wish that browsers would support it natively.
In it's current state this is only a partial implementation of [Syntactically Awesome Style Sheets (SASS)](http://sass-lang.com/), but it's written entirely in CFML.
For those unfamiliar with SASS it's an abstraction layer for CSS. CSS is insanely repetitive. So SASS makes it DRY.

Since I'm no longer working in a CF job, this project is no longer actively maintained by the author: Henrik Joreteg. If you're interested in continuing development just fork this project and go at it.

This repo is bundled as a ColdBox application, but all the logic is in "model/sass.cfc" and you could easily use it in any CF project. Just see the usage below.

##Usage
The easiest way to use this is to call processSASSFiles("absolute/path/to/sass/directory"). This function will do a CF directory and if the SASS file has been edited more recently than the corresponding css file it will process the sass file again and write a *.css file of the same name. For example, "test.sass" becomes "test.css" and gets written into the same folder. 

In your layouts you can just reference the css file because they will be dynamically generated if need be.

If you're building a coldbox app, I would suggest bundling this as an interceptor that is only active in your development server (no need for wasting processing in production).

If you don't want to use processSASSFiles(), all the processing happens in the sass2css() function of the SASS object. This function expects a sass file as a string. Most of the time this will be handled with a FileRead("/path/to/file.sass").

The sass2css function will return the css as a string, you can write it to file or whatever.

For example:

    !my_var = 118px 		// declaring a variable

    =my_mixin 			    // this is a mixin, you can think of it like a snippet 
      height = !my_var 		// mixins can contain varibles as well
      background-color: blue
      border: 1px solid black

    h1
      height = !my_var 		// here i'm using a varible
      margin-top: 1em

    .tagline
      +my_mixin 			// this is how you use a mixin
      font-size: 26px
      text-align: right

      span				// notice that this is nested, by nesting, it will prepend parent selectors with a space
        background-color: grey
	
      &:hover			// if you nest a declaration with an ampersand it will prepend parents without a space 	
        background-color: purple

becomes:

    h1{
      height: 118px;
      margin-top: 1em;
    }
    .tagline{
      height: 118px;
      background-color: blue;
      border: 1px solid black;
      font-size: 26px;
      text-align: right;
    }
      .tagline span{
        background-color: grey;
    }
      .tagline:hover{
        background-color: purple;
    }
    
In it's current state half-sass can produce the code above, but the real SASS implementation has other features like support for math, advanced importing of other SASS stylesheets and definitions. As well as support for mix-ins with arguments and a bunch of other cool stuff. Someone should fork this project and run with it. 