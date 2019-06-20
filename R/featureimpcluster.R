# FeatureImpCluster is a generic function
FeatureImpCluster <- function (clusterObj, ...) {
  UseMethod("FeatureImpCluster", clusterObj)
}

# Feature Importance for flexclust
FeatureImpCluster.kcca <- function(clusterObj,data,basePred=NULL,sub=1,biter=10) {

  # Init
  vars <- names(data)
  len <- length(vars)
  misClassRate_all <- data.table(matrix(0,biter,len))
  names(misClassRate_all) <- vars

  # loop over PermMisClassRate and collect results in data table
  for (varName in vars) {
    misClassRate <- PermMisClassRate(clusterObj,data,varName,basePred,predFUN=predict,sub,biter)
    misClassRate_all[,(varName):=misClassRate]
  }

  # Compute importance based on misClassRate
  featureImp <- sapply(misClassRate_all,FUN=mean)
  featureImp <- sort(featureImp,decreasing = TRUE)

  result <- structure(list(misClassRate=misClassRate_all,featureImp=featureImp),class="featImpCluster",subset=sub,iterations=biter)
  return(result)
}

# Feature Importance for own approach
FeatureImpCluster.kproto <- function(clusterObj,data,basePred=NULL,sub=1,biter=10) {

  # prediction function for own approach
  predFun_kproto <- function(obj,newdata) {
    predict(obj,newdata)$`cluster`
  }

  # Init
  vars <- names(data)
  len <- length(vars)
  misClassRate_all <- data.table(matrix(0,biter,len))
  names(misClassRate_all) <- vars

  # loop over PermMisClassRate and collect results in data table
  for (varName in vars) {
    misClassRate <- PermMisClassRate(clusterObj,data,varName,basePred,predFUN=predFun_kproto,sub,biter)
    misClassRate_all[,(varName):=misClassRate]
  }

  # Compute importance based on misClassRate
  featureImp <- sapply(misClassRate_all,FUN=mean)
  featureImp <- sort(featureImp,decreasing = TRUE)

  result <- structure(list(misClassRate=misClassRate_all,featureImp=featureImp),class="featImpCluster",subset=sub,iterations=biter)
  return(result)
}

#### Plot methods ####

# plot method for class featImpCluster
plot.featImpCluster <- function(featImpClusterObj,data=NULL,color="none",showPoints=FALSE) {
  # Create boxplot
  # color="type" requires data

  biter <- attr(featImpClusterObj,"iterations") # recover number of iterations
  data2plot <- melt(featImpClusterObj$misClassRate,
                    id.vars=NULL,measure.vars=names(featImpClusterObj$misClassRate)) # prepare data

  # color by type of variable
  if (color=="type") {
    data2plot[,class:=rep(sapply(data,class),each=biter)]
    data2plot[,variable:=factor(variable,levels=rev(names(featImpClusterObj$featureImp)))]
    p <- ggplot(data2plot, aes(variable, value, color=class)) + geom_boxplot(outlier.shape = NA)
  } else if (color=="none") {
    data2plot[,variable:=factor(variable,levels=rev(names(featImpClusterObj$featureImp)))]
    p <- ggplot(data2plot, aes(variable, value)) + geom_boxplot(outlier.shape = NA)

  }

  # use the same theme
  p <- p + ylab("Misclassification rate") + coord_flip() + theme_light() + xlab("")

  if (showPoints) p <- p + geom_jitter(width = 0.1,size=.5)

  return (p)
}
