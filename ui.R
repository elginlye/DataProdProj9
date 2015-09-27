library(shiny)

# Define UI for dataset viewer application
shinyUI(
    navbarPage("Navbar---|",
               tabPanel("Plot",
                        sidebarLayout(
                            sidebarPanel(
                                p("COE analyzer is a data product to study & predict COE price trends. Certificate of Entitlement(abbrv COE) is Singapore's policy tool to manage motor vehicle population growth. One has to bid for a COE and register it together with a new car; used cars are sold together with the registered COE. Motor vehicles are categorized into 5 COE categories."),
                                
                                p('Pick a COE category & specify date range to view price trends.'),
                                p('View the  data in "Data Table" tab'),
                                
                                radioButtons("coeCatInput", "COE Category",
                                             c("A, CAR UP TO 1600CC & 97KW" ="A", 
                                               "B, CAR ABOVE 1600CC OR 97KW" = "B", 
                                               "C, GOODS VEHICLE & BUS" = "C",	
                                               "D, MOTORCYCLE" = "D",
                                               "E, OPEN" = "E")
                                ),
                                
                                dateRangeInput("dateRange", "Date range:",
                                               start  = "2002-04-01",
                                               end    = Sys.Date(),
                                               min    = "2002-04-01",
                                               max    = Sys.Date(),
                                               format = "yyyy-M",
                                               separator = " - ")

                            ),
                            mainPanel(
                                plotOutput("graph"),
                                p('Summary statistics for the specified data range'),
                                verbatimTextOutput("dataSummary"),
                                p('Note: Quota & Bids Received data are simulated for CAT B,C,D,E.')
                            )
                            
                            
                        )
               ),
               
               tabPanel("Linear Regression Analysis",
                        verbatimTextOutput("modelFit")
               ),
               
               
               tabPanel("Data Table",
                        dataTableOutput("COEDataTable")
               ),
               
               tabPanel("To Do List",
                        p('More work is required to complete this data product.'),  
                        p('1. Complete data collection for CAT B,C,D,E.'),    
                        p('2. Add variables to improve model fit (e.g. stock indices, economy forecast)'),
                        p('3. Improve plotting, current graph plots are horrendous!'),
                        p('and more...')
               ),
               
               navbarMenu("More",
                          tabPanel("About COE",
                                   p("Certificate of Entitlement (abbr COE) is a policy tool of the Singapore government to manage vehicle population growth."),
                                   p("See links below for more info"),
                                   a(href="https://en.wikipedia.org/wiki/Certificate_of_Entitlement", "COE Wikipedia")
                          ),
                          
                          tabPanel("Data sources",
                                   p("This data product uses/references data from these sources."),
                                   br(),
                                   a(href="http://www.ip-atlas.com/pub/cars/coe.htm", "COE price data Maintained by Dr. Rex Yeap"),
                                   br(),
                                   a(href="https://www.lta.gov.sg/content/ltaweb/en/publications-and-research.html", "LTA  Publications & Research, sub-sections COE Bidding Results, Quota Premium and Prevailing Quota Premium")
                          )
               )
    )
)

