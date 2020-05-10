#' Create random data set with 4 clusters
#'
#' Create random data set with 4 clusters in a 2 dimensional subspace of a nr_othter_vars+2 dimensional space
#'
#' @param n number of points
#' @param nr_other_vars number of other variables / "noise" dimensions
#'
#' @return list containing the random data.table and a vector with the true underlying cluster assignments
#'
#' @examples
#' create_random_data(n=1e3)
#'
#' @export
create_random_data = function(n=1e4,nr_other_vars=4) {
  n <- round(n/4)*4
  mat <- matrix(stats::rnorm(nr_other_vars*n),n,nr_other_vars)
  me<-2.5 # mean
  x <- c(stats::rnorm(n/2,me,1),stats::rnorm(n/2,-me,1))
  y <- c(stats::rnorm(n/4,me,1),stats::rnorm(n/4,-me,1),stats::rnorm(n/4,me,1),stats::rnorm(n/4,-me,1))
  data <- cbind(mat,x,y)
  data<- as.data.frame(scale(data))
  data.table::setDT(data)
  true_clust <- c(rep(1,n/4),rep(2,n/4),rep(3,n/4),rep(4,n/4))

  return(list(data=data,true_clusters=true_clust))
}
