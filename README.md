
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Feature importance in k-means clustering

We present a novel approach for measuring feature importance in k-means
clustering, or variants thereof, to increase the interpretability of
clustering results. In supervised machine learning, feature importance
is a widely used tool to ensure interpretability of complex models. We
adapt this idea to unsupervised learning via partitional clustering. Our
approach is model agnostic in that it only requires a function that
computes the cluster assignment for new data points.

Based on a simulation study below we show that the algorithm finds the
variables which drive the cluster assignment and scores them according
to their relevance. As a further application, this provides a new
approach for hyperparameter tuning for data sets of mixed type when the
metric is a linear combination of a numerical and a categorical distance
measure - as in Gower’s distance, for example.

In combination with stability analyses, feature importance provides a
means for feature selection, i.e. the identification of a lower
dimensional subspace which offers a reasonable separation. Our package
works with some popular clustering packages such as flexclust,
clustMixType, base R’s kmeans function and the newly developed
ClustImpute package.

## Installation

You can install the package as follows:

``` r
devtools::install_github("o1iv3r/FeatureImpCluster")
```

## Useage with flexclust

We’ll create some random data to illustrate the usage of
FeatureImpCluster. It provides 4 clusters in a 2 dimensional subspace of
a 6 dimensional space

``` r
library(FeatureImpCluster)
#> Loading required package: data.table
dat <- create_random_data(n=4000,nr_other_vars = 4)
summary(dat$data)
#>        V1                  V2                 V3          
#>  Min.   :-3.503537   Min.   :-4.25505   Min.   :-3.69946  
#>  1st Qu.:-0.678525   1st Qu.:-0.67117   1st Qu.:-0.67973  
#>  Median : 0.000047   Median : 0.00745   Median : 0.01825  
#>  Mean   : 0.000000   Mean   : 0.00000   Mean   : 0.00000  
#>  3rd Qu.: 0.668155   3rd Qu.: 0.66007   3rd Qu.: 0.67338  
#>  Max.   : 3.283141   Max.   : 3.72633   Max.   : 3.62204  
#>        V4                 x                  y           
#>  Min.   :-3.74953   Min.   :-2.33650   Min.   :-2.20839  
#>  1st Qu.:-0.67451   1st Qu.:-0.93308   1st Qu.:-0.93919  
#>  Median : 0.01666   Median : 0.02645   Median :-0.02859  
#>  Mean   : 0.00000   Mean   : 0.00000   Mean   : 0.00000  
#>  3rd Qu.: 0.69444   3rd Qu.: 0.92371   3rd Qu.: 0.93294  
#>  Max.   : 3.65882   Max.   : 2.16919   Max.   : 2.14545
```

``` r
library(ggplot2)
true_clusters <- factor(dat$true_clusters)
ggplot(dat$data,aes(x=x,y=y,color=true_clusters)) + geom_point()
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

If our clustering works well, x and y should determine the partition
while the other variables V1,..,V4 should be irrelevant. Feature
importance is a novel way to determine whether this is the case. We’ll
use the flexclust package for this example. Its main function
FeatureImpCluster computes the permutation missclassification rate for
each variable of the data. The mean misclassification rate over all
iterations is interpreted as variable importance. The permutation
missclassification rate of a feature (column) is the number of wrong
cluster assignments divided by the number of observations (rows) given a
permutation of the feature.

``` r
library(FeatureImpCluster)
library(flexclust)
#> Loading required package: grid
#> Loading required package: lattice
#> Loading required package: modeltools
#> Loading required package: stats4
set.seed(123)
res <- kcca(dat$data,k=4)
FeatureImp_res <- FeatureImpCluster(res,as.data.table(dat$data))
plot(FeatureImp_res)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

Indeed, y and x are most relevant. But also V4 and V1 have some impact
on the cluster assignment. By looking at the cluster centers, we see
that, in particular, cluster 2 and 4 have a different center in the V4
and V1 dimension than the other
clusters.

``` r
barplot(res)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

``` r
# bwplot(res,dat$data), image(res,which=5:6) # alternative diagnostic plots of flexclust
```

If we had a lot more than 6 variables (and possibly more clusters), then
the chart above might be hard to interpret. The feature importance plot
instead provides an aggregate statistics per feature and is, as such,
always easy to interpret.

## Feature selection

We know that the clustering is impacted by the random initialization.
Thus it is usually recommended to run the clustering alogrithm several
times with different seeds. As a by-product, the feature importance will
provide us a feature selection mechanism: we can take the median over
the importance of a feature over various iterations so that any spurious
importance is correctly identified as outlier.

For our example we calculate the feature importance 5 times before
taking the median:

``` r
set.seed(123)
nr_seeds <- 5
seeds_vec <- sample(1:1000,nr_seeds)

