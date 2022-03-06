\name{psource}
\alias{psource}
\title{Recursive source that passes user control arguments to recursive source() calls}
\description{
  This is a version of \code{source}
  that passes the additional arguments in the top-level call to \code{source}
  to each of the sub-calls to \code{source} in the target file
  and files that they also source.
  This is important when specifying a value for the \code{local} parameter.
  It is also convenient to have the parameters such as
  \code{echo}, \code{verbose}, \code{prompt.echo}, etc.
}
\usage{
psource(file, local = FALSE, echo = verbose, print.eval = echo,
        exprs, spaced = use_file, verbose = getOption("verbose"),
        prompt.echo = getOption("prompt"), max.deparse.length = 150,
        width.cutoff = 60L, deparseCtrl = "showAttributes",
        chdir = FALSE, encoding = getOption("encoding"),
        continue.echo = getOption("continue"), skip.echo = 0,
        keep.source = getOption("keep.source"),
        origCall = list())
}
\arguments{
  \item{file}{see help for \code{\link[base]{source}}
}
\item{local}{
  see help for \code{\link[base]{source}}
}
\item{echo}{
 see help for \code{\link[base]{source}}  
}
  \item{print.eval}{
 see help for \code{\link[base]{source}}  
}
  \item{exprs}{
 see help for \code{\link[base]{source}}  
}
  \item{spaced}{
 see help for \code{\link[base]{source}}  
}
  \item{verbose}{
 see help for \code{\link[base]{source}}  
}
  \item{prompt.echo}{
 see help for \code{\link[base]{source}}  
}
  \item{max.deparse.length}{
 see help for \code{\link[base]{source}}  
}
  \item{width.cutoff}{
 see help for \code{\link[base]{source}}  
}
  \item{deparseCtrl}{
 see help for \code{\link[base]{source}}  
}
\item{chdir}{
 see help for \code{\link[base]{source}}    
}
\item{encoding}{
 see help for \code{\link[base]{source}}      
}
\item{continue.echo}{
 see help for \code{\link[base]{source}}        
}
\item{skip.echo}{
 see help for \code{\link[base]{source}}          
}
  \item{keep.source}{
 see help for \code{\link[base]{source}}          
}

\item{origCall}{ this argument is used by the internal
  implementation to pass the top-level call object
  to each call to psource which then uses this
  to modify the call to \code{\link[base]{source}}.
}
}
\details{
  This uses \code{\link[base]{trace}} to intercept calls to \code{source}
  and then modify that call frame to \code{source} before the body
  is evaluated.
}
\value{
 see help for \code{\link[base]{source}}          
}
\references{
\code{\link[base]{source}}          
}
\author{
Duncan Temple Lang
}
\seealso{
  \code{\link[base]{source}}

  There is a different implementation using \code{trace} in \code{\link{rsource}}.
}

\examples{
e = new.env()
f = system.file("A/a.R", package = "RecursiveSource")

before = ls()
psource(f, e, chdir = TRUE, prompt.echo = "!!! ", echo = TRUE)
after = ls()

ls(e)
# This will show a, b, c, x in the environment e.
}
\keyword{IO}

