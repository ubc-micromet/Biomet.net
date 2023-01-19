# Figure for assessing offset between measured incoming radiation and potential radiation
# By Sara Knox
# Created Oct 28, 2022

PPFDIN_vs_potential_rad <-
  function(data) {
    
    p2 <- ggplot() +
      geom_point(data = data, aes(x = time, y = potential_radiation*2.5), color = "red",size = 0.5) +
      geom_point(data = data, aes(x = time, y = PPFD_IN), color = "darkcyan",linetype="dashed",size = 0.5) +
      scale_x_datetime(date_labels = "%H")+ylab("PPDF_IN & scaled pot rad (umol m-2 s-1)")+xlab("")
    
    p2 <- ggplotly(p2+ facet_wrap(~as.factor(firstdate))) %>% toWebGL()
    p2
    
    return(toWebGL(ggplotly(p2))) 
  }
