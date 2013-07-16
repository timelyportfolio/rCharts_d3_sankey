---
title: Sankey from Scratch
author: Timely Portfolio
github: {user: timelyportfolio, repo: rCharts_d3_horizon, branch: "gh-pages"}
framework: bootstrap
mode: selfcontained
highlighter: prettify
hitheme: twitter-bootstrap
widgets: "d3_sankey"
assets:
  css:
    - "http://fonts.googleapis.com/css?family=Raleway:300"
    - "http://fonts.googleapis.com/css?family=Oxygen"
---

<style>
.container { width: 1000px; }

body{
  font-family: 'Oxygen', sans-serif;
  font-size: 16px;
  line-height: 24px;
}

h1,h2,h3,h4 {
  font-family: 'Raleway', sans-serif;
}

h3 {
  background-color: #D4DAEC;
  text-indent: 100px; 
}

h4 {
  text-indent: 100px;
}
</style>

<a href="https://github.com/timelyportfolio/rCharts_d3_sankey"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png" alt="Fork me on GitHub"></a>



# Sankey from Scratch using `rCharts`, `d3.js`, and `igraph`

## Introduction

This example will walk through the steps of using the `R` package [`igraph`](http://igraph.sourceforge.net/) to create a tree network for a [sankey diagram](http://econ.st/JwNX8s).  This is a great exercise to learn some basics of `igraph`, explore the construction of a sankey, and determine the conditions for a network to be drawn properly as a sankey. After all of this, we will plot our network with the [`rCharts`](http://rcharts.io/site) implementation of the [d3.js sankey plugin](https://github.com/d3/d3-plugins/blob/master/sankey/sankey.js).


## Build a Network
Let's first start by loading the `igraph` and `rCharts` packages.  Then we will use `graph.tree` to build a tree network with 40 vertices with 4 children.

```r
require(igraph)
require(rCharts)

g <- graph.tree(40, children = 4)
```

For fun, we will assign a weight of 1 `E(g)$weight = 1` for each edge and then draw a Sankey diagram using `rCharts`.  Going forward I will try to explain the `R` code through comments in the code block.

## Plot Our Sankey to Find a Problem

```r
E(g)$weight = 1

edgelist <- get.data.frame(g) #this will give us a data frame with from,to,weight
colnames(edgelist) <- c("source","target","value")
#make character rather than numeric for proper functioning
edgelist$source <- as.character(edgelist$source)
edgelist$target <- as.character(edgelist$target)

sankeyPlot <- rCharts$new()
sankeyPlot$setLib('libraries/widgets/d3_sankey')
sankeyPlot$setTemplate(script = "libraries/widgets/d3_sankey/layouts/chart.html")

sankeyPlot$set(
  data = edgelist,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot$print(chartId = 'sankey1')
```


<div id='sankey1' class='rChart d3_sankey'></div>
<!--Attribution:
Mike Bostock https://github.com/d3/d3-plugins/tree/master/sankey
Mike Bostock http://bost.ocks.org/mike/sankey/
-->

<script>
var params = {
 "dom": "sankey1",
"width":    960,
"height":    500,
"data": {
 "source": [ "1", "1", "1", "1", "2", "2", "2", "2", "3", "3", "3", "3", "4", "4", "4", "4", "5", "5", "5", "5", "6", "6", "6", "6", "7", "7", "7", "7", "8", "8", "8", "8", "9", "9", "9", "9", "10", "10", "10" ],
"target": [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40" ],
"value": [      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1,      1 ] 
},
"nodeWidth":     15,
"nodePadding":     10,
"layout":     32,
"id": "sankey1" 
};

params.units ? units = " " + params.units : units = "";

//hard code these now but eventually make available
var formatNumber = d3.format("0,.0f"),    // zero decimal places
    format = function(d) { return formatNumber(d) + units; },
    color = d3.scale.category20();

var svg = d3.select('#' + params.id).append("svg")
    .attr("width", params.width)
    .attr("height", params.height);
    
var sankey = d3.sankey()
    .nodeWidth(params.nodeWidth)
    .nodePadding(params.nodePadding)
    .layout(params.layout)
    .size([params.width,params.height]);
    
var path = sankey.link();
    
var data = params.data,
    links = [],
    nodes = [];
    
//get all source and target into nodes
//will reduce to unique in the next step
//also get links in object form
data.source.forEach(function (d, i) {
    nodes.push({ "name": data.source[i] });
    nodes.push({ "name": data.target[i] });
    links.push({ "source": data.source[i], "target": data.target[i], "value": +data.value[i] });
}); 

//now get nodes based on links data
//thanks Mike Bostock https://groups.google.com/d/msg/d3-js/pl297cFtIQk/Eso4q_eBu1IJ
//this handy little function returns only the distinct / unique nodes
nodes = d3.keys(d3.nest()
                .key(function (d) { return d.name; })
                .map(nodes));

//it appears d3 with force layout wants a numeric source and target
//so loop through each link replacing the text with its index from node
links.forEach(function (d, i) {
    links[i].source = nodes.indexOf(links[i].source);
    links[i].target = nodes.indexOf(links[i].target);
});

//now loop through each nodes to make nodes an array of objects rather than an array of strings
nodes.forEach(function (d, i) {
    nodes[i] = { "name": d };
});

sankey
  .nodes(nodes)
  .links(links)
  .layout(params.layout);
  
var link = svg.append("g").selectAll(".link")
  .data(links)
.enter().append("path")
  .attr("class", "link")
  .attr("d", path)
  .style("stroke-width", function (d) { return Math.max(1, d.dy); })
  .sort(function (a, b) { return b.dy - a.dy; });

link.append("title")
  .text(function (d) { return d.source.name + " → " + d.target.name + "\n" + format(d.value); });

var node = svg.append("g").selectAll(".node")
  .data(nodes)
.enter().append("g")
  .attr("class", "node")
  .attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; })
