rsource =
    #
    # e = new.env()
    # rsource("inst/A/a.R", e, chdir = TRUE, prompt.echo = "!!! ", echo = TRUE)
    #
function()
{
    if(!is(source, "functionWithTrace")) {
        message("setting trace on source")
        # environment(fixSourceCall) = sys.frame(sys.nframe())

        k = match.call() # sys.call()
        expr = substitute(fixSourceCall(e, sys.nframe(), quote(call)),
                                 list(e = environment(), call = k))

        trace(source, expr, print = FALSE)
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
    pos = sys.nframe() - 5
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
#    TRUE
}
