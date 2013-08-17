import SampleData.Miserables;
import Bundles.d3;

graphRecord := record
  dataset(Miserables.VertexRecord) vertices;
  dataset(Miserables.EdgeRecord) edges;
  varstring fd__400__javascript;
  varstring CoOccurrence__1000__javascript;  
end;

output(Miserables.VertexDataset, named('Miserables_Verticies'));
output(Miserables.EdgeDataset, named('Miserables_Edges'));

d3Graph := d3.Graph('vertices', 'name', 'category', 'edges', 'source', 'target', 'weight');
dataset([{Miserables.VertexDataset, Miserables.EdgeDataset, d3Graph.ForceDirected, d3Graph.CoOccurrence}], graphRecord);