.call(d3.behavior.drag()
  .origin(function (d) { return d; })
  .on("dragstart", function () { this.parentNode.appendChild(this); })
  .on("drag", dragmove));

node.append("rect")
  .attr("height", function (d) { return d.dy; })
  .attr("width", sankey.nodeWidth())
  .style("fill", function (d) { return d.color = color(d.name.replace(/ .*/, "")); })
  .style("stroke", function (d) { return d3.rgb(d.color).darker(2); })
.append("title")
  .text(function (d) { return d.name + "\n" + format(d.value); });

node.append("text")
  .attr("x", -6)
  .attr("y", function (d) { return d.dy / 2; })
  .attr("dy", ".35em")
  .attr("text-anchor", "end")
  .attr("transform", null)
  .text(function (d) { return d.name; })
.filter(function (d) { return d.x < params.width / 2; })
  .attr("x", 6 + sankey.nodeWidth())
  .attr("text-anchor", "start");

// the function for moving the nodes
  function dragmove(d) {
    d3.select(this).attr("transform", 
        "translate(" + (
                   d.x = Math.max(0, Math.min(params.width - d.dx, d3.event.x))
                ) + "," + (
                   d.y = Math.max(0, Math.min(params.height - d.dy, d3.event.y))
                ) + ")");
        sankey.relayout();
        link.attr("d", path);
  }
</script>


Interact with the sankey plot a little, and try to find the problem in our hastily constructed network.  Hovering over the vertex 4 will reveal our issue.  The edge from 1 to 4 is not as big as the sum of the edges going out from 4.  For this to make sense, unless 4 is magically creating something, the sum of the inflow should equal the sum of the outflow.  Since 4 has four children each with weight of 1 (outflow = 1 + 1 + 1 + 1 = 4), we would expect the inflow to also be 4.  It is only 1 though since we made all our edges' weights = 1 `E(g)$weight = 1`.  How then would we build our network with edge weights so that for each vertex, the sum of in equals the sum of out.


## Fix Our Problem For a Beautiful Sankey
I am a network novice, so while the code below works, I am sure there are better ways of accomplishing the desired result.  I heavily commented the code, but I will quickly describe the steps.  The code starts at the lowest level of the heirarchy, or those vertexes where there is nothing going out (out degree = 0).  In our network, these are 11 through 40.  With `igraph` we can identify these by `V(g2)[degree(g2,mode="out")==0]`.  For these we will assign a weight.  Then we will loop through all of the edges summing all of the weights of the out until we have reached the top of the heirarchy.


```r
g2 <- graph.tree(40, children=4)
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

edgelistWeight <- get.data.frame(g2)
colnames(edgelistWeight) <- c("source","target","value")
edgelistWeight$source <- as.character(edgelistWeight$source)
edgelistWeight$target <- as.character(edgelistWeight$target)

sankeyPlot2 <- rCharts$new()
sankeyPlot2$setLib('libraries/widgets/d3_sankey')
sankeyPlot2$setTemplate(script = 'libraries/widgets/d3_sankey/layouts/chart.html')

sankeyPlot2$set(
  data = edgelistWeight,
  nodeWidth = 15,
  nodePadding = 10,
  layout = 32,
  width = 960,
  height = 500
)

sankeyPlot2
```


<div id='chart259034a337d4' class='rChart d3_sankey'></div>
<!--Attribution:
Mike Bostock https://github.com/d3/d3-plugins/tree/master/sankey
Mike Bostock http://bost.ocks.org/mike/sankey/
-->

<script>
var params = {
 "dom": "chart259034a337d4",
"width":    960,
"height":    500,
"data": {
 "source": [ "1", "1", "1", "1", "2", "2", "2", "2", "3", "3", "3", "3", "4", "4", "4", "4", "5", "5", "5", "5", "6", "6", "6", "6", "7", "7", "7", "7", "8", "8", "8", "8", "9", "9", "9", "9", "10", "10", "10" ],
"target": [ "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40" ],
"value": [ 874.48, 238.62, 221.13, 174.37, 264.52,  255.6, 184.57, 169.79, 67.403, 65.402, 56.484, 49.336, 64.096, 26.709, 95.646, 34.677, 8.9458, 24.742, 42.608, 98.078, 85.809, 19.168, 76.699, 82.846, 88.469, 50.828, 37.553, 78.749, 64.682, 52.582,  46.97, 20.331, 22.229,   46.3, 1.8179, 99.445,  24.56, 7.6854, 35.158 ] 
},
"nodeWidth":     15,
"nodePadding":     10,
"layout":     32,
"id": "chart259034a337d4" 
};

