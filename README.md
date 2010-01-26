#HALF-SASS

This project is in no way affiliated with the original SASS project. I'm just a huge fan of using SASS for my non CF projects and wanted to have similar funcationality when workin in CF. Much props to the brilliant people who created SASS. In my humble opinion it is what CSS should have been and I wish that browsers would support it natively.
In it's current state this is only a partial implementation of [Syntactically Awesome Style Sheets (SASS)](http://sass-lang.com/), but it's written entirely in CFML.
For those unfamiliar with SASS it's an abstraction layer for CSS. CSS is insanely repetitive. So SASS makes it DRY.

For example:

    !my_var = 118px 		// declaring a variable

    =my_mixin 			// this is a mixin, you can think of it like a snippet 
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
    
In it's current state half-sass can produce the code above, but the real SASS implementation has other features like support for math, advanced importing of other SASS stylesheets and definitions. As well as support for mix-ins with arguments and a bunch of other cool stuff.
It is unlikely that I'll take it quite that far. But this code will let me at least take advantage of some of the things I always wish that CSS had, like variables and mixins.

Since I'm no longer working in a CF job, this project is not actively maintained by Henrik Joreteg. If you're interested in contributing and you know how to write and run unit tests in MXUnit, contact me.