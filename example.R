require(rCharts)
require(rjson)

#get source from original example
#this is a JSON, so will need to translate
#this is complicated and unnecessary but feel I need to replicate
#for completeness

#expect most data to come straight from R
#in form of source, target, value

links <- matrix(unlist(
  rjson::fromJSON(
    file = "http://bost.ocks.org/mike/sankey/energy.json"
  )$links
),ncol = 3, byrow = TRUE)

nodes <- unlist(
  rjson::fromJSON(
    file = "http://bost.ocks.org/mike/sankey/energy.json"
  )$nodes
)

#convert to data.frame so souce and target can be character and value numeric
links <- data.frame(links)
colnames(links) <- c("source", "target", "value")
links$source <- sapply(links$source, FUN = function(x) {return(as.character(nodes[x+1]))}) #x+1 since js starts at 0
links$target <- sapply(links$target, FUN = function(x) {return(nodes[x+1])}) #x+1 since js starts at 0


#now we finally have the data in the form we need
sankeyPlot <- rCharts$new()
sankeyPlot$setLib('.')
sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = links,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500,
  units = "TWh",
  title = "Sankey Diagram"
)

sankeyPlot