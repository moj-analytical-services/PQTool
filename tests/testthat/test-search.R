context("search")

library(shiny)
library(RSelenium)
library(testthat)

remDr       <- remoteDriver(port = 4444)
remDr$open(silent = TRUE)
sysDetails  <- remDr$getStatus()
browser     <- remDr$sessionInfo$browserName
appURL      <- "http://127.0.0.1:8888"

test_that("entering search terms returns the 30 most similar questions", {  
  remDr$setImplicitWaitTimeout(10000)
  remDr$navigate(appURL)
  searchBox  <- remDr$findElement("css selector", "#question")
  query      <- "prison joint enterprise cost"
  searchBox$sendKeysToElement(list(query))
  Sys.sleep(2)
  oddResultsRows  <- length(remDr$findElements("css selector", "#similarity_table .odd"))
  evenResultsRows <- length(remDr$findElements("css selector", "#similarity_table .even"))
  totalRowCount   <- oddResultsRows + evenResultsRows
  expect_equal(oddResultsRows, 15)
  expect_equal(evenResultsRows, 15)
  expect_equal(totalRowCount, 30)
})

remDr$close()