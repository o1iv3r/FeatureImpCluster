context("test-permmisclassrate")

# used for several tests
set.seed(123)
dat <- create_random_data(n=10)$data # random data
res <- flexclust::kcca(dat,k=4)
base_pred <-  flexclust::predict(res,dat)

biter=3
p1 <- PermMisClassRate(res,dat,varName="x",predFUN=flexclust::predict,biter=biter,seed=124)
p2 <- PermMisClassRate(res,dat,varName="x",basePred = base_pred,predFUN=flexclust::predict,biter=biter,seed=124)

# error if predFUN(clusterObj,newdata=as.data.frame(data))!=basePred

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
