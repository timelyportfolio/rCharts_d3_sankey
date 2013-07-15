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



#http://schoolofdata.org/2013/02/20/made-to-measure-reshaping-horsemeat-importexport-data-to-fit-a-sankey-diagram/
require(reshape)
horseexportsEU <- read.delim(
  "https://dl.dropbox.com/u/1156404/horseexportsEU.txt"
)
#Get a "long" edge list from the 2d data table 
x=melt(horseexportsEU,id='COUNTRY')

# When is what looks like a number to us not a number?
#Turn the numbers into numbers by removing the comma, then casting to an integer 
x$value2=as.integer(as.character(gsub(",", "", x$value, fixed = TRUE) ))

#More tidying...
#1) If we have an NA (null/empty) value, make it -1 
x$value2[ is.na(x$value2) ] = -1 
#2) Column names with countries that originally contained spaces uses dots in place of spaces. Undo that. 
x$variable=gsub(".", " ", x$variable, fixed = TRUE)

#I want to export a subset of the data 
xt=subset(x,value2>0,select=c('COUNTRY','variable','value2'))
#name columns as what is expected by plugin
colnames(xt) <- c("target","source","value")
#need to make names in source and target different to prevent infinite loop
xt$source <- paste0(xt$source,"[export]")


sankeyPlot <- rCharts$new()
sankeyPlot$setLib('.')
sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = xt,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot



#another one from Tony Hirst
#post at http://blog.ouseful.info/2012/05/24/f1-championship-points-as-a-d3-js-powered-sankey-diagram/
#data at https://views.scraperwiki.com/run/ergast_championship_nodelist/?
#get source from original example
#this is a JSON, so will need to translate

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
nodes[seq(1,length(nodes),by=2)]

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
  units = "points"
)

sankeyPlot














data(foodwebs, package = "igraphdata")
data(karate, package = "igraphdata")
data(Koenigsberg, package = "igraphdata")

edgelist <- data.frame(get.edgelist(Koenigsberg),stringsAsFactors = FALSE)
edgelist$value <- rep(1,nrow(edgelist))
colnames(edgelist) <- c("source","target","value")
edgelist$source <- paste0(edgelist$source,"[src]")

sankeyPlot <- rCharts$new()
sankeyPlot$setLib('.')
sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = edgelist,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot