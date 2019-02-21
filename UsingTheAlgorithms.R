# the following code is taken directly from Wes' PhD: 

# the following is only required if you haven't installed the package already
# note: dependency on multitaper package
# library(devtools)
# install_github("wesleyburr/tsinterp")

library(tsinterp)
data(flux)
ok <- flux[, "S"]
sag <- flux[, "SagOrig"]
finish <- FALSE 
while(!finish) {
  gap <- which(ok == FALSE)
  # bottom line is g_d
  diff <- gap[-1] - gap[-length(gap)]
  pos <- which(diff > 50)
  
  if (length(pos) > 0) {
    maxL <- gap[pos[1] + 1] - 1
    minL <- max(1, gap[1] - 100 )
  }
  
  gap <- gap[gap > minL & gap < maxL]
  gap <- gap - minL + 1
  zP <- sag[minL:maxL]
  
  y <- interpolate(zP, gap, maxit = 20, progress = TRUE, sigClip = 0.999)
  sag[minL:maxL] <- y[[1]]
  ok[minL:maxL] <- rep(TRUE, (maxL-minL + 1) )
  
  if (length(which(ok == FALSE) == 0)) {
    finish <- TRUE
  }
  else {
    finish <- TRUE 
  }
}

plot(zP, type = "l")
lines(y[[1]], col = "red")
