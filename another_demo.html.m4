<meta charset="utf-8">
<!-- http://cpettitt.github.io/project/dagre-d3/latest/demo/sentence-tokenization.html -->
<html>
<title>The tax graph</title>

<!--<link rel="stylesheet" href="demo.css">-->
<script src="d3.v3.js"></script>
<script src="graphlib-dot.js"></script>
<script src="dagre-d3.js"></script>

<style id="css">
/* This sets the color for user input nodes to a light blue green. */
g.u > rect {
  fill: #00ffd0;
}

text {
  font-weight: 300;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serf;
  font-size: 14px;
}

.node rect {
  stroke: #999;
  fill: #fff;
  stroke-width: 1.5px;
}

.edgePath path {
  stroke: #333;
  stroke-width: 1.5px;
}
</style>

<body>

<div id="inputname">Click on an input box to enter a dollar amount</div>
<input type="text" name="enter" class="enter" value="" id="entry"/>

<INPUT TYPE=CHECKBOX NAME="dependents" id="deps" onclick="checkbox(id, checked)">I have dependents.<BR>
<INPUT TYPE=CHECKBOX NAME="mortgage" id="mort" onclick="checkbox(id, checked)">I have a mortgage.<BR>

<svg id="svg-canvas" width=960 height=600></svg>


<script id="js">

var itemizing = 0;

m4_include(fns)


// Create the input graph
var g = new dagreD3.graphlib.Graph()
  .setGraph({})
  .setDefaultEdgeLabel(function() { return {}; });


m4_include(nodes)

var nodestorage=[]
var edgestorage=[]

var fixboxsize= function(node) {
  // Round the corners of the nodes
  node.rx = node.ry = 5;
  size = Math.sqrt(Math.max(node.val, 2000));
  node.width = size*1.818;
  node.height = size;
};

var fb2 = function(v){
    fixboxsize(g.node(v)); 
}

g.nodes().forEach(fb2);

var set_edges = function(from, toset){
    for (i in toset){
        if (toset[i]=="") return;
        g.setEdge(toset[i], from);
    }
}

// Set up edges, no special attributes.
var reedge = function(){

m4_include(edges)

}

reedge();

g.graph().rankdir="lr";

// Create the renderer
var render = new dagreD3.render();

// Set up an SVG group so that we can translate the final graph.
var svg = d3.select("svg"),
    svgGroup = svg.append("g");

// Run the renderer. This is what draws the final graph.
render(d3.select("svg g"), g);

// Center the graph
    svg.attr("width", g.graph().width + 40);
    svg.attr("height", g.graph().height + 40);
var xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
svgGroup.attr("transform", "translate(" + xCenterOffset + ", 20)");


var redrawIt = function(){
    render(d3.select("svg g"), g);
    svg.attr("width", g.graph().width + 40);
    svg.attr("height", g.graph().height + 40);
    var xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
    svgGroup.attr("transform", "translate(" + xCenterOffset + ", 20)");
}

var rm_node=function(nodes, id){
}

var input = document.getElementById("entry");
   input.addEventListener('change', function(d){
        var elmt = g._nodes[document.getElementById("inputname").className];
        elmt.val= document.getElementById("entry").value;
        fixboxsize(elmt);
        console.log(elmt.val);
        last_eval += 1;
        CV("1040_refund");
        CV("1040_tax_owed");
        redrawIt();
    });

svg.selectAll(".a_node").on('click', 
        function(d){
        document.getElementById("inputname").innerHTML=this.textContent;
        document.getElementById("inputname").className = d;
        document.getElementById("entry").value= g._nodes[d].val;
        console.log(this.textContent + g._nodes[d].val);
        redrawIt();
    });

svg.selectAll("arrowhead").style("opacity", false);

var situations = {};

var have_rr = 0;
var kids = 0;

var last_eval = 0;

function CV(name){
    console.log("eval " + name);
    this_cell = g._nodes[name];
    if (this_cell.eqn=="u") {console.log ("found "+this_cell.val + "via 'u'"); return parseFloat(this_cell.val);}
    if (this_cell.last_eval >= last_eval) {console.log ("found "+this_cell.val + "via last_eval"); return parseFloat(this_cell.val);}
    console.log("eval: "+this_cell.eqn);
    var out = parseFloat(eval(this_cell.eqn));
    console.log("formula for " + name + "=" + out);
    g._nodes[name].last_eval = last_eval;
    g._nodes[name].val = out;
    fixboxsize(g._nodes[name]);
    return out;
}

function checkbox(id, checked){situations[id]=checked;
    if (checked){
        console.log("checked" + id);
        for (i in  g._nodes)
            if (g._nodes[i].class=="type-DT"){
                nodestorage[i] = g._nodes[i];
                g.removeNode(i);
                redrawIt();
            }
    } else {
        console.log("unchecked" + id);
        for (i in  nodestorage)
            if (nodestorage[i].class=="type-DT"){
                g.setNode(i, nodestorage[i]);
                reedge();
                redrawIt();
            }
    }

}

</script>
</body>
</html>
