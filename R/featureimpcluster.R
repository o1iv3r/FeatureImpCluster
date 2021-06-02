#' Feature importance for k-means clustering
#'
#' This function loops through \code{\link{PermMisClassRate}} for each variable of the data.
#' The mean misclassification rate over all iterations is interpreted as variable importance.
#'
#' @param clusterObj a "typical" cluster object. The only requirement is that there must be a prediction function which maps the data
#' to an integer
#' @param data data.table with the same features as the data set used for clustering (or the simply the same data)
#' @param basePred should be equal to results of predFUN(clusterObj,newdata=data); this option saves time when data is a very large data set
#' @param predFUN predFUN(clusterObj,newdata=data) should provide the cluster assignment as a numeric vector;
#' typically this is a wrapper around a build-in prediction function
#' @param sub integer between 0 and 1(=default), indicates that only a subset of the data should be used if <1
#' @param biter the permutation is iterated biter(=5, default) times
#'
#' @return A list of
#' \describe{
#'   \item{misClassRate}{A matrix of the permutation misclassification rate for each variable and each iteration}
#'   \item{featureImp}{For each row of complete_data, the associated cluster}
#' }
#'
#' @examples
#' set.seed(123)
#' dat <- create_random_data(n=1e3)$data # random data
#'
#' library(flexclust)
#' res <- kcca(dat,k=4)
#' f <- FeatureImpCluster(res,dat)
#' plot(f)
#'
#' @import data.table
#'
#' @export
FeatureImpCluster <- function(clusterObj,data,basePred=NULL,predFUN=NULL,sub=1,biter=10) {

  # Init
  vars <- names(data)
  len <- length(vars)
  misClassRate_all <- data.table::data.table(matrix(0,biter,len))
  names(misClassRate_all) <- vars

  # loop over PermMisClassRate and collect results in data table
  for (varName in vars) {
    misClassRate <- PermMisClassRate(clusterObj,data,varName,basePred=basePred,predFUN=predFUN,sub=sub,biter=biter)
    misClassRate_all[,(varName):=misClassRate]
  }

  # Compute importance based on misClassRate
  featureImp <- sapply(misClassRate_all,FUN=mean)
  featureImp <- sort(featureImp,decreasing = TRUE)

  result <- structure(list(misClassRate=misClassRate_all,featureImp=featureImp),
                      class="featImpCluster",subset=sub,iterations=biter)
  return(result)
}

#' Feature importance box plot
#'
#' @param x an object returned from FeatureImpCluster
#' @param dat same data as used for the computation of the feature importance (only relevant for colored plots)
#' @param color If set to "type", the plot will show different variable types with a different color.
#' @param showPoints Show points (default is False)
#' @param ... arguments to be passed to base plot method
#'
#' @rdname plot
#' @return Returns a ggplot2 object
#'
#' @export
plot.featImpCluster <- function(x,dat=NULL,color="none",showPoints=FALSE,...) {
  # Create boxplot
  # color="type" requires data
  featImpClusterObj = x

  variable = value = NULL

  biter <- attr(featImpClusterObj,"iterations") # recover number of iterations
  data2plot <- melt(featImpClusterObj$misClassRate,
                    id.vars=NULL,measure.vars=names(featImpClusterObj$misClassRate)) # prepare data

  # color by type of variable
  if (color=="type") {
    attempt::stop_if(is.null(dat),msg="Provide data for option color by type")
    data2plot[,class:=rep(sapply(dat,class),each=biter)]
    data2plot[,variable:=factor(variable,levels=rev(names(featImpClusterObj$featureImp)))]
    p <- ggplot2::ggplot(data2plot, ggplot2::aes(variable, value, color=class)) +
      ggplot2::geom_boxplot(outlier.shape = NA)
  } else if (color=="none") {
    data2plot[,variable:=factor(variable,levels=rev(names(featImpClusterObj$featureImp)))]
    p <- ggplot2::ggplot(data2plot, ggplot2::aes(variable, value)) + ggplot2::geom_boxplot(outlier.shape = NA)

  }

  # use the same theme
  p <- p + ggplot2::ylab("Misclassification rate") + ggplot2::coord_flip() + ggplot2::theme_light() + ggplot2::xlab("")

  if (showPoints) p <- p + ggplot2::geom_jitter(width = 0.1,size=.5)

  return (p)
}