savedImp <- data.frame(matrix(0,nr_seeds,dim(dat$data)[2]))
count <- 1
for (s in seeds_vec) {
  set.seed(s)
  res <- kcca(dat$data,k=4)
  FeatureImp_res <- FeatureImpCluster(res,as.data.table(dat$data),sub = 1,biter = 10)
  savedImp[count,] <- FeatureImp_res$featureImp[sort(names(FeatureImp_res$featureImp))]
  count <- count + 1
}
names(savedImp) <- sort(names(FeatureImp_res$featureImp))
median_importance <- sapply(savedImp,median)
```

Now it becomes quite obvious that x and y are the only relevant
features, and we could do our clustering only based on these features.
This is importantant in practice since cluster centroids with a lower
number of features are easier to interpret, and we can save time / money
collecting and pre-processing unnecessary
features.

``` r
data2plot <- data.frame(Feature=names(median_importance),Importance=median_importance)
ggplot(data2plot,aes(x=Feature,y=sort(Importance,decreasing = F))) + geom_col() + 
  coord_flip() + ylab("Median feature importance") + theme_light()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Data sets of mixed type

Another application arises for data sets with numerical and categorical
features. Since one cannot simply calculate an Euclidean distance for
categorical variables, one often uses an L0-norm (1 for equality, 0
else) for the latter and combines both metrices linearly with an
appropriate weight (often this choice is referred to as Gower’s distance
in the literature). In the clustMixType package the parameter **lambda**
defines the trade off between Euclidean distance of numeric variables
and simple matching coefficient between categorical variables. Feature
Importance can be used as an additional guide to tune this parameter.

First we add categorical variables to our data set

``` r
ds <- as.data.table(dat$data)

n <- dim(ds)[1]
p <- dim(ds)[2]

set.seed(123)
ds[,cat1:=factor(rbinom(n,size=1,prob=0.3),labels = c("yes","no"))] # irrelevant factor
ds[,cat2:=factor(c(rep("yes",n/2),rep("no",n/2)))] # relevant factor
```

Obviously x and cat2 are strongly correlated.

``` r
cor(ds$x,as.numeric(ds$cat2),method="spearman")
#> [1] 0.8657435
```

First we’ll apply the clustering with an automatic estimation of
**lambda**

``` r
library(clustMixType)
res <- kproto(x=ds,k=4)
#> # NAs in variables:
#>   V1   V2   V3   V4    x    y cat1 cat2 
#>    0    0    0    0    0    0    0    0 
#> 0 observation(s) with NAs.
#> 
#> Estimated lambda: 2.17156
res$lambda
#> [1] 2.17156
```

With color=“type” we can draw the attention to the importance by data
type. While cat2 correctly has some importance, the one of cat1 is
almost zero.

``` r
FeatureImp_res <- FeatureImpCluster(res,ds)
plot(FeatureImp_res,ds,color="type")
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

All in all the numeric variables are more important for the
partitioning. If, for some reason, we wanted partitions that emphasize
differences between the cateogrical features, we’d have to increase
**lambda**. The feature importance directly shows us the effect of this
action: the two categorical features now have an equally high importance
only somewhat smaller than x. As above, repeated partitioning could be
used to compute a more reasonable importance for the data set and not
only an importance for a specific partition.

``` r
res2 <- kproto(x=ds,k=4,lambda=3)
#> # NAs in variables:
#>   V1   V2   V3   V4    x    y cat1 cat2 
#>    0    0    0    0    0    0    0    0 
#> 0 observation(s) with NAs.
plot(FeatureImpCluster(res2,ds),ds,color="type")
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

Of course, further criteria should be used to determine an “optimal”
**lamda** for the use case at hand - but certainly featuer importance
provides helpful guidance for data of mixed types.

## Other methods: kmeans(), pam() and ClustImpute()

FeatureImpCluster can be easily used with other packages. For example,
stats::kmeans or cluster::pam can be used via flexclust:

``` r
cl_kcca <- flexclust::as.kcca(cl, dat$data) # cl is a kcca or pam object
FeatureImpCluster(cl_kcca,as.data.table(dat$data))
```

ClustImpute, a package that efficiently imputes missing values while
performing a k-means clustering can be used directly:

``` r
library(ClustImpute)
res_clustimpute <- ClustImpute(as.data.frame(dat$data),4)

FeatureImpCluster(res_clustimpute,as.data.table(dat$data))
```

For other methods, a custom prediction function can be provided
(cf. documentation for
details)

``` r
FeatureImpCluster(clusterObj, data, predFUN = custom_prediction_function_for_clusterObj)
#> Warning in mean.default(X[[i]], ...): argument is not numeric or logical:
#> returning NA
#> $misClassRate
#> Empty data.table (0 rows) of 1 col: 
#> 
#> $featureImp
#> named numeric(0)
#> 
#> attr(,"class")
#> [1] "featImpCluster"
#> attr(,"subset")
#> [1] 1
#> attr(,"iterations")
#> [1] 10
```

## Further options

There are further options not being explained in the examples above:

  - For initialization, the prediction methodhas to be computed on the
    entire data set. This can be of high computational cost for large
    data sets. Alterntively one can provide the current partitioning via
    basePred.
  - To further spead up a computation on large data sets, the
    permutation importance can be computed on random subsets of the
    data. This can be controlled via the **sub** parameter
  - The number of iterations (default is 10) can be set via **biter**
