import SampleData.Cars;
import Bundles.d3;

r := record
    varstring geo__javascript;
    dataset(Cars.CarsRecord) cars;
    varstring pc__javascript;
end;

d3Chart := d3.Chart('cars', 'name', 'unused');
d := dataset([{'document.write("<iframe height=\'420\' width=\'620\' frameborder=\'0\' src=\'https://render.github.com/view/geojson?url=https://raw.github.com/benbalter/dc-wifi-social/master/bars.geojson\'></iframe>")', Cars.CarsDataset, d3Chart.ParallelCoordinates}], r);
d;



