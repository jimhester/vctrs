coerces_to <- function(x, y, using = "strict") {
  type_max <- switch(using,
    strict = vec_type2,
    base_c = c,
    base_unlist = function(x, y) unlist(list(x, y)),
    base_modify = function(x, y) `[<-`(x, 2, value = y)
  )

  tryCatch({
    type <- suppressWarnings(type_max(x, y))
    format(vec_type(type))
  }, error = function(e) {
    NA_character_
  })
}

maxtype_mat <- function(types, using = "strict") {
  names(types) <- map_chr(types, function(x) format(vec_type(x)))

  grid <- expand.grid(x = types, y = types)
  grid$max <- map2_chr(grid$x, grid$y, coerces_to, using = using)

  matrix(
    grid$max,
    nrow = length(types),
    dimnames = list(names(types), names(types))
  )
}
