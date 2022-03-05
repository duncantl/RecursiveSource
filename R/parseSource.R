#
psource =
function()
{
    origCall = substitute(k, list(k = origCall))

    k = match.call()    
    if(length(origCall) == 0) {
        # need to leave the file for chdir to be able to take effect. but can't have file and exprs
        origCall = k
        #m = match("origCall", names(k))
        #origCall = k[-m]
    } 
        

    exprs = as.list(parse(file))
    exprs = updateCallsToSource(exprs, origCall)

    k$exprs = exprs

    k = k[-2]    
    m = match("origCall", names(k))
    if(!is.na(m))
        k = k[-m]
    
    k[[1]] = as.name("source")
    
    print(getwd())
    if(chdir) {
        cwd = getwd()
        on.exit(setwd(cwd))
        setwd(dirname(file))
    }    
    eval(k, parent.frame())
}

formals(psource) = formals(source)
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
function(call, origCall)    
{
    call = match.call(source, call)
    origParams = names(origCall)[-1]
    addParams = setdiff(origParams, names(call))
    call[ addParams ] = origCall[addParams]
    call[[1]] = as.name("psource")
#    browser()
    call$origCall = substitute(quote(k), list(k = origCall))
    call
}





