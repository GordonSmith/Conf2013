import SampleData.Miserables;
import Bundles.CellFormatter;

graphRecord := record
  dataset(Miserables.VertexRecord) vertices;
  dataset(Miserables.EdgeRecord) edges;
  varstring fd__javascript;
  varstring fd__js;
end;

d3 := CellFormatter.d3Graph('vertices', 'name', 'category', 'edges', 'source', 'target', 'weight');
graphDataset := dataset([{Miserables.VertexDataset, Miserables.EdgeDataset, d3.ForceDirected, d3.ForceDirected}], graphRecord);
graphDataset;
