#another one from Tony Hirst
#post at http://blog.ouseful.info/2012/05/24/f1-championship-points-as-a-d3-js-powered-sankey-diagram/
#data at https://views.scraperwiki.com/run/ergast_championship_nodelist/?
#get source from original example
#this is a JSON, so will need to translate

require(rCharts)

#expect most data to come straight from R
#in form of source, target, value

links <- matrix(unlist(
  rjson::fromJSON(
    file = "https://views.scraperwiki.com/run/ergast_championship_nodelist/?"
  )$links
),ncol = 3, byrow = TRUE)

nodes <- unlist(
  rjson::fromJSON(
    file = "https://views.scraperwiki.com/run/ergast_championship_nodelist/?"
  )$nodes
)

#nodes are 2 columns but in vector form
#just get the name and ignore id
nodes <- nodes[seq(1,length(nodes),by=2)]

#convert to data.frame so souce and target can be character and value numeric
links <- data.frame(links)
colnames(links) <- c("source", "target", "value")
links$source <- sapply(links$source, FUN = function(x) {return(as.character(nodes[x+1]))}) #x+1 since js starts at 0
links$target <- sapply(links$target, FUN = function(x) {return(nodes[x+1])}) #x+1 since js starts at 0


#now we finally have the data in the form we need
sankeyPlot <- rCharts$new()
#can grab from web if available
sankeyPlot$setLib('http://timelyportfolio.github.io/rCharts_d3_sankey')
#eliminate this since rCharts will auto look for chart.html
#sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = links,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 700,
  height = 400,
  units = "points"
)

sankeyPlot
