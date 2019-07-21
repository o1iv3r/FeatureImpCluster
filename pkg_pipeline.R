library(usethis) # https://usethis.r-lib.org/reference/index.html


#### Infrastructure ####

use_gpl3_license(name = "Oliver Pfaffel") # required to share improvements

use_package("flexclust", "Suggests")
use_package("clustMixType", "Suggests")
use_package("ClustImpute", "Suggests")

use_package("attempt", "Suggests")
use_package("data.table", "Depends")
use_package("ggplot2", "Imports")
# use_pipe() # Use %>%

### create R files
use_r("FeatureImpCluster")
use_r("PermMisClassRate")
use_r("Create_random_data")

### documentation
use_news_md()
use_readme_rmd()
use_vignette("Feature-selection")
use_vignette("Usage-with-clustMixType")
use_vignette("Usage-with-ClustImpute")
use_spell_check() # requires spelling package

## Package website
# use_pkgdown() # https://github.com/r-lib/pkgdown
# pkgdown::build_site()
#  check into git, then go to settings for your repo and make sure that the GitHub pages source is set to “master branch /docs folder”. Be sure to update the URL on your github repository homepage so others can easily navigate to your new site.

## github
use_git() # git remote add origin https://github.com/o1iv3r/FeatureImpCluster.git
# use_github()
use_git_config(user.name = "Oliver Pfaffel", user.email = "opfaffel@gmail.com")

## If article or other reference exists
# use_citation()

## tests # https://testthat.r-lib.org/
use_test("PermMisClassRate")
use_test("FeatureImpCluster")
use_coverage() # Add-in test coverage

use_build_ignore(c("pkg_pipeline.R"))

#### Deployment ####

## Document and check package
# restart R session first
devtools::document()
devtools::check(document = FALSE)

## Commit changes
# terminal: git commit -m "Commit message"
# or commit button in Rstudio

## Increment version
use_version() #  increments the "Version" field in DESCRIPTION, adds a new heading to NEWS.md (if it exists), and commits those changes (if package uses Git).

## Push to github
# terminal: git push -u origin master
# or push button in Rstudio

## Build
# Install and Restart
# More Build Source

## Release package to CRAN
# devtools::release()
# devtools::submit_cran()

#### CI ####

use_travis()
use_build_ignore("travis.yml")

use_coverage()
use_build_ignore("codecov.yml")

