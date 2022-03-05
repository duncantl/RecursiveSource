The source()  function has chdir parameter that temporarily changes
the current working directory to that of the file being sourced.
This means commands such as readLines, read.table, readxl, ...
in the file being sourced can continue to be "local" to the
directory and do not need a relative path.

For recursive calls, i.e., a call to source() in a script that we source(),
they too can add `chdir = TRUE` to the call and that makes sense as the author
of the script knows whether the target script being sourced needs to operate in its
local directory.  So that is up to the author of each script.

However, where the script should be evaluated, i.e., the local parameter, 
or whether verbose and echo should be TRUE or FALSE should be at the discretion
of the user, i.e., the person making the top-level call to source().
These control parameters should be passed to each call to source.



+ static analysis on the target script to modify any calls to source to add the additional arguments.
+ run-time, temporarily define a new function source that captures the arguments
  in the original call to source() 
+ use trace() to catch each call to source() and assign values to 
  parameters from the top-level call if they were not supplied in the specific call.




## rsource and trace()

Unfortuantely, if we call trace() in a function with the name of a function that is local 
to the calling function, trace doesn't inser the function object, but just uses the name
and arranges to find it when it is called. We want 



## Our source() function in R/source2.R
Problem:  When base::source is called
  and that script contains a call to source
  it will see this one but won't pass the ...
  from this top-level call to the subsequent
  calls to source() in those scripts.

 So if we source inst/A/a.R and it calls
     source("../B/b.R")
 that 
