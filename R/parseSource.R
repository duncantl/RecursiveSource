#
# e = new.env()
# psource("inst/A/a.R", e, chdir = TRUE)
# psource("inst/A/a.R", e, chdir = TRUE, echo = TRUE, prompt.echo = ">> ")
#
psource =
function()
{
    use_file = NA # doesn't matter. Only to keep R CMD check happy.
    
    k = match.call()    
    if(length(origCall) == 0) 
        origCall = k

    exprs = as.list(parse(file))
    # modify calls to source() to become calls to psource() with any additional arguments
    exprs = updateCallsToSource(exprs, origCall)

    # Create the call to source() from this call to psource,
    # removing the file argument and and adding an exprs argument.
    # Also remove the origCall from this call to psource.
    k$exprs = exprs
    # need to leave the file for chdir to be able to take effect. but can't have file and exprs
    # That's why we have to handle the chdir/setwd below.
    k = k[-2]    
    m = match("origCall", names(k))
    if(!is.na(m))
        k = k[-m]
    
    k[[1]] = as.name("source")
    
    if(chdir) {
        cwd = getwd()
        on.exit(setwd(cwd))
        setwd(dirname(file))
    }

    # Now perform the call to source()
    eval(k, parent.frame())
}

formals(psource) = formals(source)
# add an origCall parameter with a default value of list()
formals(psource)$origCall = quote(list())

updateCallsToSource =
function(exprs, origCall)
{

    # Make this more general to find the source() calls anywhere, including nested in if(), etc.
    #    idx = findCallsTo(exprs, "source", index = TRUE)
    # For now, look at top-level calls.
    idx = which(sapply(exprs, isCallTo, "source"))

    if(length(idx)) {
        # change to psource and add arguments from origCall.
        exprs[idx] = lapply(exprs[idx], updateSourceCall, origCall)
    }
    exprs
}

updateSourceCall =
    # Change the call to source() to psource()
    # add any arguments in origCall that are not in call
    # and add origCall = quote( actual original call ).
function(call, origCall)    
{
    call = match.call(source, call)
    origParams = names(origCall)[-1]
    addParams = setdiff(origParams, names(call))
    call[ addParams ] = origCall[addParams]
    call[[1]] = as.name("psource")

    call$origCall = substitute(quote(k), list(k = origCall))
    call
}





# From CodeAnalysis
isCallTo =
function(x, funs)
    is.call(x) && is.name(x[[1]]) && as.character(x[[1]]) %in% funs



