nearestNeighbor <- function(x) {
  stopifnot(is.ts(as.ts(x))) 
  
  findNearestNeighbors <- function(x, i) {
    leftValid <- FALSE
    rightValid <- FALSE 
    numItLeft <- 1
    numItRight <- 1
    while (!leftValid) {
      leftNeighbor <- x[i - numItLeft]
      if (!is.na(leftNeighbor)) {
        leftValid <- TRUE
        leftNeighbor <- i - numItLeft
      }
      numItLeft <- numItLeft + 1
    }
    while (!rightValid) {
      rightNeighbor <- x[i + numItRight]
      if (!is.na(rightNeighbor)) {
        rightValid <- TRUE
        rightNeighbor <- i + numItRight
      }
      numItRight <- numItRight + 1
    }
    return(c(leftNeighbor, rightNeighbor))
  }
  
  for (i in 1:length(x)) {
    if (is.na(x[i])) {
      nearestNeighborsIndices <- findNearestNeighbors(x, i)
      a <- nearestNeighborsIndices[1]
      b <- nearestNeighborsIndices[2]
      if (i < ((a + b) / 2)) {
        x[i] <- x[a]
      } else {
        x[i] <- x[b]
      }
    }
  }
  return(x)
}