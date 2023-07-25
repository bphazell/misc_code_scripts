cf_packrat_snapshot <- function(){
  packrat::snapshot(sourcePackagePaths = c("vendor/rlibs/data.r.utils"))
}

cf_packrat_install_vendored <- function(){
  devtools::install_local('vendor/rlibs/data.r.utils')
}
