#' Construct "list_of" objects
#'
#' A `list_of` object is a list where each element has the same type.
#' Modifying the list with `$`, `[`, and `[[` preserves the constraint
#' by coercing all input items.
#'
#' @inheritParams vec_c
#' @param x For `as_list_of()`, a vector to be coerced to list_of.
#' @export
#' @examples
#' x <- list_of(1:3, 5:6, 10:15)
#' tibble::tibble(x = x)
#'
#' vec_c(list_of(1, 2), list_of(FALSE, TRUE))
list_of <- function(..., .type = NULL) {
  args <- list2(...)

  type <- find_type(args, .type = .type)
  if (is_null(type)) {
    stop("Could not find common type for elements of `x`", call. = FALSE)
  }

  x <- map(args, vec_cast, to = type)
  new_list_of(x, type)
}

#' @export
#' @rdname list_of
as_list_of <- function(x, ...) {
  UseMethod("as_list_of")
}

#' @export
as_list_of.list_of <- function(x, .type = NULL, ...) {
  if (!is.null(.type)) {
    list_of(!!!x, .type = .type)
  } else {
    x
  }
}

#' @export
as_list_of.list <- function(x, ..., .type = NULL) {
  list_of(!!!x, .type = .type)
}

#' @export
#' @rdname list_of
new_list_of <- function(x, .type) {
  stopifnot(is.list(x))
  stopifnot(vec_length(.type) == 0)

  structure(
    x,
    type = .type,
    class = "list_of"
  )
}

#' @export
#' @rdname list_of
is_list_of <- function(x) {
  inherits(x, "list_of")
}

# registered .onLoad
type_sum.list_of <- function(x) {
  paste0("list<", tibble::type_sum(attr(x, "type")), ">")
}

#' @export
vec_type_string.list_of <- function(x) {
  paste0("list_of<", vec_type(attr(x, "type")), ">")
}

#' @export
print.list_of <- function(x, ...) {
  cat(format(vec_type(x)), "\n", sep = "")

  # Expensive: need to find a better way
  attr(x, "type") <- NULL
  class(x) <- NULL

  print(x)
}

#' @export
as.list.list_of <- function(x, ...) {
  attr(x, "type") <- NULL
  attr(x, "class") <- NULL
  x
}

#' @export
`[.list_of` <- function(x, ...) {
  new_list_of(NextMethod(), attr(x, "type"))
}

#' @export
`[<-.list_of` <- function(x, i, value) {
  value <- map(value, vec_cast, attr(x, "type"))
  NextMethod()
}

#' @export
`[[<-.list_of` <- function(x, i, value) {
  value <- vec_cast(value, attr(x, "type"))
  NextMethod()
}

#' @export
`$<-.list_of` <- function(x, i, value) {
  value <- vec_cast(value, attr(x, "type"))
  NextMethod()
}
