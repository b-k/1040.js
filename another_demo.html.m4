m4_changequote(<|,|>)
<meta charset="utf-8">
<!-- http://cpettitt.github.io/project/dagre-d3/latest/demo/sentence-tokenization.html -->
<html>
<title>The tax graph</title>

<!--<link rel="stylesheet" href="demo.css">-->
<script>
m4_include(d3.v3.js)

m4_include(graphlib-dot.js)

m4_include(dagre-d3.js)
</script>

<style id="css">
/* This sets the color for user input nodes to a light blue green. */
g.u > rect {
  fill: #00ffd0;
}

text {
  font-weight: 300;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serf;
  font-size: 19px;
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

<INPUT TYPE=CHECKBOX NAME="dependents" id=".over_65" onclick="checkbox(id, checked)">I am over 65.<BR>
<INPUT TYPE=CHECKBOX NAME="mortgage" id="mort" onclick="checkbox(id, checked)">I have a mortgage.<BR>

<svg id="svg-canvas" width=960 height=600></svg>


<script id="js">

var itemizing = 0;
var over_65 = 0;
var spouse_over_65 = 0;

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
  size = Math.sqrt(Math.max(node.val, 1000));
  //node.width = size*2.5;
  node.height = size*.9;
  node.label = node.baselabel + ": " + node.val
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

svg.selectAll(".u").on('click', 
        function(d){
        var promptval = window.prompt(this.textContent, g._nodes[d].val);
        if(promptval==null) return;
        g._nodes[d].val = parseFloat(promptval);
        //console.log(this.textContent + g._nodes[d].val);
        fixboxsize(g._nodes[d]);
        last_eval += 1;
        CV("1040_refund");
        CV("1040_tax_owed");
        redrawIt();
    });

svg.selectAll("arrowhead").style("opacity", false);

var situations = {};

var have_rr = 0;
var kids = 0;

var last_eval = 0;

function CV(name){
    //console.log("eval " + name);
    this_cell = g._nodes[name];
    if (!this_cell) this_cell = nodestorage[name];
    if (this_cell.eqn=="u" || this_cell.eqn=="") return parseFloat(this_cell.val);
    if (this_cell.last_eval >= last_eval) return parseFloat(this_cell.val);
    var out = parseFloat(eval(this_cell.eqn));
    g._nodes[name].last_eval = last_eval;
    g._nodes[name].val = out;
    fixboxsize(g._nodes[name]);
    return out;
}

function checkbox(id, checked){situations[id]=checked;
    if (checked){
        console.log("checked" + id);
        svg.selectAll(id).each(function(i){
                nodestorage[i] = g._nodes[i];
                g.removeNode(i);
                redrawIt();
            });
    } else {
        console.log("unchecked" + id);
        for (i in nodestorage){
            var changed = false;
            console.log("checking "+ i+" for "+id.replace('\.',''));
            if (nodestorage[i].class.indexOf(id.replace('\.',''))>0){
                changed=true;
                console.log("found "+ i);
                g.setNode(i, nodestorage[i]);
                g.setNode(i,  { label: nodestorage[i].label,
                        baselabel: nodestorage[i].baselabel,
                        fullname:  nodestorage[i].fullname,
                        class: nodestorage[i].class, val:nodestorage[i].val
                        , eqn: nodestorage[i].eqn, last_eval: nodestorage[i].last_eval });
            }
        }
        if (changed){
            reedge();
            redrawIt();
        }
    }

}

</script>
</body>
</html>