params.units ? units = " " + params.units : units = "";

//hard code these now but eventually make available
var formatNumber = d3.format("0,.0f"),    // zero decimal places
    format = function(d) { return formatNumber(d) + units; },
    color = d3.scale.category20();

var svg = d3.select('#' + params.id).append("svg")
    .attr("width", params.width)
    .attr("height", params.height);
    
var sankey = d3.sankey()
    .nodeWidth(params.nodeWidth)
    .nodePadding(params.nodePadding)
    .layout(params.layout)
    .size([params.width,params.height]);
    
var path = sankey.link();
    
var data = params.data,
    links = [],
    nodes = [];
    
//get all source and target into nodes
//will reduce to unique in the next step
//also get links in object form
data.source.forEach(function (d, i) {
    nodes.push({ "name": data.source[i] });
    nodes.push({ "name": data.target[i] });
    links.push({ "source": data.source[i], "target": data.target[i], "value": +data.value[i] });
}); 

//now get nodes based on links data
//thanks Mike Bostock https://groups.google.com/d/msg/d3-js/pl297cFtIQk/Eso4q_eBu1IJ
//this handy little function returns only the distinct / unique nodes
nodes = d3.keys(d3.nest()
                .key(function (d) { return d.name; })
                .map(nodes));

//it appears d3 with force layout wants a numeric source and target
//so loop through each link replacing the text with its index from node
links.forEach(function (d, i) {
    links[i].source = nodes.indexOf(links[i].source);
    links[i].target = nodes.indexOf(links[i].target);
});

//now loop through each nodes to make nodes an array of objects rather than an array of strings
nodes.forEach(function (d, i) {
    nodes[i] = { "name": d };
});

sankey
  .nodes(nodes)
  .links(links)
  .layout(params.layout);
  
var link = svg.append("g").selectAll(".link")
  .data(links)
.enter().append("path")
  .attr("class", "link")
  .attr("d", path)
  .style("stroke-width", function (d) { return Math.max(1, d.dy); })
  .sort(function (a, b) { return b.dy - a.dy; });

link.append("title")
  .text(function (d) { return d.source.name + " → " + d.target.name + "\n" + format(d.value); });

var node = svg.append("g").selectAll(".node")
  .data(nodes)
.enter().append("g")
  .attr("class", "node")
  .attr("transform", function (d) { return "translate(" + d.x + "," + d.y + ")"; })
.call(d3.behavior.drag()
  .origin(function (d) { return d; })
  .on("dragstart", function () { this.parentNode.appendChild(this); })
  .on("drag", dragmove));

node.append("rect")
  .attr("height", function (d) { return d.dy; })
  .attr("width", sankey.nodeWidth())
  .style("fill", function (d) { return d.color = color(d.name.replace(/ .*/, "")); })
  .style("stroke", function (d) { return d3.rgb(d.color).darker(2); })
.append("title")
  .text(function (d) { return d.name + "\n" + format(d.value); });

node.append("text")
  .attr("x", -6)
  .attr("y", function (d) { return d.dy / 2; })
  .attr("dy", ".35em")
  .attr("text-anchor", "end")
  .attr("transform", null)
  .text(function (d) { return d.name; })
.filter(function (d) { return d.x < params.width / 2; })
  .attr("x", 6 + sankey.nodeWidth())
  .attr("text-anchor", "start");

// the function for moving the nodes
  function dragmove(d) {
    d3.select(this).attr("transform", 
        "translate(" + (
                   d.x = Math.max(0, Math.min(params.width - d.dx, d3.event.x))
                ) + "," + (
                   d.y = Math.max(0, Math.min(params.height - d.dy, d3.event.y))
                ) + ")");
        sankey.relayout();
        link.attr("d", path);
  }
</script>


## Another Look at Our Network
There are very [good examples](http://rulesofreason.wordpress.com/tag/plot-igraph/) illustrating the use of `igraph` to plot a network.  This is not one of these examples.  For fun though, let's plot the network with igraph using just the defaults to compare it to our Sankey output from above.


```r
plot(g2)
```

![plot of chunk unnamed-chunk-5](assets/fig/unnamed-chunk-5.png) 


## Lots More Sankey
Believe it or not, there is an entire site devoted to sankey diagrams.  For all the sankey you can handle, check out http://sankey-diagrams.com.  Here are a couple more sankeys generated from `rCharts`:  http://rcharts.io/viewer/?6001601#.UeWfuY3VCSo, http://rcharts.io/viewer/?6003605, http://rcharts.io/viewer/?6003575.
