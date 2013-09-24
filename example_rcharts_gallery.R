require(rCharts)
require(plyr)

gallery <- read.csv(
  "https://docs.google.com/spreadsheet/pub?key=0AovoNzJt5GetdEhQVDgyYXpJMnZ2M2J2YmtvX0I5Snc&output=csv",
  stringsAsFactors = FALSE
)

gallery.use <- gallery[,c("technology","visualizationType","documentType","author")]
colnames(gallery.use) <- rep("column",4)

gallery.edge <- rbind(
  gallery.use[,1:2],
  gallery.use[,2:3],
  gallery.use[,3:4],
  deparse.level=1
)

colnames(gallery.edge) <- c("source","target")

gallery.edge <- ddply(gallery.edge,~source+target,nrow)

colnames(gallery.edge) <- c("source","target","value")

#verify that no source = target
#or will get stuck in infinite loop
gallery.edge[which(gallery.edge[,1]==gallery.edge[,2]),]



gallery.edge$source <- as.character(gallery.edge$source)
gallery.edge$target <- as.character(gallery.edge$target)
sankeyPlot2 <- rCharts$new()
sankeyPlot2$setLib('http://timelyportfolio.github.io/rCharts_d3_sankey/')
sankeyPlot2$set(
  data = gallery.edge,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)
sankeyPlot2