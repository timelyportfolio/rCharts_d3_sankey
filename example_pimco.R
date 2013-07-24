#sankey of PIMCO All Asset All Authority holdings
#data source http://investments.pimco.com/ShareholderCommunications/External%20Documents/PIMCO%20Bond%20Stats.xls

require(rCharts)

#originally read the data from clipboard of Excel copy
#for those interested here is how to do it
#read.delim(file = "clipboard")

holdings = read.delim("http://timelyportfolio.github.io/rCharts_d3_sankey/holdings.txt", skip = 3, header = FALSE, stringsAsFactors = FALSE)
colnames(holdings) <- c("source","target","value")

#get rid of holdings with 0 weight or since copy/paste from Excel -
holdings <- holdings[-which(holdings$value == "-"),]
holdings$value <- as.numeric(holdings$value)

#now we finally have the data in the form we need
sankeyPlot <- rCharts$new()
sankeyPlot$setLib('http://timelyportfolio.github.io/rCharts_d3_sankey')

sankeyPlot$set(
  data = holdings,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 750,
  height = 500,
  labelFormat = ".1%"
)

sankeyPlot