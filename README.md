Pointers/shortcuts in R with the ‘pointr’ package
================

## Overview

R’s built-in copy-on-modify behavior prevents the user from having two
symbols always pointing to the same object. Because pointers, as they
are common in other programming languages, are essentially symbols
(variable) related to an object that has already another symbol attached
to it, it is clear that pointers do not fit naturally into R’s language
concept.

However, pointers would indredibly useful, e.g. when you work with
complex subsets of dataframes. These complex filtering conditions make
the code harder to read and to maintain. For this reason, it would be
good to have a kind of ‘abbreviation’ or ‘shortcut’ that lets you write
such filtering conditions more efficiently.

The **`pointr`** package provides functionality to create pointers to
any R object easily, including pointers to subsets/selections from
dataframes.

## Working with `pointr`

### Installing and loading `pointr`

To install the CRAN version of **`pointr`** from the R console, just
call:

``` r
install.packages("pointr", dependencies = TRUE)
```

Before using **`pointr`**, it needs to be attached to the package search
path:

``` r
library(pointr)
```

Now, we are ready to go.

### Functions

From the user’s perspective, **`pointr`** provides three simple
functions:

  - **`ptr(symbol1, symbol2)`** creates a pointer called `symbol1` to
    the object in `symbol2`. The function has no return value. The
    `symbol1` pointer variable is created by the function. Both
    arguments, `symbol1` and `symbol2`, are strings.

  - **`rm.ptr(symbol1, keep=TRUE)`** removes the pointer. It deletes the
    hidden access function `.symbol1()`. If `keep == FALSE` it also
    deletes the pointer variable `symbol1`. If, however `keep == FALSE`
    a copy of the object that the pointer refers to is stored in the
    `symbol1` variable. The `symbol1` argument is a string.

  - **`where(symbol1)`** shows the name of the object the pointer
    `symbol1` points to. The `symbol1` argument is a character vector.

Pointers work like the referenced variable itself. You can, for example,
print them (which prints the contents of the referenced variable) or
assign values to them (which assigns the values to the referenced
variable).

### Examples

#### Example 1: A simple vector

First, we define a variable `myvar` and create a pointer `mypointer` to
this variable. Accessing the pointer `mypointer` actually reads `myvar`.

``` r
myvar <- 3
ptr("mypointer", "myvar")
mypointer
```

    ## [1] 3

Accordingly, changes to `myvar` can be seen using the pointer.

``` r
myvar <- 5
mypointer
```

    ## [1] 5

The pointer can also be used in assignments; this changes the variables
the pointer points to:

``` r
mypointer <- 7
myvar
```

    ## [1] 7

#### Example 2: Subsetting a dataframe

We create a simple dataframe:

``` r
df <- data.frame(list(var1 = c(1,2,3), var2 = c("a", "b", "c")), stringsAsFactors = FALSE)
df
```

    ##   var1 var2
    ## 1    1    a
    ## 2    2    b
    ## 3    3    c

Now we set a pointer `sel` to a subset of `df`:

``` r
i <- 2
ptr("sel", "df$var2[i]")
```

We can now change…

``` r
sel <- "hello"
df$var2[i]
```

    ## [1] "hello"

and read data from `df` using the `sel` pointer:

``` r
df$var2[i] <- "world"
sel
```

    ## [1] "world"

We can also check easily where our pointer points to:

``` r
where.ptr("sel")
```

    ## [1] "world"

When the index variable `i` changes, our pointer adjusts accordingly:

``` r
i <- 3
sel
```

    ## [1] "c"

## Technical note

Active bindings are used to create the **`pointr`** pointers. For each
pointer an object with active binding is created. Every time the pointer
is accessed, the active binding calls a hidden function called
`.pointer` where *`pointer`* is the name of the pointer variable. This
function evaluates the assignment (if the user assigns a value to the
pointer) or evaluates the object the pointer refers to as such (if the
user accesses the contents of the object the pointer points to). This
way it is possible not only to address objects like vectors or
dataframes but also to have pointers to things like, for example,
subsets of datafames.

All **`pointr`** functions operate in the environment in which the
pointer is created.
