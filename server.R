library(shiny)
library(curl)
library(rCharts)

coeDat <- read.csv( curl("https://raw.githubusercontent.com/elginlye/DataProdProj9/master/COE%20data.csv") )
#coeDat<- read.csv("COE data.csv")

## Clean data
# Only use data since the advent of bi-monthy open bidding, Apr-2002
coeDat = subset(coeDat, grepl("T[12]", coeDat$MONTH))

# Create new column DATE out of YEAR & MONTH
coeDat["DATE"] = paste0(coeDat$YEAR, "-",coeDat$MONTH)

# Impute bi-weekly bids to 1st and 15th respectively
coeDat$DATE = gsub(".T1", "-01", coeDat$DATE)
coeDat$DATE = gsub(".T2", "-15", coeDat$DATE)

# Replace 2001-1-Dec with 2001-Dec-1
coeDat$DATE = gsub("-([0-9])-([A-Z][a-z].)$", "-\\2-\\1", coeDat$DATE)

# Replace 2001-Apr with 2001-Apr-01
coeDat$DATE = gsub("([a-z])$", "\\1-01", coeDat$DATE)

# Replace 2000-Apr-00  with 2000-Apr-01
coeDat$DATE = gsub("00$", "01", coeDat$DATE)

# Replace 2000-Apr-00  with 2000-Apr-01
coeDat$DATE = gsub("99$", "01", coeDat$DATE)

# remove comma thousand separator from number fields
coeDat$CAT.A = as.numeric(gsub(",", "", coeDat$CAT.A))
coeDat$CAT.B = as.numeric(gsub(",", "", coeDat$CAT.B))
coeDat$CAT.C = as.numeric(gsub(",", "", coeDat$CAT.C))
coeDat$CAT.D = as.numeric(gsub(",", "", coeDat$CAT.D))
coeDat$CAT.E = as.numeric(gsub(",", "", coeDat$CAT.E))
coeDat$CAT.A.QUOTA = as.numeric(gsub(",", "", coeDat$CAT.A.QUOTA))
coeDat$CAT.A.BIDS.RECV = as.numeric(gsub(",", "", coeDat$CAT.A.BIDS.RECV))

# reformat date fields
coeDat$DATE = as.Date(coeDat$DATE, "%Y-%b-%d")

# Only use data since the advent of bi-monthy open bidding, Apr-2002
coeDat = coeDat[coeDat$DATE >= "2002-04-01",]

# Simulate data for the COE Categories B-E due to lack of time to gather raw data.
set.seed(1234)
coeDat$CAT.B.QUOTA = sample(100:1000, nrow(coeDat))
coeDat$CAT.C.QUOTA = sample(100:1000, nrow(coeDat))
coeDat$CAT.D.QUOTA = sample(100:1000, nrow(coeDat))
coeDat$CAT.E.QUOTA = sample(100:1000, nrow(coeDat))
coeDat$CAT.B.BIDS.RECV = sample(100:1000, nrow(coeDat))
coeDat$CAT.C.BIDS.RECV = sample(100:1000, nrow(coeDat))
coeDat$CAT.D.BIDS.RECV = sample(100:1000, nrow(coeDat))
coeDat$CAT.E.BIDS.RECV = sample(100:1000, nrow(coeDat))

# Save cleaned dataset
##write.csv(coeDat,file = "Cleaned COE data.csv", row.names = FALSE)

predictCOE <- function(category) {
    switch(category,
        A = (fit <- lm(CAT.A ~ CAT.A.BIDS.RECV + CAT.A.QUOTA, data=coeDat)),
        B = (fit <- lm(CAT.B ~ CAT.B.BIDS.RECV + CAT.B.QUOTA, data=coeDat)), 
        C = (fit <- lm(CAT.C ~ CAT.C.BIDS.RECV + CAT.C.QUOTA, data=coeDat)), 
        D = (fit <- lm(CAT.D ~ CAT.D.BIDS.RECV + CAT.D.QUOTA, data=coeDat)), 
        E = (fit <- lm(CAT.E ~ CAT.E.BIDS.RECV + CAT.E.QUOTA, data=coeDat)), 
    )
    fit
}

plotChart <- function(coeCat, dateRange) {
    switch(coeCat,
           A = plot(CAT.A ~ DATE, type="l", data=subset(coeDat, DATE >= dateRange[1] & DATE <= dateRange[2]) ),
           B = plot(CAT.B ~ DATE, type="l", data=subset(coeDat, DATE >= dateRange[1] & DATE <= dateRange[2]) ),
           C = plot(CAT.C ~ DATE, type="l", data=subset(coeDat, DATE >= dateRange[1] & DATE <= dateRange[2]) ),
           D = plot(CAT.D ~ DATE, type="l", data=subset(coeDat, DATE >= dateRange[1] & DATE <= dateRange[2]) ),
           E = plot(CAT.E ~ DATE, type="l", data=subset(coeDat, DATE >= dateRange[1] & DATE <= dateRange[2]) )
    )
}



shinyServer(
  function(input, output) {

    output$COEDataTable = renderDataTable( 
        {
            showColumns =  c("DATE", grep(paste0("CAT.", input$coeCatInput), names(coeDat), value = TRUE))
            coeDat[ coeDat$DATE <= input$dateRange[2] & coeDat$DATE >= input$dateRange[1], showColumns]
        }
    )
    
    
    
    output$dataSummary = renderPrint( 
        {
            showColumns =  c("DATE", grep(paste0("CAT.", input$coeCatInput), names(coeDat), value = TRUE))
            summary(coeDat[coeDat$DATE <= input$dateRange[2] & coeDat$DATE >= input$dateRange[1], showColumns])
            
        } 
    )
    
    
    output$aboutCOE = renderPrint("https://www.lta.gov.sg/content/ltaweb/en/publications-and-research.html")

    output$modelFit =  renderPrint( 
        {
            fit <- predictCOE(input$coeCatInput)
            summary(fit)
        } 
    )
    
    
    output$graph <- renderPlot(
        {
            plotChart(input$coeCatInput, input$dateRange)

        }
    )
    
  }
)
