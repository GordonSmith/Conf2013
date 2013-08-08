import SampleData.Miserables;
import Bundles.d3;

graphRecord := record
  dataset(Miserables.VertexRecord) vertices__hidden;
  dataset(Miserables.EdgeRecord) edges__hidden;
  varstring fd__javascript;
  varstring CoOccurrence__javascript;  
  //varstring fd__js;
end;

d3Graph := d3.Graph('vertices__hidden', 'name', 'category', 'edges__hidden', 'source', 'target', 'weight');
graphDataset := dataset([{Miserables.VertexDataset, Miserables.EdgeDataset, d3Graph.ForceDirected, d3Graph.CoOccurrence}], graphRecord);
graphDataset;
