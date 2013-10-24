int_slope_lmodel2 <- function(fit, method = "RMA")
  # computes intercepts and slopes of fitted and confidence limits' bands for model II regression fitted by lmodel2
  # fit: a lmodel2 object
  # method: OLS, MA, SMA, RMA
  # returns a data.frame which than can be passed to geom_abline() in ggplot2 (see example below)
  # based on code lmodel2 code by Pierre Legendre URL https://r-forge.r-project.org/scm/viewvc.php/devel/lmodel2/R/lmodel2.R?view=markup&revision=561&root=vegan&pathrev=561
  # modified by Marina Varfolomeeva
{
  centr.y <- mean(fit$y)
  centr.x <- mean(fit$x)
  row <- which(fit$regression.results == method)
  a <- fit$regression.results[row,2]
  b <- fit$regression.results[row,3]
  b1 <- fit$confidence.intervals[row,4]
  a1 <- centr.y - b1*centr.x
  b2 <- fit$confidence.intervals[row,5]
  a2 <- centr.y - b2*centr.x
  res <- data.frame(line = c("predicted", "lower", "upper"), 
                    intercept = c(a, a1, a2),
                    slope = c(b, b1, b2))
  if((row != 1) && (fit$rsquare <= fit$epsilon)) {
    warning("R-square = 0: model and C.I. not drawn for MA, SMA or RMA")
  }
  return(res)
}

# # Example usage of int_slope_lmodel2()
# library(ggplot2)
# library(lmodel2)
# data(cars)
# fit <- lmodel2(dist ~ speed, range.y="interval", range.x="interval", data=cars, nperm = 100)
# reg_lines <- int_slope_lmodel2(fit)
# ggplot(cars) + 
#   geom_point(data = cars, aes(x = speed, y = dist)) +
#   geom_abline(data = reg_lines, aes(intercept = intercept, slope = slope), colour = c("blue", "red", "red"))
# # Compare with built-in plot for lmodel2
# plot(fit, "RMA")
