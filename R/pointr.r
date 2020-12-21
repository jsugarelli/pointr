#' @title Package 'pointr'
#'
#' @description The \pkg{pointr} package allows to work with pointers to R
#'   objects/selection in order to make the R code more readable and
#'   maintainable.
#'   The main function of the package are: \emph{\code{ptr()}} to
#'   create a pointer, \emph{\code{rm.ptr()}} to remove a pointer, and
#'   \emph{\code{where.ptr()}} to check the target object of a pointer.
#'
#' @name pointr
#'
NULL


# Helper function that returns the R code of the hidden access function used to
# create the active binding for the pointer variable.
createAccessFun <- function(symbol1, symbol2) {
  varname <- paste0(".zstor", sample(10000000:99999999, 1))
  return(paste0("
  .", symbol1, "<- function(arg = NULL) {
    # ", symbol2, "
    if(!is.null(arg)) {
      assign(\"", varname, "\", eval(arg), env = parent.env(environment()))
      eval(parse(text=\"", symbol2, " <- ", varname, "\"), envir = parent.env(environment()))
      rm(",varname,", envir = parent.env(environment()))
    }
    else {
      return(eval(parse(text=\"", symbol2,"\"), envir = parent.env(environment())))
    }
  }
 "))
}

#' @title Working with pointers
#'
#' @description Create, remove and analyze pointers in R. Pointers can point to
#'   any R object, including selections/subsets.
#'
#' @param symbol1 The name of the pointer, as a one-element character vector.
#' @param symbol2 The object/selection the pointer will point to, as a
#'   one-element character vector.
#' @param keep A logical value relevant when removing a pointer with
#'   \code{rm.ptr}. If \code{TRUE}, the pointer variable will be kept and filled
#'   with a copy of the object the pointers points to; if \code{FALSE}, the
#'   pointer variable \code{symbol1} will be removed completely. Default is
#'   \code{FALSE}.
#'
#' @details The \code{ptr()} function and the \code{\%=\%} operator will create
#'   a pointer to an R object, like a vector, list, dataframe or even a
#'   subset/selection from a dataframe. \code{where.ptr()} shows where a pointer
#'   actually points to. Existing pointers can be removed usig the
#'   \code{rm.ptr()} function. Pointers created with \pkg{pointr} use active
#'   bindings that call a hidden access function everytime the pointer is
#'   accessed. This hidden access function is named \code{.pointer()} (where
#'   \code{pointer} is the name of the pointer variable) and is created in the
#'   environment from which \code{ptr()} is called. It is not necessary to call
#'   this hidden access function as a pointer user. The hidden access function
#'   is removed when \code{rm.ptr()} is called.
#'
#' @return \code{ptr()}, \code{\%=\%} and \code{rm.ptr()} have no return value.
#'   \code{ptr()} and \code{\%=\%} create the pointer variable (argument
#'   \code{symbol1}) in the environment from which it is called.
#'   \code{where.ptr} returns the object/selection a pointer points to as a
#'   character vector.
#'
#' @section Contributions: Thanks to Chad Hammerquist for contributing the
#'   \code{pointr} operator \code{\%=\%}.
#'
#' @family pointr
#' @export
#'
#' @examples
#'
#' library(pointr)
#'
#' # Pointer to simple variable
#'
#' myvar <- 3
#' ptr("mypointer", "myvar")
#' mypointer
#'
#' myvar <- 5
#' mypointer
#'
#' mypointer <- 7
#' myvar
#'
#'
#' # Alternative: Use the pointr operator %=%
#'
#' myvar <- 3
#' mypointr %=% myvar
#' myvar
#'
#'
#' # Pointer to subset from dataframe
#'
#' df <- data.frame(list(var1 = c(1,2,3), var2 = c("a", "b", "c")), stringsAsFactors = FALSE)
#' df
#'
#' i <- 2
#' ptr("sel", "df$var2[i]")
#'
#' sel <- "hello"
#' df$var2[i]
#'
#' df$var2[i] <- "world"
#' sel
#'
#' where.ptr("sel")
#' @order 1
ptr <- function(symbol1, symbol2) {
  funcode <- createAccessFun(symbol1, symbol2)
  eval(parse(text = funcode), envir = parent.frame())
  makeActiveBinding(symbol1, get(paste0(".", symbol1), envir = parent.frame()), env = parent.frame())
}


#' @rdname ptr
#' @export
rm.ptr <- function(symbol1, keep = FALSE) {
  rm(list=paste0(".", symbol1), envir=parent.env(environment()))
  if(keep == FALSE) {
    rm(list=symbol1, envir=parent.env(environment()))
  } else {
    pres <- eval(parse(text=symbol1), envir=parent.env(environment()))
    rm(list=paste0(symbol1), envir=parent.env(environment()))
    assign(symbol1, pres, envir=parent.env(environment()))
  }
}


#' @rdname ptr
#' @export
where.ptr <- function(symbol1) {
  code <- utils::capture.output(eval(parse(text=paste0(".", symbol1))))
  return(substring(code[2], stringr::str_locate(code[2], "# ")[2]+1, nchar(code[2])))
}


#' @rdname ptr
#' @order 3
#' @export
'%=%' <- function(symbol1, symbol2){
  symbol1 <- deparse(substitute(symbol1))
  symbol2 <- deparse(substitute(symbol2))
  funcode <- createAccessFun(symbol1, symbol2)
  eval(parse(text = funcode), envir = parent.frame())
  makeActiveBinding(symbol1, get(paste0(".", symbol1), envir = parent.frame()), env = parent.frame())
}
