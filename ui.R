shinyUI(fluidPage(
  column(1),
  column(10,
    h2("Ewing Family Hikes"),
    column(3,
      shiny::selectInput("hikeID","Select a Hike",unique(hikingData$Hike),selected = "Chilkoot Trail (2016)"),
      shiny::selectInput("dayID","Select Days",unique(hikingData$Day[hikingData$Hike == "Chilkoot Trail (2016)"]),multiple = T),
      hr(),
      plotOutput("elevPlot",height=250)
    ),
    column(9,
      tabsetPanel(
        tabPanel("Map",
          leafletOutput("bigMap",height=600)
        ),
        tabPanel("Speed/Elevation Plot",
          plotlyOutput("overlayPlot")
        )
      )
    )
  ),
  column(1)
))
