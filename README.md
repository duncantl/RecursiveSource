# Source

A long, long time ago I implemented a version of the source() function
that could track the files it was sourcing recursively.
This would 1) facilitate resolving files relative to different files being source
and 2) allow the code being sourced to check from where they were being sourced.

The source()  function now has a `chdir` parameter that temporarily changes
the current working directory to that of the file being sourced.
This means commands such as readLines, read.table, readxl, ...
in the file being sourced can continue to be "local" to the
directory and do not need a relative path.

For recursive calls, i.e., a call to source() in a script that we source(),
they too can add `chdir = TRUE` to the call and that makes sense as the author
of the script knows whether the target script being sourced needs to operate in its
local directory.  So that is up to the author of each script.

However, in which environment the script should be evaluated, i.e., the local parameter, 
or whether verbose and echo should be TRUE or FALSE should be at the discretion
of the user, i.e., the person making the top-level call to source().
These control parameters should be passed to each call to source.

So we explore how to implement this in this code.
This is a somewhat interesting case study in 
+ static code analysis,
+ meta-programming and manipulating language objects
+ semi-standard evaluation
+ run-time interception of calls
+ call frames and the call stack.

There are several possible approaches to implementing this.

+ √ static analysis on each target script to find and modify any calls to source to add the additional
  arguments from the top-level call.
+ √ run-time, using trace() to catch each call to source() and assign values to 
  parameters from the top-level call if they were not supplied in the specific call.
+ [not implemented (yet)] run-time, temporarily define a new function source that captures the arguments
  in the original call to source() 

## Static analysis

See psource() in [parseSource.R](R/parseSource.R).

This approach parses the file and then modifies any calls to source()
in that file 
+ to instead call psource(), and 
+ add any arguments in the top-level call to psource() to these calls
+ add the top-level call to each call to psource() via the origCall parameter we add to psource().

Each recursive call to source() will become a call to psource().
In each of those calls to psource(), we again parse the new file being sourced()
and change those.


At present, it only handles top-level calls to source(), not those nested within
e.g., if statements or other calls. Fixing this orthogonal to the approach.


## rsource and trace()

See rsource in [traceSource3.R](R/traceSource.R)

We wanted to create a local version of fixSourceCall() so that it had
the environment of the top-level call to source(). This way, it would
have access to all of the argument values in that call.
Unfortuantely, if we pass the modified value of fixSourceCall
to trace() in rsource(), trace() does not evaluate the variable name and get the function.
Instead, it captures the variable name and will then look for that
when the trace code is evaluated in source().
In other words, in a function with the name of a function that is local 
to the calling function, trace doesn't insert the function object, but just uses the name
and arranges to find it when it is called. 

Accordingly, we change our approach.
We create a call to fixSourceCall to pass to trace.
We  insert the current call frame and the call  of the top-level source() command
into this call. Then we pass this to trace().

We only establish the trace() on source once, i.e., in the top-level call to source.
We do this by checking to see if source is already being traced.

We also use on.exit() to remove the trace on source at the end of the top-level call to source().

In each call to fixSourceCall(), we are given the same top-level call frame
and call to source().  We also pass the current frame number.
From the frame number, we can find the current/most recent call to source
and get its call frame  - `curFrame`.
We can also get the current call to source() - `curCall`.

We compare curCall to origCall to see if this is the top-most call to source() in which
case we don't need to do anything.
If it is not the top-most call to source, we 
+ find the parameters NOT in this call to source()
+ find the parameters in the original call to source()

For each parameter in the original call that are not in the current call,
we assign the value of that parameter from the top-level call frame 
to the same parameter in the current call.


In our example,  we call
```
rsource("inst/A/a.R", e, chdir = TRUE, echo = TRUE, prompt.echo = "!!!")
```

+ a.R sources ../B/b.R with an explicit chdir
```
source("../B/b.R", chdir = TRUE)
```
+ b.R 
```
source("C/c.R", chdir = TRUE, echo = FALSE)
```

In the second call to source() for b.R, fixSourceCall()
adds the echo and prompt.echo arguments.

In the third call to source() for c.R, fixSourceCall() 
adds the prompt.echo argument, but not the echo parameter as it is already in the call.
Since echo = FALSE, the prompt.echo argument is not actually used.


It would be nice to remove the messags from trace() and untrace().
We could engineer this, but not now as again, it is orthogonal to focus here.







