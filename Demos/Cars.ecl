import SampleData.Cars;
import Bundles.d3;

r := record
    dataset(Cars.CarsRecord) cars;
    varstring pc__javascript;
end;

d3Chart := d3.Chart('cars', 'name', 'unused');
d := dataset([{Cars.CarsDataset, d3Chart.ParallelCoordinates}], r);
d;
