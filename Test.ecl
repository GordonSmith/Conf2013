import SampleData.Cars;
import Bundles.d3;

r := record
    dataset(Cars.CarsRecord) cars;
    varstring pc__javascript;
end;

output(Cars.CarsDataset, named('cars'));

d3Chart := d3.Field_Population(Cars.CarsDataset);




