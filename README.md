# Feature importance in k-means clustering

We present a novel approach for measuring feature importance in k-means clustering, or variants thereof, to increase the interpretability of clustering results.  In supervised machine learning, feature importance is a widely used tool to ensure interpretability of complex models. We adapt this idea to unsupervised learning via partitional clustering. Our approach is model agnostic in that it only requires a function that computes the cluster assignment for new data points. 

Based on simulation studies we show that the algorithm finds the variables which drive the cluster assignment and scores them according to their relevance. As a further application, this provides a new approach for hyperparameter tuning for data sets of mixed type when the metric is a linear combination of a numerical and a categorical distance measure - as in Gower's distance, for example. In combination with stability analyses, feature importance provides a means for feature selection, i.e. the identification of a lower dimensional subspace which offers a reasonable separation. Our package works with some popular clustering packages such as flexclust and clustMixType as well as base R's kmeans function.

 
## Installation

You can install the package with with:

``` r
devtools::install_github("o1iv3r/FeatureImpCluster")
```

## Examples

See vignettes.


## Useage with kmeans via flexclust

``` r
# cl is a kmeans object
cl2 = flexclust::as.kcca(cl, data=x) 
flexclust::predict(cl2,newdata=x)
```
