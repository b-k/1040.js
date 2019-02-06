m4_changequote(<|,|>)
<meta charset="utf-8">
<!-- Licensed under GPLv2, with one clarification; see https://github.com/b-k/1040.js . -->
<html>
<title>The tax graph</title>

<!--<link rel="stylesheet" href="demo.css">-->
<script src="d3.v3.min.js" charset="utf-8"></script>
<script src="dagre-d3.min.js" charset="utf-8"></script>
<script>

</script>

<style id="css">
g.u > rect {
  fill: #caf2bd;
}

text {
  font-weight: 300;
  font-family: "Helvetica Neue", Helvetica, Arial, sans-serf;
  font-size: 19px;
}

input[type=checkbox]
{
   /* Double-sized Checkboxes, via https://stackoverflow.com/questions/306924/checkbox-size-in-html-css */
   -ms-transform: scale(2); /* IE */
   -moz-transform: scale(2); /* FF */
   -webkit-transform: scale(2); /* Safari and Chrome */
   -o-transform: scale(2); /* Opera */
   padding: 10px;
}

.checkboxtext
{
    /* Checkbox text */
    font-size: 110%;
    display: inline;
}


body{
  font-size: 25px;
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


div.tooltip { /* thx, http://www.d3noob.org/2013/01/adding-tooltips-to-d3js-graph.html */
  position: absolute;
  text-align: center;
  /*width: 60px;
  height: 28px;                 */
  padding: 3px;
  font: 25px sans-serif;
  background: lightsteelblue;
  border: 1px;
  border-radius: 8px;
  pointer-events: none;
}

</style>

<body>
The 2017 U.S. tax graph<br>
Click an avocado box to enter a value.<br>
To see more or less, use your browser's zoom (often &lt;ctrl&gt;-&lt;+&gt; or &lt;ctrl&gt;-&lt;-&gt;, or try your mouse wheel).<br>

<table><tr><td>
<input type="radio" name="spouse" size=3em checked onchange="recalc()"> I am single.<br>
<input type="radio" name="spouse" size=3em onchange="recalc()"> I have a spouse; we file jointly.<br>
<input type="radio" name="spouse" size=3em onchange="recalc()"> I have a spouse; we file separately.<br>
<input text id="kids" size=3em onchange="kidcalc()"> Dependent children<br>
<input text id="nonkid_dependents" size=3em onchange="recalc()"> Dependents over 17<br>
</td><td>

m4_define(BOX, <|<INPUT class=check TYPE=CHECKBOX NAME="$1" id=".$1" onclick="checkbox(id, checked)" checked><span class="checkboxtext"> $2</span><BR>|>)
BOX(over_65, I am over 65.)

BOX(spouse_over_65, My spouse is over 65.)
BOX(s_loans, I have student loans or education expenses.)
BOX(mort, I have a mortgage.)
BOX(itemizing, I am itemizing.)
BOX(have_rr, I have rental or royalty income.)
<INPUT class=check TYPE=CHECKBOX NAME="hide_zeros" id=".hide_zeros" onclick="hidezeros(id, checked)" ><span class="checkboxtext"> I want to hide the inessential zero cells.</span><BR>
<a href="https://github.com/b-k/1040.js">I want to make this tax explorer better.</a>
</td></tr></table>

<svg id="svg-canvas" width=960 height=600></svg>

<script id="js">
<!-- Much of this started at http://cpettitt.github.io/project/dagre-d3/latest/demo/sentence-tokenization.html -->

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
    if (typeof g._nodes[from] === "undefined") return;
    for (i in toset){
        if (toset[i]=="") return;
        if (typeof g._nodes[toset[i]] === "undefined") return;
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


var val_prompt = function(d){
    //var promptval = window.prompt(this.textContent, g._nodes[d].val);
    var promptval = window.prompt(this.textContent);
    var floated = parseFloat(promptval)
    if(isNaN(floated)) return;
    g._nodes[d].val = floated;
    fixboxsize(g._nodes[d]);
    last_eval += 1;
    Cv("f1040_refund");
    Cv("f1040_tax_owed");
    Cv("f8582_carryover_to_next_year");
    redrawIt();
}

var redrawIt = function(){
    d3.selectAll("div.tooltip").style("opacity", 0);
    render(d3.select("svg g"), g);
    svg.attr("width", g.graph().width + 40);
    svg.attr("height", g.graph().height + 40);
    var xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
    svgGroup.attr("transform", "translate(" + xCenterOffset + ", 20)");
    svg.selectAll(".u").on('click', val_prompt);

    var div = d3.select("body").append("div")
        .attr("class", "tooltip")
            .style("opacity", 0);

    svg.selectAll(".a_node")
        .on("mouseover", function(d) {
            div.transition()
                .duration(200)
                .style("opacity", .9);
            div .html(g._nodes[d].fullname + "<br>" + g._nodes[d].form)
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY - 28) + "px");
            }
            )
        .on("mouseout", function(d){
            div.transition()
                .duration(500)
                .style("opacity", 0);
                });
}


