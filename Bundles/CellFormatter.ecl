EXPORT CellFormatter := MODULE, FORWARD
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

  EXPORT d3Chart(string dataCol, string labelField, string valueField) := MODULE
  		shared common := 'var __sourceData=lang.clone(row.' + dataCol + ');var getLabel=function(e){return e.' + labelField + '};var getValue=function(e){return+e.' + valueField + '};';		
		export Pie := common +
			'var diameter=500;var radius=diameter/2;var color=d3.scale.category20c();var arc=d3.svg.arc().outerRadius(radius-10).innerRadius(0);var pie=d3.layout.pie().sort(null).value(function(e){return getValue(e)});var svg=d3.select(cell).append("svg").attr("width",diameter).attr("height",diameter).append("g").attr("transform","translate("+radius+","+radius+")");var g=svg.selectAll(".arc").data(pie(__sourceData)).enter().append("g").attr("class","arc");g.append("path").attr("d",arc).style("fill",function(e){return color(getLabel(e.data))});g.append("text").attr("transform",function(e){return"translate("+arc.centroid(e)+")"}).attr("dy",".35em").style("text-anchor","middle").text(function(e){return getLabel(e.data)});';
		export Bubble := common +
			'var diameter=500;var color=d3.scale.category20c();var format=d3.format(",d");var bubble=d3.layout.pack().sort(null).value(function(e){return getValue(e)}).size([diameter,diameter]).padding(1.5);var svg=d3.select(cell).append("svg").attr("width",diameter).attr("height",diameter).attr("class","bubble");var root={children:__sourceData};var node=svg.selectAll(".node").data(bubble.nodes(root).filter(function(e){return!e.children})).enter().append("g").attr("class","node").attr("transform",function(e){return"translate("+e.x+","+e.y+")"});node.append("title").text(function(e){return getLabel(e)+": "+format(getValue(e))});node.append("circle").attr("r",function(e){return e.r}).style("fill",function(e){return color(getLabel(e))});node.append("text").attr("dy",".3em").style("text-anchor","middle").text(function(e){return getLabel(e).substring(0,e.r/3)});';
		export BarChart := common +
			'dojo.query("head").append("<style>.axisBC path, .axisBC line { fill: none; stroke: #000; shape-rendering: crispEdges; } .barBC { fill: steelblue; } .x.axisBC path { display: none; } </style>");var margin={top:20,right:20,bottom:30,left:40},width=500-margin.left-margin.right,height=500-margin.top-margin.bottom;var formatPercent=d3.format(",d");var x=d3.scale.ordinal().rangeRoundBands([0,width],.1);var y=d3.scale.linear().range([height,0]);var xAxis=d3.svg.axis().scale(x).orient("bottom");var yAxis=d3.svg.axis().scale(y).orient("left").tickFormat(formatPercent);var svg=d3.select(cell).append("svg").attr("width",width+margin.left+margin.right).attr("height",height+margin.top+margin.bottom).append("g").attr("transform","translate("+margin.left+","+margin.top+")");x.domain(__sourceData.map(function(e){return getLabel(e)}));y.domain([0,d3.max(__sourceData,function(e){return getValue(e)})]);svg.append("g").attr("class","x axisBC").attr("transform","translate(0,"+height+")").call(xAxis);svg.append("g").attr("class","y axisBC").call(yAxis).append("text").attr("transform","rotate(-90)").attr("y",6).attr("dy",".71em").style("text-anchor","end").text("Count");svg.selectAll(".barBC").data(__sourceData).enter().append("rect").attr("class","barBC").attr("x",function(e){return x(getLabel(e))}).attr("width",x.rangeBand()).attr("y",function(e){return y(getValue(e))}).attr("height",function(e){return height-y(getValue(e))});'; 
  END;
  EXPORT d3Tree(string dataCol, string labelField, string childrenField, string valueField) := MODULE
  		shared common := 'var __sourceData=lang.clone(row.' + dataCol + ');var getLabel=function(e){return e.' + labelField + '};var getChildren=function(e){return e.' + childrenField + '};var getValue=function(e){return+e.' + valueField + '};';		
		export ClusterDendrogram := common + 
			'dojo.query("head").append("<style>.nodeCD circle { fill: #fff; stroke: steelblue; stroke-width: 1.5px;}.nodeCD { font: 10px sans-serif;}.linkCD { fill: none; stroke: #ccc; stroke-width: 1.5px;}</style>");var width=500,height=500;var cluster=d3.layout.cluster().size([height,width-160]).children(function(e){return getChildren(e)});var diagonal=d3.svg.diagonal().projection(function(e){return[e.y,e.x]});var svg=d3.select(cell).append("svg").attr("width",width).attr("height",height).append("g").attr("transform","translate(40,0)");var nodes=cluster.nodes(__sourceData),links=cluster.links(nodes);var link=svg.selectAll(".link").data(links).enter().append("path").attr("class","linkCD").attr("d",diagonal);var node=svg.selectAll(".node").data(nodes).enter().append("g").attr("class","nodeCD").attr("transform",function(e){return"translate("+e.y+","+e.x+")"});node.append("circle").attr("r",4.5);node.append("text").attr("dx",function(e){return getChildren(e)?-8:8}).attr("dy",3).style("text-anchor",function(e){return getChildren(e)?"end":"start"}).text(function(e){return getLabel(e)});';
		export CirclePacking := common + 
			'dojo.query("head").append("<style>.nodeCP circle{ fill: rgb(31, 119, 180); fill-opacity: .25; stroke: rgb(31, 119, 180); stroke-width: 1px;}.leafCP circle {  fill: #ff7f0e;  fill-opacity: 1;}</style>");var diameter=500,format=d3.format(",d");var pack=d3.layout.pack().size([diameter-4,diameter-4]).children(function(e){return getChildren(e)}).value(function(e){return getValue(e)});var svg=d3.select(cell).append("svg").attr("width",diameter).attr("height",diameter).append("g").attr("transform","translate(2,2)");var node=svg.datum(__sourceData).selectAll(".node").data(pack.nodes).enter().append("g").attr("class",function(e){return getChildren(e)?"nodeCP":"leafCP nodeCP"}).attr("transform",function(e){return"translate("+e.x+","+e.y+")"});node.append("title").text(function(e){return getLabel(e)+(getChildren(e)?"":": "+format(getValue(e)))});node.append("circle").attr("r",function(e){return e.r});node.filter(function(e){return!getChildren(e)}).append("text").attr("dy",".3em").style("text-anchor","middle").text(function(e){return getLabel(e).substring(0,e.r/3)});';        	
		export ReingoldTilfordTree := common +
			'dojo.query("head").append("<style>.nodeRTT circle {  fill: #fff;  stroke: steelblue;  stroke-width: 1.5px;}.nodeRTT {  font: 10px sans-serif;}.linkRTT {  fill: none;  stroke: #ccc;  stroke-width: 1.5px;}</style>");var diameter=500;var tree=d3.layout.tree().size([360,diameter/2-20]).children(function(e){return getChildren(e)}).separation(function(e,t){return(e.parent==t.parent?1:2)/e.depth});var diagonal=d3.svg.diagonal.radial().projection(function(e){return[e.y,e.x/180*Math.PI]});var svg=d3.select(cell).append("svg").attr("width",diameter).attr("height",diameter-0).append("g").attr("transform","translate("+diameter/2+","+diameter/2+")");var nodes=tree.nodes(__sourceData),links=tree.links(nodes);var link=svg.selectAll(".link").data(links).enter().append("path").attr("class","linkRTT").attr("d",diagonal);var node=svg.selectAll(".node").data(nodes).enter().append("g").attr("class","nodeRTT").attr("transform",function(e){return"rotate("+(e.x-90)+")translate("+e.y+")"});node.append("circle").attr("r",4.5);node.append("text").attr("dy",".31em").attr("text-anchor",function(e){return e.x<180?"start":"end"}).attr("transform",function(e){return e.x<180?"translate(8)":"rotate(180)translate(-8)"}).text(function(e){return getLabel(e)});';
		export SunburstPartition := common +
			'function computeTextRotation(e){var t=x(e.x+e.dx/2)-Math.PI/2;return t/Math.PI*180}dojo.query("head").append("<style>path { stroke: #fff; fill-rule: evenodd; } </style>");var width=500,height=500,radius=Math.min(width,height)/2;var x=d3.scale.linear().range([0,2*Math.PI]);var y=d3.scale.sqrt().range([0,radius]);var color=d3.scale.category20c();var svg=d3.select(cell).append("svg").attr("width",width).attr("height",height).append("g").attr("transform","translate("+width/2+","+(height/2+10)+")");var partition=d3.layout.partition().children(function(e){return getChildren(e)}).value(function(e){return getValue(e)});var arc=d3.svg.arc().startAngle(function(e){return Math.max(0,Math.min(2*Math.PI,x(e.x)))}).endAngle(function(e){return Math.max(0,Math.min(2*Math.PI,x(e.x+e.dx)))}).innerRadius(function(e){return Math.max(0,y(e.y))}).outerRadius(function(e){return Math.max(0,y(e.y+e.dy))});var g=svg.selectAll("g").data(partition.nodes(__sourceData)).enter().append("g");var path=g.append("path").attr("d",arc).style("fill",function(e){return color(getLabel(getChildren(e)?e:e.parent))});var text=g.append("text").attr("x",function(e){return y(e.y)}).attr("dx","6").attr("dy",".35em").text(function(e){return getLabel(e)});text.attr("transform",function(e){return"rotate("+computeTextRotation(e)+")"});';
  END;
  EXPORT d3Graph(string verticesCol, string labelField, string groupField, string edgesCol, string sourceField, string targetField, string weightField) := MODULE
  		shared common := 'var __verticesData=lang.clone(row.' + verticesCol + ').map(function(e){e.name=e.' + labelField + ';e.group=e.' + groupField + ';return e});var __edgesData=lang.clone(row.' + edgesCol + ').map(function(e){e.source=+e.' + sourceField + ';e.target=+e.' + targetField + ';e.value=+e.' + weightField + ';return e});';
		export ForceDirected := common + 
			'dojo.query("head").append("<style>.nodeFD { stroke: #fff; stroke-width: 1.5px; } .linkFD { stroke: #999; stroke-opacity: .6; }</style>");var width=500,height=500;var color=d3.scale.category20();var force=d3.layout.force().charge(-120).linkDistance(30).size([width,height]);var svg=d3.select(cell).append("svg").attr("width",width).attr("height",height).append("g");force.nodes(__verticesData).links(__edgesData);var link=svg.selectAll(".linkFD").data(__edgesData).enter().append("line").attr("class","linkFD").style("stroke-width",function(e){return Math.sqrt(e.value)});var node=svg.selectAll(".nodeFD").data(__verticesData).enter().append("circle").attr("class","nodeFD").attr("r",5).style("fill",function(e){return color(e.group)}).call(force.drag);node.append("title").text(function(e){return e.name});force.on("tick",function(){link.attr("x1",function(e){return e.source.x}).attr("y1",function(e){return e.source.y}).attr("x2",function(e){return e.target.x}).attr("y2",function(e){return e.target.y});node.attr("cx",function(e){return e.x}).attr("cy",function(e){return e.y})});var n=__verticesData.length;arrayUtil.forEach(__verticesData,function(e,t){e.x=e.y=width/n*t});force.start();for(var i=n;i>0;--i){force.tick()}force.stop();';
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