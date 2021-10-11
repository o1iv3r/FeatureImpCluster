#' Permutation misclassification rate for single variable
#'
#' Answers the following question: Using the current partion as a baseline,
#' what is the misclassification rate if a given feature is permuted?
#'
#' @param clusterObj a "typical" cluster object. The only requirement is that there must be a prediction function which maps the data
#' to an integer
#' @param data data.table with the same features as the data set used for clustering (or the simply the same data)
#' @param varName character; variable name
#' @param basePred should be equal to results of predFUN(clusterObj,newdata=data); this option saves time when data is a very large data set
#' @param predFUN predFUN(clusterObj,newdata=data) should provide the cluster assignment as a numeric vector;
#' typically this is a wrapper around a build-in prediction function
#' @param sub integer between 0 and 1(=default), indicates that only a subset of the data should be used if <1
#' @param biter the permutation is iterated biter(=5, default) times
#' @param seed value for random seed
#'
#' @return vector of length biter with the misclassification rate
#'
#' @examples
#' set.seed(123)
#' dat <- create_random_data(n=1e3)$data # random data
#'
#' library(flexclust)
#' res <- kcca(dat,k=4)
#' PermMisClassRate(res,dat,varName="x")
#'
#' @export
PermMisClassRate <- function(clusterObj,data,varName,basePred=NULL,predFUN=NULL,sub=1,biter=5,seed=123) {

  base_pred = new_pred = NULL # due to NSE notes in R CMD check, cf. https://cran.r-project.org/web/packages/data.table/vignettes/datatable-importing.html

  # Define prediction function here
  if (inherits(clusterObj,"kcca")) {
    # prediction function for flexclust
    predFUN<- flexclust::predict
  } else if (inherits(clusterObj,"kproto")) {
    # prediction function for clustMixType
    predFUN <- function(obj,newdata) {
      stats::predict(obj,newdata)$`cluster`
    }
  } else if (inherits(clusterObj,"kmeans_ClustImpute")) {
    # predFUN <- ClustImpute:::predict.kmeans_ClustImpute
    predFUN <- stats::predict
  } else if (is.null(predFUN)) {
    attempt::stop_if(is.null(predFUN),msg="Provide prediction function")
  }

  n <- nrow(data) # number of rows of data

  # baseline: cluster before permutation
  if (is.null(basePred)) {
    data[,base_pred:=predFUN(clusterObj,newdata=as.data.frame(data))] # predict may not be able to deal with data.table
  } else {# if basePred is provided

    # check length of basePred
    attempt::stop_if_not(length(basePred)==n,msg="Length of basePred is not equal to the number of rows of data")

    # check on small sample that predFUN(clusterObj,newdata=as.data.frame(data))==basePred
    # do not fix seed to improve this test in case of various interations
    idx_test <- sample(x=1:n,size=min(10,n),replace=FALSE)
    data_test <- data[idx_test,]
    attempt::stop_if_not(identical(basePred[idx_test],predFUN(clusterObj,newdata=as.data.frame(data_test))),
                         msg="predFUN(clusterObj,newdata=as.data.frame(data))==basePred is violeted on a small sample of data")

    data[,base_pred:=basePred]
  }

  set.seed(seed)

  # iterate over biter
  misClassRate <- rep(0,biter)
  for (b in 1:biter) {

    # take a new subset of the data in each permutation (true error bounds)
    if (sub<1) {
      data_perm <- copy(data)
      data_perm <- data_perm[sample(x=1:n,size=max(1,round(sub*n)),replace=FALSE),]
      n <- nrow(data_perm)
    } else {
      data_perm <- copy(data) # copy data before permuting
    }

    # permute rows of variable column randomly
    var_perm <- data_perm[,get(varName)][sample(x=1:n,size=n,replace=FALSE)]
    data_perm[,(varName):=var_perm] # overwrite varName dynamically

    # predictions after permutation
    data_perm[,new_pred:=predFUN(clusterObj,newdata=as.data.frame(data_perm[,!"base_pred"]))]

    # compute missclassification rate
    misClassRate[b] <- data_perm[,sum(base_pred!=new_pred)/.N]
  }

  data[,base_pred:=NULL] # remove this in the end
  return (misClassRate)
}


