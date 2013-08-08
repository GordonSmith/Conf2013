EXPORT d3 := MODULE, FORWARD
  IMPORT Std;
  EXPORT Bundle := MODULE(Std.BundleBase)
    EXPORT Name := 'CellFormatter';
    EXPORT Description := 'D3 Visualisations';
    EXPORT Authors := ['Gordon Smith'];
    EXPORT License := 'http://www.apache.org/licenses/LICENSE-2.0';
    EXPORT Copyright := 'Copyright (C) 2013 HPCC Systems';
    EXPORT DependsOn := [];
    EXPORT Version := '1.0.0';
  END;
  
  EXPORT Chart(string dataCol, string labelField, string valueField) := MODULE
  		shared common := 'var __sourceData=lang.clone(__row.' + dataCol + ');var getLabel=function(e){return e.' + labelField + '};var getValue=function(e){return+e.' + valueField + '};' +
  			'require(["d3/d3.v3.min.js"],function () {';		
		export Pie := common +
			'var diameter=500;var radius=diameter/2;var color=d3.scale.category20c();var arc=d3.svg.arc().outerRadius(radius-10).innerRadius(0);var pie=d3.layout.pie().sort(null).value(function(e){return getValue(e)});var svg=d3.select(__cell).append("svg").attr("width",diameter).attr("height",diameter).append("g").attr("transform","translate("+radius+","+radius+")");var g=svg.selectAll(".arc").data(pie(__sourceData)).enter().append("g").attr("class","arc");g.append("path").attr("d",arc).style("fill",function(e){return color(getLabel(e.data))});g.append("text").attr("transform",function(e){return"translate("+arc.centroid(e)+")"}).attr("dy",".35em").style("text-anchor","middle").text(function(e){return getLabel(e.data)});' +
			'});';
		export Bubble := common +
			'var diameter=500;var color=d3.scale.category20c();var format=d3.format(",d");var bubble=d3.layout.pack().sort(null).value(function(e){return getValue(e)}).size([diameter,diameter]).padding(1.5);var svg=d3.select(__cell).append("svg").attr("width",diameter).attr("height",diameter).attr("class","bubble");var root={children:__sourceData};var node=svg.selectAll(".node").data(bubble.nodes(root).filter(function(e){return!e.children})).enter().append("g").attr("class","node").attr("transform",function(e){return"translate("+e.x+","+e.y+")"});node.append("title").text(function(e){return getLabel(e)+": "+format(getValue(e))});node.append("circle").attr("r",function(e){return e.r}).style("fill",function(e){return color(getLabel(e))});node.append("text").attr("dy",".3em").style("text-anchor","middle").text(function(e){return getLabel(e).substring(0,e.r/3)});' +
			'});';
		export BarChart := common +
			'dojo.query("head").append("<style>.axisBC path, .axisBC line { fill: none; stroke: #000; shape-rendering: crispEdges; } .barBC { fill: steelblue; } .x.axisBC path { display: none; } </style>");var margin={top:20,right:20,bottom:30,left:40},width=500-margin.left-margin.right,height=500-margin.top-margin.bottom;var formatPercent=d3.format(",d");var x=d3.scale.ordinal().rangeRoundBands([0,width],.1);var y=d3.scale.linear().range([height,0]);var xAxis=d3.svg.axis().scale(x).orient("bottom");var yAxis=d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent);var svg=d3.select(__cell).append("svg").attr("width",width+margin.left+margin.right).attr("height",height+margin.top+margin.bottom).append("g").attr("transform","translate("+margin.left+","+margin.top+")");x.domain(__sourceData.map(function(e){return getLabel(e)}));y.domain([0,d3.max(__sourceData,function(e){return getValue(e)})]);svg.append("g").attr("class","x axisBC").attr("transform","translate(0,"+height+")").call(xAxis);svg.append("g").attr("class","y axisBC").call(yAxis).append("text").attr("transform","rotate(-90)").attr("y",6).attr("dy",".71em").style("text-anchor","end").text("Count");svg.selectAll(".barBC").data(__sourceData).enter().append("rect").attr("class","barBC").attr("x",function(e){return x(getLabel(e))}).attr("width",x.rangeBand()).attr("y",function(e){return y(getValue(e))}).attr("height",function(e){return height-y(getValue(e))});' + 
			'});';
		export ParallelCoordinates := common +
			'var __labelField = "' + labelField + '";' +
			'dojo.query("head").append("<style>svg{font:10px sans-serif} .background path{fill:none;stroke:#ccc;stroke-opacity:.4;shape-rendering:crispEdges} .foreground path{fill:none;stroke:#4682B4;stroke-opacity:.7} .brush .extent{fill-opacity:.3;stroke:#fff;shape-rendering:crispEdges} .axis line,.axis path{fill:none;stroke:#000;shape-rendering:crispEdges} .axis text{text-shadow:0 1px 0 #fff;cursor:move}</style>");var m=[30,10,10,10],w=960-m[1]-m[3],h=500-m[0]-m[2];var x=d3.scale.ordinal().rangePoints([0,w],1),y={},dragging={};var line=d3.svg.line(),axis=d3.svg.axis().orient("left"),background,foreground;var svg=d3.select(__cell).append("svg").attr("width",w+m[1]+m[3]).attr("height",h+m[0]+m[2]).append("g").attr("transform","translate("+m[3]+","+m[0]+")");x.domain(dimensions=d3.keys(__sourceData[0]).filter(function(e){return e!=__labelField&&(y[e]=d3.scale.linear().domain(d3.extent(__sourceData,function(t){return+t[e]})).range([h,0]))}));background=svg.append("g").attr("class","background").selectAll("path").data(__sourceData).enter().append("path").attr("d",path);foreground=svg.append("g").attr("class","foreground").selectAll("path").data(__sourceData).enter().append("path").attr("d",path);var g=svg.selectAll(".dimension").data(dimensions).enter().append("g").attr("class","dimension").attr("transform",function(e){return"translate("+x(e)+")"}).call(d3.behavior.drag().on("dragstart",function(e){dragging[e]=this.__origin__=x(e);background.attr("visibility","hidden")}).on("drag",function(e){dragging[e]=Math.min(w,Math.max(0,this.__origin__+=d3.event.dx));foreground.attr("d",path);dimensions.sort(function(e,t){return position(e)-position(t)});x.domain(dimensions);g.attr("transform",function(e){return"translate("+position(e)+")"})}).on("dragend",function(e){delete this.__origin__;delete dragging[e];transition(d3.select(this)).attr("transform","translate("+x(e)+")");transition(foreground).attr("d",path);background.attr("d",path).transition().delay(500).duration(0).attr("visibility",null)}));g.append("g").attr("class","axis").each(function(e){d3.select(this).call(axis.scale(y[e]))}).append("text").attr("text-anchor","middle").attr("y",-9).text(String);g.append("g").attr("class","brush").each(function(e){d3.select(this).call(y[e].brush=d3.svg.brush().y(y[e]).on("brush",brush))}).selectAll("rect").attr("x",-8).attr("width",16);var position=function(e){var t=dragging[e];return t==null?x(e):t};var transition=function(e){return e.transition().duration(500)};var path=function(e){return line(dimensions.map(function(t){return[position(t),y[t](e[t])]}))};var brush=function(){var e=dimensions.filter(function(e){return!y[e].brush.empty()}),t=e.map(function(e){return y[e].brush.extent()});foreground.style("display",function(n){return e.every(function(e,r){return t[r][0]<=n[e]&&n[e]<=t[r][1]})?null:"none"})};' + 
			'});';
  END;
  EXPORT Tree(string dataCol, string labelField, string childrenField, string valueField) := MODULE
  		shared common := 'var __sourceData=lang.clone(__row.' + dataCol + ');var getLabel=function(e){return e.' + labelField + '};var getChildren=function(e){return e.' + childrenField + '};var getValue=function(e){return+e.' + valueField + '};' +
  			'require(["d3/d3.v3.min.js"],function () {';		
		export ClusterDendrogram := common + 
			'dojo.query("head").append("<style>.nodeCD circle { fill: #fff; stroke: steelblue; stroke-width: 1.5px;}.nodeCD { font: 10px sans-serif;}.linkCD { fill: none; stroke: #ccc; stroke-width: 1.5px;}</style>");var width=500,height=500;var cluster=d3.layout.cluster().size([height,width-160]).children(function(e){return getChildren(e)});var diagonal=d3.svg.diagonal().projection(function(e){return[e.y,e.x]});var svg=d3.select(__cell).append("svg").attr("width",width).attr("height",height).append("g").attr("transform","translate(40,0)");var nodes=cluster.nodes(__sourceData),links=cluster.links(nodes);var link=svg.selectAll(".link").data(links).enter().append("path").attr("class","linkCD").attr("d",diagonal);var node=svg.selectAll(".node").data(nodes).enter().append("g").attr("class","nodeCD").attr("transform",function(e){return"translate("+e.y+","+e.x+")"});node.append("circle").attr("r",4.5);node.append("text").attr("dx",function(e){return getChildren(e)?-8:8}).attr("dy",3).style("text-anchor",function(e){return getChildren(e)?"end":"start"}).text(function(e){return getLabel(e)});';
			'});';
		export CirclePacking := common + 
			'dojo.query("head").append("<style>.nodeCP circle{ fill: rgb(31, 119, 180); fill-opacity: .25; stroke: rgb(31, 119, 180); stroke-width: 1px;}.leafCP circle {  fill: #ff7f0e;  fill-opacity: 1;}</style>");var diameter=500,format=d3.format(",d");var pack=d3.layout.pack().size([diameter-4,diameter-4]).children(function(e){return getChildren(e)}).value(function(e){return getValue(e)});var svg=d3.select(__cell).append("svg").attr("width",diameter).attr("height",diameter).append("g").attr("transform","translate(2,2)");var node=svg.datum(__sourceData).selectAll(".node").data(pack.nodes).enter().append("g").attr("class",function(e){return getChildren(e)?"nodeCP":"leafCP nodeCP"}).attr("transform",function(e){return"translate("+e.x+","+e.y+")"});node.append("title").text(function(e){return getLabel(e)+(getChildren(e)?"":": "+format(getValue(e)))});node.append("circle").attr("r",function(e){return e.r});node.filter(function(e){return!getChildren(e)}).append("text").attr("dy",".3em").style("text-anchor","middle").text(function(e){return getLabel(e).substring(0,e.r/3)});';        	
			'});';
		export ReingoldTilfordTree := common +
			'dojo.query("head").append("<style>.nodeRTT circle {  fill: #fff;  stroke: steelblue;  stroke-width: 1.5px;}.nodeRTT {  font: 10px sans-serif;}.linkRTT {  fill: none;  stroke: #ccc;  stroke-width: 1.5px;}</style>");var diameter=500;var tree=d3.layout.tree().size([360,diameter/2-20]).children(function(e){return getChildren(e)}).separation(function(e,t){return(e.parent==t.parent?1:2)/e.depth});var diagonal=d3.svg.diagonal.radial().projection(function(e){return[e.y,e.x/180*Math.PI]});var svg=d3.select(__cell).append("svg").attr("width",diameter).attr("height",diameter-0).append("g").attr("transform","translate("+diameter/2+","+diameter/2+")");var nodes=tree.nodes(__sourceData),links=tree.links(nodes);var link=svg.selectAll(".link").data(links).enter().append("path").attr("class","linkRTT").attr("d",diagonal);var node=svg.selectAll(".node").data(nodes).enter().append("g").attr("class","nodeRTT").attr("transform",function(e){return"rotate("+(e.x-90)+")translate("+e.y+")"});node.append("circle").attr("r",4.5);node.append("text").attr("dy",".31em").attr("text-anchor",function(e){return e.x<180?"start":"end"}).attr("transform",function(e){return e.x<180?"translate(8)":"rotate(180)translate(-8)"}).text(function(e){return getLabel(e)});' +
		export SunburstPartition := common +
			'function computeTextRotation(e){var t=x(e.x+e.dx/2)-Math.PI/2;return t/Math.PI*180}dojo.query("head").append("<style>path { stroke: #fff; fill-rule: evenodd; } </style>");var width=500,height=500,radius=Math.min(width,height)/2;var x=d3.scale.linear().range([0,2*Math.PI]);var y=d3.scale.sqrt().range([0,radius]);var color=d3.scale.category20c();var svg=d3.select(__cell).append("svg").attr("width",width).attr("height",height).append("g").attr("transform","translate("+width/2+","+(height/2+10)+")");var partition=d3.layout.partition().children(function(e){return getChildren(e)}).value(function(e){return getValue(e)});var arc=d3.svg.arc().startAngle(function(e){return Math.max(0,Math.min(2*Math.PI,x(e.x)))}).endAngle(function(e){return Math.max(0,Math.min(2*Math.PI,x(e.x+e.dx)))}).innerRadius(function(e){return Math.max(0,y(e.y))}).outerRadius(function(e){return Math.max(0,y(e.y+e.dy))});var g=svg.selectAll("g").data(partition.nodes(__sourceData)).enter().append("g");var path=g.append("path").attr("d",arc).style("fill",function(e){return color(getLabel(getChildren(e)?e:e.parent))});var text=g.append("text").attr("x",function(e){return y(e.y)}).attr("dx","6").attr("dy",".35em").text(function(e){return getLabel(e)});text.attr("transform",function(e){return"rotate("+computeTextRotation(e)+")"});' +
			'});';
  END;
  EXPORT Graph(string verticesCol, string labelField, string groupField, string edgesCol, string sourceField, string targetField, string weightField) := MODULE
  		shared common := 'var __verticesData=lang.clone(__row.' + verticesCol + ').map(function(e){e.name=e.' + labelField + ';e.group=e.' + groupField + ';return e});var __edgesData=lang.clone(__row.' + edgesCol + ').map(function(e){e.source=+e.' + sourceField + ';e.target=+e.' + targetField + ';e.value=+e.' + weightField + ';return e});' +
  			'require(["d3/d3.v3.min.js"],function () {';
		export ForceDirected := common + 
			'dojo.query("head").append("<style>.nodeFD { stroke: #fff; stroke-width: 1.5px; } .linkFD { stroke: #999; stroke-opacity: .6; }</style>");var width=500,height=500;var color=d3.scale.category20();var force=d3.layout.force().charge(-120).linkDistance(30).size([width,height]);var svg=d3.select(__cell).append("svg").attr("width",width).attr("height",height).append("g");force.nodes(__verticesData).links(__edgesData);var link=svg.selectAll(".linkFD").data(__edgesData).enter().append("line").attr("class","linkFD").style("stroke-width",function(e){return Math.sqrt(e.value)});var node=svg.selectAll(".nodeFD").data(__verticesData).enter().append("circle").attr("class","nodeFD").attr("r",5).style("fill",function(e){return color(e.group)}).call(force.drag);node.append("title").text(function(e){return e.name});force.on("tick",function(){link.attr("x1",function(e){return e.source.x}).attr("y1",function(e){return e.source.y}).attr("x2",function(e){return e.target.x}).attr("y2",function(e){return e.target.y});node.attr("cx",function(e){return e.x}).attr("cy",function(e){return e.y})});var n=__verticesData.length;arrayUtil.forEach(__verticesData,function(e,t){e.x=e.y=width/n*t});force.start();for(var i=n;i>0;--i){force.tick()}force.stop();' +
			'});';
		export CoOccurrence := common + 
			'function row(e){var t=d3.select(this).selectAll(".cell").data(e.filter(function(e){return e.z})).enter().append("rect").attr("class","cell").attr("x",function(e){return x(e.x)}).attr("width",x.rangeBand()).attr("height",x.rangeBand()).style("fill-opacity",function(e){return z(e.z)}).style("fill",function(e){return nodes[e.x].group==nodes[e.y].group?c(nodes[e.x].group):null}).on("mouseover",mouseover).on("mouseout",mouseout)}function mouseover(e){d3.selectAll(".row text").classed("active",function(t,n){return n==e.y});d3.selectAll(".column text").classed("active",function(t,n){return n==e.x})}function mouseout(){d3.selectAll("text").classed("active",false)}function order(e){x.domain(orders[e]);var t=svg.transition().duration(2500);t.selectAll(".row").delay(function(e,t){return x(t)*4}).attr("transform",function(e,t){return"translate(0,"+x(t)+")"}).selectAll(".cell").delay(function(e){return x(e.x)*4}).attr("x",function(e){return x(e.x)});t.selectAll(".column").delay(function(e,t){return x(t)*4}).attr("transform",function(e,t){return"translate("+x(t)+")rotate(-90)"})}dojo.query("head").append("<style>.background { fill: #eee; } line { stroke: #fff; } text.active { fill: red; } </style>");var margin={top:80,right:0,bottom:10,left:100},width=720,height=720;var x=d3.scale.ordinal().rangeBands([0,width]),z=d3.scale.linear().domain([0,4]).clamp(true),c=d3.scale.category10().domain(d3.range(10));var svg=d3.select(__cell).append("svg").attr("width",width+margin.left+margin.right).attr("height",height+margin.top+margin.bottom).style("margin-left",0+"px").append("g").attr("transform","translate("+margin.left+","+margin.top+")");var matrix=[],nodes=__verticesData,n=nodes.length;nodes.forEach(function(e,t){e.index=t;e.count=0;matrix[t]=d3.range(n).map(function(e){return{x:e,y:t,z:0}})});__edgesData.forEach(function(e){matrix[e.source][e.target].z+=e.value;matrix[e.target][e.source].z+=e.value;matrix[e.source][e.source].z+=e.value;matrix[e.target][e.target].z+=e.value;nodes[e.source].count+=e.value;nodes[e.target].count+=e.value});var orders={name:d3.range(n).sort(function(e,t){return d3.ascending(nodes[e].name,nodes[t].name)}),count:d3.range(n).sort(function(e,t){return nodes[t].count-nodes[e].count}),group:d3.range(n).sort(function(e,t){return nodes[t].group-nodes[e].group})};x.domain(orders.group);svg.append("rect").attr("class","background").attr("width",width).attr("height",height);var row=svg.selectAll(".row").data(matrix).enter().append("g").attr("class","row").attr("transform",function(e,t){return"translate(0,"+x(t)+")"}).each(row);row.append("line").attr("x2",width);row.append("text").attr("x",-6).attr("y",x.rangeBand()/2).attr("dy",".32em").attr("text-anchor","end").text(function(e,t){return nodes[t].name});var column=svg.selectAll(".column").data(matrix).enter().append("g").attr("class","column").attr("transform",function(e,t){return"translate("+x(t)+")rotate(-90)"});column.append("line").attr("x1",-width);column.append("text").attr("x",6).attr("y",x.rangeBand()/2).attr("dy",".32em").attr("text-anchor","start").text(function(e,t){return nodes[t].name});d3.select("#order").on("change",function(){clearTimeout(timeout);order(this.value)});' + 
			'});';
  END;
	/*
  EXPORT __selfTest := MODULE
    SHARED testrec := RECORD
      STRING20 name;
			UNSIGNED integer4 value;
    END;

    testdata := DATASET([
			{'Richard', 30},
			{'Gordon', 66},
			{'Gavin', 64}
			], testrec);
    pieViz := pie(testdata, testdata.name, testdata.value);

    EXPORT __selfTest := [
			OUTPUT(pieViz, named('__selfTest');
    ];
  END;
*/
END;