#' Permutation misclassification rate for single variable
#'
#' Creates a plot of the crayon colors in \code{\link{brocolors}}
#'
#' @param method2order method to order colors (\code{"hsv"} or \code{"cluster"})
#' @param cex character expansion for the text
#' @param mar margin parameters; vector of length 4 (see \code{\link[graphics]{par}})
#'
#' @return None
#'
#' @examples
#' plot_crayons()
#'
#' @export

PermMisClassRate <- function(clusterObj,data,varName,basePred=NULL,predFUN,sub=1,biter=5) {
  # data is a data.table
  # clusterObj: the function call predict(clusterObj,newdata=data) should produce an integer
  # varName: character with variable name
  # basePred: provide base prediction, i.e., results of predict(clusterObj,newdata=data), so that predict() does not have to be applied to the whole data set
  # sub: take only a subset of data
  # biter: number of iterations for permutation

  # baseline: cluster before permutaiton
  if (is.null(basePred)) {
    data[,base_pred:=predFUN(clusterObj,newdata=as.data.frame(data))] # predict may not be able to deal with data.table
  } else {
    data[,base_pred:=basePred]
  }

  # iterate over b
  misClassRate <- rep(0,biter)
  for (b in 1:biter) {

    n <- nrow(data) # number of rows od data

    # take subset of the data in each permutation (true error bounds)
    if (sub<1) {
      data_perm <- copy(data)
      data_perm <- data_perm[sample(x=1:n,size=round(sub*n),replace=FALSE),]
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


