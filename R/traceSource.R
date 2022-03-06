rsource =
    #
    # e = new.env()
    # rsource("inst/A/a.R", e, chdir = TRUE, prompt.echo = "!!! ", echo = TRUE)
    #
function()
{
    if(!is(source, "functionWithTrace")) {
     
        k = match.call() # sys.call()
        if(TRUE) {
            # if this branch is TRUE, need to export fixSourceCall
           expr = substitute(fixSourceCall(e, sys.nframe(), quote(call)),
                                     list(e = environment(), call = k))
           trace(source, expr, print = FALSE)
        } else {
            # We can't just change the environment and pass that to trace
            # environment(fixSourceCall) = sys.frame(sys.nframe())
            # as trace won't evaluate it until it is required.
            # Instead, we create an anonymous function. The promise will get the
            # correct environment, i.e., this call frame.
            # This is just a different way of setting up the call to fixSourceCall
            # rather than the substitute aboev. So not a big win, just a different
            # approach. The original intent was to have fixSourceCall() defined
            # here locally with this call frame as its environment so it would
            # simply have access to the call and arguments in this call frame
            # and we wouldn't have to pass them as arguments. However, this approach
            # is probably better.
            # 
            env = environment()
            k2 = substitute(quote(call), list(call = k))
            trace(source, function()
                              fixSourceCall(env, sys.nframe(), k2),
              print = FALSE)
        }
        
        on.exit(untrace(source))
    }
    
    k = match.call()
    k[[1]] = as.name("source")

    eval(k, parent.frame())
}

formals(rsource) = formals(source)

fixSourceCall =
function(env, frameNum, origCall)
{
    pos = sys.nframe() - 5 # needs to be 5 for the version w/o the anonymous function for trace().
    curFrame = sys.frame(pos)
    k = sys.calls()[[pos]]
    curCall = match.call(source, k)

    # the origCall is to rsource, not source.
    # so we only compare the arguments
    if(identical(curCall[-1], origCall[-1]))
        return()
    
    margs = setdiff(names(formals(source)), names(curCall)[-1])
    addArgs = intersect(names(origCall), margs)

    lapply(addArgs, function(var) assign(var, get(var, env), envir = curFrame ))
}
