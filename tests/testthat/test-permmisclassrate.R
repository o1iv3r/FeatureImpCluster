context("test-permmisclassrate")

## used for several tests
set.seed(123)
dat <- create_random_data(n=100)$data # random data
res <- flexclust::kcca(dat,k=4)
base_pred <-  flexclust::predict(res,dat)

biter=3
p1 <- PermMisClassRate(res,dat,varName="x",predFUN=flexclust::predict,biter=biter,seed=124)
p2 <- PermMisClassRate(res,dat,varName="x",basePred = base_pred,predFUN=flexclust::predict,biter=biter,seed=124)

# test that error if predFUN(clusterObj,newdata=as.data.frame(data))!=basePred
test_that("basePred is checked", {
  expect_error(PermMisClassRate(res,dat,varName="x",basePred=1))
  expect_error(PermMisClassRate(res,dat,varName="x",basePred=rep(1,nrow(dat))))
  expect_equal(p1,p2)
})

test_that("Length of output is correct", {
  expect_equal(length(p1),biter)
})

p3 <- PermMisClassRate(res,dat,varName="x",predFUN=flexclust::predict,sub=.0001,biter=biter)

test_that("Test lower cap for sub", {
  expect_equal(length(p3),biter)
})

## Test other packages
res_clustimpute <- ClustImpute::ClustImpute(dat,4)
p_clustimpute <- PermMisClassRate(res_clustimpute,dat,"x",biter=biter)

## Test unsupported packages
res_cclust <- flexclust::cclust(dat,3)
p_cclust <- PermMisClassRate(res_cclust,dat,"x",predFUN=flexclust::predict)

# include categorical variables
set.seed(123)
dat_cat <- copy(dat)
dat_cat[,cat1:=factor(rbinom(100,size=1,prob=0.3),labels = c("yes","no"))]
dat_cat[,cat2:=factor(c(rep("yes",50),rep("no",50)))]

res_kproto <- clustMixType::kproto(x=dat_cat,k=4)
p_kproto <- PermMisClassRate(res_kproto,dat_cat,"cat2",biter=biter)

test_that("Functionality with other packages than flexclust", {
  expect_equal(length(p_kproto),length(p_clustimpute))
})

# test error if there is no prediction function
res_dummy <- res
class(res_dummy) <- "dummy"
test_that("Prediction function required", {
  expect_error(PermMisClassRate(res_dummy,dat,varName="x"))
})
