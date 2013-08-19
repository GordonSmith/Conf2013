define([
  "dojo/_base/declare",
  "dojo/_base/lang",
  "dojo/_base/array",
  "dojo/dom",
  "dojo/NodeList-manipulate",
  "dojo/promise/all",
  "hpcc/ESPWorkunit"
], function (declare, lang, arrayUtil, dom, NodeListManipulate, all, ESPWorkunit) {
    var DojoD3 = declare(null, {
        constructor: function () {
        },
        mixinTarget: function (_target) {
            var retVal = lang.mixin({
                domNode: "",
                width: 500,
                height: 500
            }, _target);
            lang.mixin(retVal, {
                diameter: Math.min(retVal.width, retVal.height)
            });
            lang.mixin(retVal, {
                radius: retVal.diameter / 2
            });
            return retVal;
        },
        delegateItem: function (item, mappings) {
            if (!item)
                return item;

            var retVal = {};
            for (key in mappings) {
                if (lang.exists(mappings[key], item)) {
                    if (Object.prototype.toString.call(item[mappings[key]]) === '[object Array]') {
                        retVal[key] = this.delegateArray(item[mappings[key]], mappings);
                    } else if (!isNaN(parseInt(item[mappings[key]]))) {
                        retVal[key] = parseInt(item[mappings[key]]);
                    } else {
                        retVal[key] = item[mappings[key]];
                    }
                }
            }
            return retVal;
            /*
            return lang.delegate(item, {
                label: item[mappings.label],
                value: +item[mappings.value],
                children: this.delegateArray(item[mappings.children], mappings)
            });
            */
        },

        delegateArray: function (arr, mappings) {
            if (!arr)
                return arr;

            return arr.map(lang.hitch(this, function (item) {
                return this.delegateItem(item, mappings);
            }));
        }
    });

    var DojoD3Tree = declare(DojoD3, {
        tree: null,
        constructor: function (title, tree, mappings) {
            if (tree.length == 1) {
                this.tree = this.delegateItem(lang.clone(tree[0]), mappings);
            } else {
                this.tree = {
                    label: title,
                    children: this.delegateArray(lang.clone(tree), mappings)
                };
            }
        },

        ClusterDendrogram: function (_target) {
            var target = this.mixinTarget(_target);

            var cluster = d3.layout.cluster().size([target.height, target.width - 160]);
            var diagonal = d3.svg.diagonal().projection(function (e) {
                return [e.y, e.x]
            });
            var svg = d3.select(target.domNode).append("svg").attr("width", target.width).attr("height", target.height).append("g").style("font", "10px sans-serif").attr("transform", "translate(40,0)");
            var nodes = cluster.nodes(this.tree);
            var links = cluster.links(nodes);
            var link = svg.selectAll(".link").data(links).enter().append("path").style("fill", "none").style("stroke", "#ccc").style("stroke-width", "1.5px").attr("d", diagonal);
            var node = svg.selectAll(".node").data(nodes).enter().append("g").attr("transform", function (e) {
                return "translate(" + e.y + "," + e.x + ")"
            });
            node.append("circle").style("fill", "#fff").style("stroke", "steelBlue").style("stroke-width", "1.5px").attr("r", 4.5);
            node.append("text").attr("dx", function (e) {
                return e.children ? -8 : 8
            }).attr("dy", 3).style("text-anchor", function (e) {
                return e.children ? "end" : "start"
            }).text(function (e) {
                return e.label;
            });
        },
        ReingoldTilfordTree: function (_target) {
            var target = this.mixinTarget(_target);

            var tree = d3.layout.tree().size([360, target.radius - 20]).separation(function (e, t) {
                return (e.parent == t.parent ? 1 : 2) / e.depth
            });
            var diagonal = d3.svg.diagonal.radial().projection(function (e) {
                return [e.y, e.x / 180 * Math.PI]
            });
            var svg = d3.select(target.domNode).append("svg").attr("width", target.diameter).attr("height", target.diameter).append("g").style("font", "10px sans-serif").attr("transform", "translate(" + target.radius + "," + target.radius + ")");
            var nodes = tree.nodes(this.tree), links = tree.links(nodes);
            var link = svg.selectAll(".link").data(links).enter().append("path").attr("d", diagonal).style("fill", "none").style("stroke", "#ccc").style("stroke-width", "1.5px;");
            var node = svg.selectAll(".node").data(nodes).enter().append("g").attr("transform", function (e) {
                return "rotate(" + (e.x - 90) + ")translate(" + e.y + ")"
            });
            node.append("circle").attr("r", 4.5).style("fill", "#fff").style("stroke", "steelblue").style("stroke-width", "1.5px");
            node.append("text").attr("dy", ".31em").attr("text-anchor", function (e) {
                return e.x < 180 ? "start" : "end"
            }).attr("transform", function (e) {
                return e.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"
            }).text(function (e) {
                return e.label
            });
        },
        CirclePacking: function (_target) {
            var target = this.mixinTarget(_target);
            var diameter = target.width, format = d3.format(",d");
            var pack = d3.layout.pack().size([diameter - 4, diameter - 4]);
            var svg = d3.select(target.domNode).append("svg").attr("width", diameter).attr("height", diameter).append("g").style("font", "10px sans-serif").attr("transform", "translate(2,2)");
            var node = svg.datum(this.tree).selectAll(".node").data(pack.nodes).enter().append("g").style("fill", function (e) {
                return e.children ? "rgb(31, 119, 180)" : "#ff7f0e"
            }).style("fill-opacity", function (e) {
                return e.children ? " .25" : "1"
            }).style("stroke", "rgb(31, 119, 180)").style("stroke-width", "1px").attr("transform", function (e) {
                return "translate(" + e.x + "," + e.y + ")"
            });
            node.append("title").text(function (e) {
                return e.label + e.children ? "" : ": " + format(e.value)
            });
            node.append("circle").attr("r", function (e) {
                return e.r
            });
            node.filter(function (e) {
                return !e.children
            }).append("text").attr("dy", ".3em").style("text-anchor", "middle").style("fill", "black").style("stroke", "none").text(function (e) {
                return e.label.substring(0, e.r / 3)
            });
        },
        SunburstPartition: function (_target) {
            var target = this.mixinTarget(_target);

            function computeTextRotation(e) {
                var t = x(e.x + e.dx / 2) - Math.PI / 2;
                return t / Math.PI * 180
            }
            var x = d3.scale.linear().range([0, 2 * Math.PI]);
            var y = d3.scale.sqrt().range([0, target.radius]);
            var color = d3.scale.category20c();
            var svg = d3.select(target.domNode).append("svg").attr("width", target.width).attr("height", target.height).append("g").style("font", "10px sans-serif").attr("transform", "translate(" + target.width / 2 + "," + (target.height / 2 + 10) + ")");
            var partition = d3.layout.partition();
            var arc = d3.svg.arc().startAngle(function (e) {
                return Math.max(0, Math.min(2 * Math.PI, x(e.x)))
            }).endAngle(function (e) {
                return Math.max(0, Math.min(2 * Math.PI, x(e.x + e.dx)))
            }).innerRadius(function (e) {
                return Math.max(0, y(e.y))
            }).outerRadius(function (e) {
                return Math.max(0, y(e.y + e.dy))
            });
            var g = svg.selectAll("g").data(partition.nodes(this.tree)).enter().append("g");
            var path = g.append("path").attr("d", arc).style("fill", function (e) {
                return color(e.children ? e.label : e.parent.label)
            }).style("stroke", "#fff").style("fill-rule", "evenodd");
            var text = g.append("text").attr("x", function (e) {
                return y(e.y)
            }).attr("dx", "6").attr("dy", ".35em").text(function (e) {
                return e.label;
            });
            text.attr("transform", function (e) {
                return "rotate(" + computeTextRotation(e) + ")"
            });
        }
    });
    var DojoD3Graph = declare(DojoD3, {
        vertices: null,
        edges: null,
        constructor: function (title, vertices, vMappings, edges, eMappings) {
            this.vertices = this.delegateArray(lang.clone(vertices), vMappings);
            this.edges = this.delegateArray(lang.clone(edges), eMappings);
        },
        ForceDirected: function (_target) {
            var target = this.mixinTarget(_target);
            var color = d3.scale.category20();
            var force = d3.layout.force().charge(-120).linkDistance(30).size([target.width, target.height]);
            var svg = d3.select(target.domNode).append("svg").attr("width", target.width).attr("height", target.height).append("g");
            force.nodes(this.vertices).links(this.edges);
            var link = svg.selectAll(".linkFD").data(this.edges).enter().append("line").style("stroke-width", function (e) {
                return Math.sqrt(e.weight)
            }).style("stroke", "#999").style("stroke-opacity", ".6");
            var node = svg.selectAll(".nodeFD").data(this.vertices).enter().append("circle").attr("r", 5).style("fill", function (e) {
                return color(e.category)
            }).style("stroke", "#fff").style("stroke-width", "1.5px").call(force.drag);
            node.append("title").text(function (e) {
                return e.name
            });
            force.on("tick", function () {
                link.attr("x1", function (e) {
                    return e.source.x
                }).attr("y1", function (e) {
                    return e.source.y
                }).attr("x2", function (e) {
                    return e.target.x
                }).attr("y2", function (e) {
                    return e.target.y
                });
                node.attr("cx", function (e) {
                    return e.x
                }).attr("cy", function (e) {
                    return e.y
                })
            });
            var n = this.vertices.length;
            arrayUtil.forEach(this.vertices, function (e, t) {
                e.x = e.y = target.width / n * t
            });
            force.start();
            for (var i = n; i > 0; --i) {
                force.tick()
            }
            force.stop();
        }
    });
    return {
        Tree: DojoD3Tree,
        Graph: DojoD3Graph,
        ForceDirected: function (_target, _data) {
            //  Boiler Plate ---
            var target = {
                domNode: "",
                width: 500,
                height: 500
            };
            lang.mixin(target, _target);
            var data = {
                vertices: [],
                vertexName: "name",
                vertexCategory: "category",
                edges: [],
                edgeSource: "source",
                edgeTarget: "target",
                edgeWeight: "weight"
            };
            lang.mixin(data, _data);
            var __verticesData = lang.clone(data.vertices).map(function (e) {
                e.name = e[data.vertexName];
                e.category = e[data.vertexCategory];
                return e;
            });
            var __edgesData = lang.clone(data.edges).map(function (e) {
                e.source = +e[data.edgeSource];
                e.target = +e[data.edgeTarget];
                e.weight = +e[data.edgeWeight];
                return e;
            });
            //  Viz Specific ---
            var color = d3.scale.category20();
            var force = d3.layout.force().charge(-120).linkDistance(30).size([target.width, target.height]);
            var svg = d3.select(target.domNode).append("svg").attr("width", target.width).attr("height", target.height).append("g");
            force.nodes(__verticesData).links(__edgesData);
            var link = svg.selectAll(".linkFD").data(__edgesData).enter().append("line").style("stroke-width", function (e) {
                return Math.sqrt(e.weight);
            }).style("stroke", "#999").style("stroke-opacity", ".6");
            var node = svg.selectAll(".nodeFD").data(__verticesData).enter().append("circle").attr("r", 5).style("fill", function (e) {
                return color(e.category);
            }).style("stroke", "#fff").style("stroke-width", "1.5px").call(force.drag);
            node.append("title").text(function (e) {
                return e.name;
            });
            force.on("tick", function () {
                link.attr("x1", function (e) {
                    return e.source.x;
                }).attr("y1", function (e) {
                    return e.source.y;
                }).attr("x2", function (e) {
                    return e.target.x;
                }).attr("y2", function (e) {
                    return e.target.y;
                });
                node.attr("cx", function (e) {
                    return e.x;
                }).attr("cy", function (e) {
                    return e.y;
                });
            });
            var n = __verticesData.length;
            arrayUtil.forEach(__verticesData, function (e, t) {
                e.x = e.y = target.width / n * t;
            });
            force.start();
            for (var i = n; i > 0; --i) {
                force.tick();
            }
            force.stop();
        },
        CoOccurrence: function (_target, _data) {
            //  Boiler Plate ---
            var target = {
                domNode: "",
                width: 500,
                height: 500
            };
            lang.mixin(target, _target);
            var data = {
                vertices: [],
                vertexName: "name",
                vertexCategory: "category",
                edges: [],
                edgeSource: "source",
                edgeTarget: "target",
                edgeWeight: "weight"
            };
            lang.mixin(data, _data);
            var __verticesData = lang.clone(data.vertices).map(function (e) {
                e.name = e[data.vertexName];
                e.category = e[data.vertexCategory];
                return e;
            });
            var __edgesData = lang.clone(data.edges).map(function (e) {
                e.source = +e[data.edgeSource];
                e.target = +e[data.edgeTarget];
                e.weight = +e[data.edgeWeight];
                return e;
            });
            //  Viz Specific ---
            function row(e) {
                var t = d3.select(this).selectAll(".cell").data(e.filter(function (e) {
                    return e.z
                })).enter().append("rect").attr("class", "cell").attr("x", function (e) {
                    return x(e.x)
                }).attr("width", x.rangeBand()).attr("height", x.rangeBand()).style("fill-opacity", function (e) {
                    return z(e.z)
                }).style("fill", function (e) {
                    return nodes[e.x].category == nodes[e.y].category ? c(nodes[e.x].category) : null
                }).on("mouseover", mouseover).on("mouseout", mouseout)
            }
            function mouseover(e) {
                d3.selectAll(".row text").classed("active", function (t, n) {
                    return n == e.y
                });
                d3.selectAll(".column text").classed("active", function (t, n) {
                    return n == e.x
                })
            }
            function mouseout() {
                d3.selectAll("text").classed("active", false)
            }
            function order(e) {
                x.domain(orders[e]);
                var t = svg.transition().duration(2500);
                t.selectAll(".row").delay(function (e, t) {
                    return x(t) * 4
                }).attr("transform", function (e, t) {
                    return "translate(0," + x(t) + ")"
                }).selectAll(".cell").delay(function (e) {
                    return x(e.x) * 4
                }).attr("x", function (e) {
                    return x(e.x)
                });
                t.selectAll(".column").delay(function (e, t) {
                    return x(t) * 4
                }).attr("transform", function (e, t) {
                    return "translate(" + x(t) + ")rotate(-90)"
                })
            }

            dojo.query("head").append("<style>text.active { fill: red; } </style>");
            var margin = {
                top: 100,
                right: 10,
                bottom: 10,
                left: 100
            };
            target.width -= (margin.left + margin.right);
            target.height -= (margin.top + margin.bottom);
            var x = d3.scale.ordinal().rangeBands([0, target.width]), z = d3.scale.linear().domain([0, 4]).clamp(true), c = d3.scale.category10().domain(d3.range(10));
            var svg = d3.select(target.domNode).append("svg").attr("width", target.width).attr("height", target.height + margin.top + margin.bottom).style("margin-left", 0 + "px").append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
            var matrix = [], nodes = __verticesData, n = nodes.length;
            nodes.forEach(function (e, t) {
                e.index = t;
                e.count = 0;
                matrix[t] = d3.range(n).map(function (e) {
                    return {
                        x: e,
                        y: t,
                        z: 0
                    }
                })
            });
            __edgesData.forEach(function (e) {
                matrix[e.source][e.target].z += e.weight;
                matrix[e.target][e.source].z += e.weight;
                matrix[e.source][e.source].z += e.weight;
                matrix[e.target][e.target].z += e.weight;
                nodes[e.source].count += e.weight;
                nodes[e.target].count += e.weight
            });
            var orders = {
                name: d3.range(n).sort(function (e, t) {
                    return d3.ascending(nodes[e].name, nodes[t].name)
                }),
                count: d3.range(n).sort(function (e, t) {
                    return nodes[t].count - nodes[e].count
                }),
                category: d3.range(n).sort(function (e, t) {
                    return nodes[t].category - nodes[e].category
                })
            };
            x.domain(orders.category);
            svg.append("rect").attr("width", target.width).attr("height", target.height).style("fill", "#eee");
            var row = svg.selectAll(".row").data(matrix).enter().append("g").attr("class", "row").attr("transform", function (e, t) {
                return "translate(0," + x(t) + ")";
            }).each(row);
            row.append("line").attr("x2", target.width).style("stroke", "#fff");
            row.append("text").attr("x", -6).attr("y", x.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "end").text(function (e, t) {
                return nodes[t].name;
            });
            var column = svg.selectAll(".column").data(matrix).enter().append("g").attr("class", "column").attr("transform", function (e, t) {
                return "translate(" + x(t) + ")rotate(-90)";
            });
            column.append("line").attr("x1", -target.width).style("stroke", "#fff");
            column.append("text").attr("x", 6).attr("y", x.rangeBand() / 2).attr("dy", ".32em").attr("text-anchor", "start").text(function (e, t) {
                return nodes[t].name;
            });
            /*
            d3.select("#order").on("change", function () {
                clearTimeout(timeout);
                order(this.weight);
            });
            */
        }
    };
});
