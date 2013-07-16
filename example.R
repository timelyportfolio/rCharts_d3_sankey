require(rCharts)
require(rjson)
require(igraph)

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





















data(foodwebs, package = "igraphdata")
data(karate, package = "igraphdata")
data(Koenigsberg, package = "igraphdata")
edgelist <- get.data.frame(foodwebs$ChesLower)

#simulate a network
g <- graph.tree(26,children=2)
edgelist <- get.data.frame(g)
edgelist$value <- 1
colnames(edgelist) <- c("source","target","value")
edgelist$source <- LETTERS[edgelist$source]
edgelist$target <- LETTERS[edgelist$target]

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


g2 <- graph.tree(40,children=4)
#to construct a sankey the weight of each vertex should be the sum
#of its outgoing edges
#I believe the first step in creating a network that satisfies this condition
#is define a vertex weight for all vertexes with out degree = 0
#but first let's define 0 for all
V(g2)$weight = 0
#now for all vertexes with out degree = 0
V(g2)[degree(g2,mode="out")==0]$weight <- runif(n=length(V(g2)[degree(g2,mode="out")==0]),min=0,max=100)
#the lowest level of the heirarchy is defined with a random weight
#with the lowest level defined we should now be able to sum the vertex weights
#to define the edge weight
#E(g2)$weight = 0.1 #define all weights small to visually see as we build sankey
E(g2)[to(V(g2)$weight>0)]$weight <- V(g2)[V(g2)$weight>0]$weight
#and to find the neighbors to the 0 out degree vertex
#we could do V(g2)[nei(degree(g2,mode="out")==0)]
#we have everything we need to build the rest by summing
#these edge weights if there are edges still undefined
#so set up a loop to run until all edges have a defined weight
while(max(is.na(E(g2)$weight))) {
  #get.data.frame gives us from, to, and weight
  #we will get this to make an easier reference later
  df <- get.data.frame(g2)
  #now go through each edge and find the sum of all its subedges
  #we need to check to make sure out degree of its "to" vertex is not 0
  #or we will get 0 since there are no edges for vertex with out degree 0
  for (i in 1:nrow(df)) {
    x = df[i,]
    #sum only those with out degree > 0 or sum will be 0
    if(max(df$from==x$to)) {
      E(g2)[from(x$from) & to(x$to)]$weight = sum(E(g2)[from(x$to)]$weight)
    }
  }
}


#just a quick check on the adjacency
get.adjacency(g2,sparse = FALSE,attr="weight")




#E(g2)$weight <- runif(length(E(g2)))
edgelistWeight <- get.data.frame(g2)
colnames(edgelistWeight) <- c("source","target","value")
edgelistWeight$source <- as.character(edgelistWeight$source)
edgelistWeight$target <- as.character(edgelistWeight$target)

sankeyPlot2 <- rCharts$new()
sankeyPlot2$setLib('.')
sankeyPlot2$setTemplate(script = "layouts/chart.html")

sankeyPlot2$set(
  data = edgelistWeight,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot2



data(pHWebs, package = "cheddar")

community <- pHWebs[[1]]$trophic.links
community$value <- 1
colnames(community) <- c("source","target", "value")
community$source <- paste0(community$source,"[resource]")

sankeyPlot <- rCharts$new()
sankeyPlot$setLib('.')
sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = community,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot





data(Millstream, package = "cheddar")

community <- pHWebs[[1]]$trophic.links
community$value <- 1
colnames(community) <- c("source","target", "value")
community$source <- paste0(community$source,"[resource]")

sankeyPlot <- rCharts$new()
sankeyPlot$setLib('.')
sankeyPlot$setTemplate(script = "layouts/chart.html")

sankeyPlot$set(
  data = community,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot











 ToIgraph <- function(community, weight=NULL)
{
  if(is.null(TLPS(community)))
  {
    stop('The community has no trophic links')
  }
  else
  {
    tlps <- TLPS(community, link.properties=weight)
    if(!is.null(weight))
    {
      tlps$weight <- tlps[,weight]
    }
    return (graph.data.frame(tlps,
                             vertices=NPS(community),
                             directed=TRUE))
  }
}
 data(TL84)
 # Unweighted network
   TL84.ig <- ToIgraph(TL84)

edgelist <- data.frame(get.edgelist(TL84.ig),stringsAsFactors = FALSE)
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



graph.edgelist(as.matrix(edgelist)[,1:2],directed = TRUE)
g <- graph.edgelist(as.matrix(edgelist)[,1:2],directed = TRUE)
a <- get.adjacency(g)







edgelist <- get.data.frame(as.undirected(erdos.renyi.game(n=20,p.or.m=.5,type="gnp",directed=T),mode="collapse"))
edgelist$value <- 1
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