svg.selectAll(".u").on('click', val_prompt);

svg.selectAll("arrowhead").style("opacity", false);

var situations = [];

var last_eval = 0;

function Cv(name){
    this_cell = g._nodes[name];
    if (typeof this_cell === "undefined") this_cell = nodestorage[name];
    if (this_cell.eqn==="" || this_cell.last_eval >= last_eval)
        return parseFloat(this_cell.val);
    var out = parseFloat(eval(this_cell.eqn));

    if (g._nodes[name]){
        g._nodes[name].last_eval = last_eval;
        g._nodes[name].val = out;
        fixboxsize(g._nodes[name]);
    } else{
        nodestorage[name].last_eval = last_eval;
        nodestorage[name].val = out;
    }
    return out;
}

function recalc(){
    last_eval +=1
    Cv("f1040_refund");
    Cv("f1040_tax_owed");
    Cv("f8582_carryover_to_next_year");
    redrawIt();
}

function checkbox(id, checked){situations[id]=checked;
    if (!checked){
        svg.selectAll(id).each(function(i){
                if (g._nodes[i].class.match("critical")) return;
                var n = g._nodes[i];
                nodestorage[i] = { label: n.label,
                        baselabel: n.baselabel,
                        form: n.form,
                        fullname:  n.fullname,
                        class: n.class, val:n.val
                        , eqn: n.eqn, last_eval: n.last_eval
                        };
                g.removeNode(i);
            });
        redrawIt();
    } else {
        for (i in nodestorage){
            if (nodestorage[i].class.indexOf(id.replace('\.',''))>0){
                g.setNode(i, nodestorage[i], { label: nodestorage[i].label,
                        baselabel: nodestorage[i].baselabel,
                        form: nodestorage[i].form,
                        fullname:  nodestorage[i].fullname,
                        class: nodestorage[i].class, val:nodestorage[i].val
                        , eqn: nodestorage[i].eqn, last_eval: nodestorage[i].last_eval
                        });
            }
        }
        reedge();
        redrawIt();
    }
    Cv("f1040_refund");
    Cv("f1040_tax_owed");
}

function hidezeros(id, checked){
    if (!checked){
        checkbox(id, !checked);
        //svg.selectAll(".a_node").filter(function(d){return g._nodes[d].val==0}).classed('hide_zeros', false)
    } else {
//        svg.selectAll(".a_node").filter(function(d){return g._nodes[d].val==0}).classed('hide_zeros', true)
        for (i in g._nodes)  g._nodes[i].class.replace(/hide_zeros/g, "");
         for (i in nodestorage)  nodestorage[i].class.replace(/hide_zeros/g, "");
        for (i in g._nodes) if (g._nodes[i].val==0) g._nodes[i].class += " hide_zeros";
        redrawIt();
        checkbox(id, !checked);
    }
}

var kidcalc = function(){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    checkbox('.have_kids', (kids>0 ? true : false)); recalc();
}

document.getElementById(".have_rr").click()
document.getElementById(".s_loans").click()
document.getElementById(".mort").click()
document.getElementById(".itemizing").click()
document.getElementById(".over_65").click()
document.getElementById(".spouse_over_65").click()
checkbox(".have_kids", false)

redrawIt()

</script>
</body>
</html>
