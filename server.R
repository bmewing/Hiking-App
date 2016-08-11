shinyServer(function(input, output,session) {
  
  observeEvent(input$hikeID,{
    updateSelectInput(session,inputId = "dayID",choices = unique(thisHike0()$Day))
  })
  
  pictures = reactive({
    p = read_excel("img/pictureDB.xlsx")%>% 
      filter(Hike == input$hikeID)
    if(!is.null(input$dayID)){
      p %<>% filter(Day %in% input$dayID)
    }
    p %>% 
      mutate(Content = sprintf('<a href="%s"><img src="%s" width="100%%" height="100%%"></a><br>Photo taken on %s',Picture,Picture,format(Timestamp,format="%B%e, %Y %I:%M %p")))
  })
   
  thisHike0 = reactive({
    hikingData %>% 
      filter(Hike == input$hikeID) %>% 
      mutate(Timestamp = as.POSIXct(as.numeric(Timestamp),tz=.$Timezone[1],origin="1970-01-01"))
  })
  
  thisHike = reactive({
    h = thisHike0()
    if(!is.null(input$dayID)){
      h %<>% filter(Day %in% input$dayID)
    }
    h
  })
  
  output$bigMap = renderLeaflet({
    req(nrow(thisHike()) > 0)
    colors = c('red','blue','orange','purple','green','yellow')
    
    map = leaflet() %>% 
      addTiles(group = "Standard") %>% 
      addProviderTiles("Thunderforest.Landscape", group = "Topographical") %>% 
      addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
      addLayersControl(position='bottomright',
        baseGroups = c("Standard","Topograpical","Satellite"),
        overlayGroups = c("Daily Progress"),
        options = layersControlOptions(collapsed=F)) %>% 
      addLegend(position = 'bottomright',opacity = 0.4,
        colors = colors[1:length(unique(thisHike()$Day))],
        labels = unique(thisHike()$Day),
        title = 'Daily Progress')
    
    for(i in seq_along(unique(thisHike()$Day))){
      dtf = unique(thisHike()$Day)[i]
      map %<>%
        addPolylines(data=thisHike() %>% dplyr::filter(Day == dtf),color = colors[i],lng=~Longitude,lat=~Latitude,group='Daily Progress')
    }

    if(nrow(pictures()) > 0){
      photoIcon <- makeIcon(
        iconAnchorX = 12, iconAnchorY = 12, # center middle of icon on track,
        # instead of top corner  
        iconUrl = "img/camera_icon_small.gif"
      )
      map %<>% addMarkers(lng=pictures()$Longitude,lat=pictures()$Latitude,group="Photos",popup=pictures()$Content,icon = photoIcon)
    }
    
    map
  })
  
  output$elevPlot = renderPlot({
    hd = thisHike0()
    hd$dist[is.na(hd$dist)] = 0
    hd %<>%
      mutate(dist = cumsum(dist))
    
    plot(hd$Elevation~hd$dist,type='l',ylab="Elevation (ft)",xlab="Distance (mi)",col='blue',main="Hike Elevation")
  })
  
  output$overlayPlot = renderPlotly({
    hd = thisHike()
    hd$dist[is.na(hd$dist)] = 0
    hd %<>%
      mutate(dist = cumsum(dist)) %>% 
      group_by(Timestamp) %>% 
      mutate(maxDist = max(dist)) %>% 
      ungroup() %>% 
      filter(dist == maxDist) %>% 
      mutate(distTraveled = dist-lag(dist)) %>% 
      mutate(timeTraveled = as.numeric(Timestamp - lag(Timestamp))) %>% 
      mutate(speed = distTraveled/timeTraveled*60*60)
    hd$speed[is.na(hd$speed)] = 0
    
    smoother = loess(speed~dist,data=hd,span = 0.1)
    hd$`Speed (mph)` = predict(smoother,hd$dist)
    hd$`Distance (mi)` = hd$dist
    hd$`Elevation (ft)` = hd$Elevation
    
    ay = list(overlaying = "y",side="right")
    plot_ly(data=hd,x=`Distance (mi)`,y=`Speed (mph)`,name="Average Speed (mph)") %>% 
      add_trace(x = `Distance (mi)`,y = `Elevation (ft)`,name="Elevation (ft)",yaxis="y2") %>% 
      layout(yaxis2=ay)
  })
})
