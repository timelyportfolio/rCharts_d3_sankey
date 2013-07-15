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
  width = 700,
  height = 400
)

sankeyPlot
