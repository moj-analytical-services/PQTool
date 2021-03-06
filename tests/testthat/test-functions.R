library(testthat)

context("nameCleaner")

test_that("does not reformat the names of peers", {
  peers <- c(
    "Lord John H. Smith",
    "Lady Jane H. Smith",
    "The John H. Smith",
    "Baroness Jane H. Smith",
    "Viscount John H. Smith"
  )
  for(peer in peers) {
    actual   <- nameCleaner(peer)
    expected <- peer
    expect_equal(actual, expected)
  }
})

test_that("otherwise, removes excess whitespace and formats: surname, firstname initials", {
  actual   <- nameCleaner("Mr  John  H.  Smith")
  expected <- "Smith, John H."
  expect_equal(actual, expected)
})

test_that("deals with some special cases and duplicated entries", {
  expect_equal(nameCleaner("Sir David Amess"), "Amess, Sir David")
  expect_equal(nameCleaner("Sir Hugh Bayley"), "Bayley, Sir Hugh")
  expect_equal(nameCleaner("Dr Roberta Blackman-Woods"), "Blackman-Woods, Dr Roberta")
  expect_equal(nameCleaner("Nick de Bois"     ), "de Bois, Nick")
  expect_equal(nameCleaner("Sir Simon Burns"  ),"Burns, Sir Simon")
  expect_equal(nameCleaner("Sir David Crausby"),"Crausby, Sir David")
  expect_equal(nameCleaner("Graham P Jones"   ), "Jones, Graham")
  expect_equal(nameCleaner("Ian C. Lucas"     ), "Lucas, Ian")
  expect_equal(nameCleaner("Grahame M. Morris"), "Morris, Grahame")
  expect_equal(nameCleaner("Gloria De Piero"  ), "De Piero, Gloria")
  expect_equal(nameCleaner("Liz Saville Roberts"), "Saville Roberts, Liz")
  expect_equal(nameCleaner("Sir Nicholas Soames"), "Soames, Sir Nicholas")
})

context("cleanCorpus")

test_that("Cleans the corpus of various troublesome elements", {
  dirty_corpus <- readRDS("./examples/data/corpus.rda")
  actual       <- cleanCorpus(dirty_corpus)
  expected     <- readRDS("./examples/data/cleaned_corpus.rda")
  expect_equal(actual, expected)
})

context("summarise")

test_that("Summarises top 12 terms per cluster", {
  expected_terms  <- c("hours", "week", "cells", "unemploy", "per", "class", "data", "work", "spent", "three", "proportion", "hmp")
  expected_scores <- c(36.3, 36, 34.6, 33.5, 33.0, 32.5, 31.6, 31.6, 29.2, 28.8, 25.2, 14.7)
  matrix    <- readRDS("./examples/data/matrix.rda")
  hierarchy <- readRDS("./examples/data/clustering_hierarchy.rda")
  questions <- read.csv("./examples/data/lsa_training_sample.csv")$Question_Text
  actual    <- summarise(type = "cluster", 1, matrix, hierarchy, 12, questions, 100)
  actual_names  <- names(actual)
  actual_scores <- signif(unname(actual), digits = 3)
  expect_equal(actual_names, expected_terms)
  expect_equal(actual_scores, expected_scores)
})

context("fromItoY")

test_that("Substitutes i for y, when it occurs at the end of a word", {
  expect_equal(fromItoY("endi"), "endy")
  expect_equal(fromItoY("istart"), "istart")
  expect_equal(fromItoY("middle"), "middle")
})

context("normVec")

test_that("Returns the length of a vector",{
  vec      <- c(1,1)
  actual   <- signif(normVec(vec), digits = 3)
  expected <- 1.41
  expect_equal(actual, expected)
})

context("normalize")

test_that("normalises the lengths of a matrix to length 1", {
  matrix   <- readRDS("./examples/data/matrix.rda")
  actual   <- normalize(matrix)
  expected <- readRDS("./examples/data/normalised_matrix.rda")
  expect_equal(actual, expected)
})

context("queryVec")

test_that("returns vector of numbers representing indices in vocab", {
  vocab <- readRDS("./examples/data/vocab.rda")
  actual <- queryVec("prison officer", vocab)
  expected <- c(8, 121)
  expect_equal(actual, expected)
})

context("familyName")

test_that("returns expected family name", {
  expect_equal(familyName("Abbott, Diane"), "Abbott")
  expect_equal(familyName("Fox, Dr Liam"), "Fox")
  expect_equal(familyName("De Piero, Gloria"), "De Piero")
})

context("firstName")

test_that("returns expected first name", {
  expect_equal(firstName("Abbott, Diane"), "Diane")
  expect_equal(firstName("Fox, Dr Liam"), "Dr Liam")
  expect_equal(firstName("De Piero, Gloria"), "Gloria")
})

context("urlName")

test_that("returns expected first name", {
  expect_equal(urlName("Abbott, Diane"), "Diane_Abbott")
  expect_equal(urlName("Fox, Dr Liam"), "Liam_Fox")
  expect_equal(urlName("De Piero, Gloria"), "Gloria_De_Piero")
  expect_equal(urlName("Saville Roberts, Liz"), "Liz_Saville-Roberts")
  expect_equal(urlName("The Lord Bishop of Rochester"), "Bishop_of_Rochester")
  expect_equal(urlName("Baroness Armstrong of Hill Top"), "Baroness_Armstrong_of_Hill_Top")
})

context("testConstituencies")

test_that("reports true in cases where constituencies match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  expected <- rep(TRUE, nrow(data))
  actual <- sapply(1:nrow(data), function(x) testConstituencies(data[x,]))
  expect_equal(actual, expected)
})

test_that("reports false in cases where constituencies don't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$MP_Constituency.remote = "Zenda"
  data[2,]$MP_Constituency.local = "Zembla"
  expected <- rep(FALSE, 2)
  actual <- sapply(1:2, function(x) testConstituencies(data[x,]))
  expect_equal(actual, expected)
})

context("areRemoteAndLocalEqual")

test_that("reports all equal when all are equal", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  expected <- sapply(1:nrow(data), function(x) rep(TRUE, 7))
  actual <- sapply(1:nrow(data), function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when MP doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Question_MP.remote <- "Feargal Sharkey"
  data[2,]$Question_MP.local <- "Madonna"
  expected <- sapply(1:2, function(x) c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Question date doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Question_Date.remote <- "25/12/45"
  data[2,]$Question_Date.local <- "11/11/18"
  expected <- sapply(1:2, function(x) c(TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Question text doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Question_Text.remote <- "Where are the Snowdens of yesteryear?"
  data[2,]$Question_Text.local <- "What is the sound of one hand clapping?"
  expected <- sapply(1:2, function(x) c(TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Answer MP doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Answer_MP.remote <- "Pablo Escobar"
  data[2,]$Answer_MP.local <- "Shakira"
  expected <- sapply(1:2, function(x) c(TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Answer test doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Answer_Text.remote <- "How many fingers am I holding up?"
  data[2,]$Answer_Text.local <- "What's that got to do with the price of fish?"
  expected <- sapply(1:2, function(x) c(TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Constituency doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$MP_Constituency.remote <- "Holby"
  data[2,]$MP_Constituency.remote <- "Denton"
  expected <- sapply(1:2, function(x) c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})

test_that("reports unequal when Party doesn't match", {
  data <- read.csv("./examples/data/TestQsData.csv", stringsAsFactors = FALSE)
  data[1,]$Party.remote <- "Adder"
  data[2,]$Party.local <- "Keep Royalty White, Rat Catching And Safe Sewage Residents"
  expected <- sapply(1:2, function(x) c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE))
  actual <- sapply(1:2, function(x) areRemoteAndLocalEqual(data[x,]))
  row.names(expected) <- row.names(actual)
  expect_equal(actual, expected)
})