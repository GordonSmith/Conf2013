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

  EXPORT d3(string dataCol, string labelField, string valueField) := MODULE
		shared common :=
			'var diameter = 500;\n' +
			'var radius = diameter / 2;\n' +
			'var color = d3.scale.category20c();\n' +
			'var _data = lang.clone(row.' + dataCol + '.Row);\n';
		
		export Pie := common +
			'var arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(0);\n' +
			'var pie = d3.layout.pie().sort(null).value(function(d) { return d.' + valueField + '; });\n' +
			'var svg = d3.select(cell).append("svg").attr("width", diameter).attr("height", diameter).append("g").attr("transform", "translate(" + radius + "," + radius + ")");\n' +
			'var data = _data;\n' +
			'var g = svg.selectAll(".arc").data(pie(data)).enter().append("g").attr("class", "arc");\n' +
			'g.append("path").attr("d", arc).style("fill", function(d) { return color(d.data.' + labelField + '); });\n' +
			'g.append("text").attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; }).attr("dy", ".35em").style("text-anchor", "middle").text(function (d) { return d.data.' + labelField + '; });';
		export Bubble := common +
			'var format = d3.format(",d");\n' +
			'var bubble = d3.layout.pack().sort(null).value(function(d) { return d.' + valueField + '; }).size([diameter, diameter]).padding(1.5);\n' +
			'var svg = d3.select(cell).append("svg").attr("width", diameter).attr("height", diameter).attr("class", "bubble");\n' +
			'var data = { children: _data };\n' +
			'var node = svg.selectAll(".node").data(bubble.nodes(data).filter(function (d) { return !d.children; })).enter().append("g").attr("class", "node").attr("transform", function (d) {  return "translate(" + d.x + "," + d.y + ")";  });\n' +
			'node.append("title").text(function (d) { return d.' + labelField + ' + ": " + format(d.' + valueField + '); });\n' +
			'node.append("circle").attr("r", function (d) { return d.r; }).style("fill", function (d) { return color(d.' + labelField + '); });\n' +
			'node.append("text") .attr("dy", ".3em").style("text-anchor", "middle").text(function (d) { return d.' + labelField + '.substring(0, d.r / 3); });';
		export CirclePacking := common +
			'var format = d3.format(",d");\n' +
			'var bubble = d3.layout.pack().sort(null).value(function(d) { return d.' + valueField + '; }).size([diameter, diameter]).padding(1.5);\n' +
			'var svg = d3.select(cell).append("svg").attr("width", diameter).attr("height", diameter).attr("class", "bubble");\n' +
			'var data = { children: lang.clone(row.' + dataCol + '.Row) };\n' +
			'var node = svg.selectAll(".node").data(bubble.nodes(data).filter(function (d) { return !d.children; })).enter().append("g").attr("class", "node").attr("transform", function (d) {  return "translate(" + d.x + "," + d.y + ")";  });\n' +
			'node.append("title").text(function (d) { return d.' + labelField + ' + ": " + format(d.' + valueField + '); });\n' +
			'node.append("circle").attr("r", function (d) { return d.r; }).style("fill", function (d) { return color(d.' + labelField + '); });\n' +
			'node.append("text") .attr("dy", ".3em").style("text-anchor", "middle").text(function (d) { return d.' + labelField + '.substring(0, d.r / 3); });';
  END;

  EXPORT pieXXX(VIRTUAL DATASET ds, <?> ANY name, <?> ANY value) := MODULE
		#UNIQUENAME(__d3_meta, '__viz_meta_$_');
		shared pieRecord := record
				varstring label;
				integer4 val;
		 end;		

		shared pieRecord makePieData(ds l) := transform
			self.label := l.<name>;
			self.val := l.<value>;
		end;
		shared pieData := project(ds, makePieData(LEFT));
		 
		shared pieMetaRecord := record
						varstring pie__javascript;
						string64 title;
						integer4 width;
						integer4 height;
						dataset(pieRecord) _data;
				 end;
				 
		shared pieMetaData := dataset([{  
			'var radius = row.width / 2;' +
			'var color = d3.scale.category20c();' +
			'var arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(0);' +
			'var pie = d3.layout.pie().sort(null).value(function(d) { return d.val; });' +
			'var svg = d3.select(cell).append("svg").attr("width", row.width).attr("height", row.height).append("g").attr("transform", "translate(" + radius + "," + radius + ")");' +
			'var data = lang.clone(row._data.Row);' +
			'var g = svg.selectAll(".arc").data(pie(data)).enter().append("g").attr("class", "arc");' +
			'g.append("path").attr("d", arc).style("fill", function(d) { return color(d.data.label); });' +
			'g.append("text").attr("transform", function(d) { return "translate(" + arc.centroid(d) + ")"; }).attr("dy", ".35em").style("text-anchor", "middle").text(function (d) { return d.data.label; });',
			'pie', 
			500, 
			520, 
			pieData
		}], pieMetaRecord);
				 
	  export _record := pieMetaRecord;
		export _dataset := pieMetaData;
		export _output := output(_dataset);
  END;

  EXPORT bubbleXXX(VIRTUAL DATASET ds, <?> ANY name, <?> ANY value) := MODULE
		#UNIQUENAME(__d3_meta, '__viz_meta_$_');
		pieRecord := record
				varstring label;
				integer4 val;
		 end;		

		pieRecord makePieData(ds l) := transform
			self.label := l.<name>;
			self.val := l.<value>;
		end;
		pieData := project(ds, makePieData(LEFT));
		 
		pieMetaRecord := record
						varstring pie__javascript;
						string64 title;
						integer4 width;
						integer4 height;
						dataset(pieRecord) _data;
				 end;
				 
		pieMetaData := dataset([{  
			'var diameter = 500;' +
			'var format = d3.format(",d");' +
			'var color = d3.scale.category20c();' +
			'var bubble = d3.layout.pack().sort(null).value(function(d) { return d.val; }).size([diameter, diameter]).padding(1.5);' +
			'var svg = d3.select(cell).append("svg").attr("width", diameter).attr("height", diameter).attr("class", "bubble");' +
			'var data = { children: lang.clone(row._data.Row) };' +
			'var node = svg.selectAll(".node").data(bubble.nodes(data).filter(function (d) { return !d.children; })).enter().append("g").attr("class", "node").attr("transform", function (d) {  return "translate(" + d.x + "," + d.y + ")";  });' +
			'node.append("title").text(function (d) { return d.label + ": " + format(d.val); });' +
			'node.append("circle").attr("r", function (d) { return d.r; }).style("fill", function (d) { return color(d.label); });' +
			'node.append("text") .attr("dy", ".3em").style("text-anchor", "middle").text(function (d) { return d.label.substring(0, d.r / 3); });', 
			'Bubble',
			500, 
			520, 
			pieData
		}], pieMetaRecord);
				 
		export _output := output(pieMetaData);
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