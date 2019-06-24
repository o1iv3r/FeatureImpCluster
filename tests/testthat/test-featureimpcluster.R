context("test-featureimpcluster")

## used for several tests
set.seed(123)
nr_other_vars = 2
dat <- create_random_data(n=100,nr_other_vars = nr_other_vars)$data # random data
res <- flexclust::kcca(dat,k=4)
base_pred <-  flexclust::predict(res,dat)
biter = 2
f <- FeatureImpCluster(res,dat,biter=biter)

test_that("Test dimension of outputs", {
  expect_equal(dim(f$misClassRate)[1],biter)
  expect_equal(dim(f$misClassRate)[2],nr_other_vars+2)
  expect_equal(length(f$featureImp),nr_other_vars+2)
})

test_that("Result is not NA", {
  expect_equal(sum(is.na(f$featureImp)),0)
})


# include categorical variables
set.seed(123)
dat_cat <- copy(dat)
dat_cat[,cat1:=factor(rbinom(100,size=1,prob=0.3),labels = c("yes","no"))]
dat_cat[,cat2:=factor(c(rep("yes",50),rep("no",50)))]


test_that("FeatureImp plots", {
  p <- plot(f)
  ps <- plot(f,showPoints = TRUE)

  expect_equal(p$labels$y,"Misclassification rate")
  expect_equal(ps$layers[[2]]$position$width,.1)
  expect_error(plot(f,color="type"))

  # this should simply run through
  res_kproto <- clustMixType::kproto(x=dat_cat,k=4)
  f <- FeatureImpCluster(res_kproto,dat_cat,biter=biter)
  p_cat <- plot(f,dat_cat,color="type")
})
