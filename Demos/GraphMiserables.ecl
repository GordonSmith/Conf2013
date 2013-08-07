import SampleData.Miserables;
import Bundles.d3;

graphRecord := record
  dataset(Miserables.VertexRecord) vertices;
  dataset(Miserables.EdgeRecord) edges;
  varstring fd__javascript;
  varstring fd__js;
end;

d3Graph := d3.Graph('vertices', 'name', 'category', 'edges', 'source', 'target', 'weight');
graphDataset := dataset([{Miserables.VertexDataset, Miserables.EdgeDataset, d3Graph.ForceDirected, d3Graph.ForceDirected}], graphRecord);
graphDataset;
