# Figure for assessing offset between measured incoming radiation and potential radiation
# By Sara Knox
# Created Oct 28, 2022

SWIN_vs_potential_rad <-
  function(data) {
    
    p1 <- ggplot() +
      geom_point(data = data, aes(x = time, y = potential_radiation), color = "red",size = 0.5) +
      geom_point(data = data, aes(x = time, y = SW_IN), color = "steelblue",linetype="dashed",size = 0.5) +
      geom_point(data = data, aes(x = time, y = exceeds), color = "black",size = 0.75)+
      scale_x_datetime(date_labels = "%H")+ylab("SW_IN & Pot rad (W/m2)")+xlab("")
    
    p1 <- ggplotly(p1+ facet_wrap(~as.factor(firstdate))) %>% toWebGL()
    
    return(toWebGL(ggplotly(p1))) 
  }