import CellFormatter;
import GenData;

CityRecord := record
  string2 state;
  qstring5 zip;
  string1 name;
  integer size;
end;

CityRecord toCity(GenData.Layout_Person L) := transform
  self.name := L.middleinitial;
  self.size := 1001;
  SELF := L;
end;

cities := project(dedup(sort(GenData.Dataset_Person, state, zip, middleinitial), state, zip, middleinitial), toCity(LEFT));
//cities;

ZipRecord := record
  string2 state;
  qstring5 name;
  dataset(CityRecord) children;
end;

ZipRecord DeNormCities(GenData.Layout_Person L, dataset(CityRecord) R2) := transform
    self.state := L.state;
    self.name := L.zip;
    self.children := choosen(R2, 5);
    self := L;
end;

zips := dedup(sort(GenData.Dataset_Person, state, zip), state, zip);
zipCities := DENORMALIZE(zips, cities, LEFT.zip = RIGHT.zip, GROUP, DeNormCities(LEFT,ROWS(RIGHT)));
//zipCities;

StateRecord := record
  string2 name;
  dataset(ZipRecord) children;
end;

StateRecord DeNormZips(GenData.Layout_Person L, dataset(ZipRecord) R3) := TRANSFORM
  self.name := L.state;
  self.children := choosen(R3, 4);
  self := L;
end;

states := dedup(sort(GenData.Dataset_Person, state), state);
stateZips := DENORMALIZE(states, zipCities, LEFT.state = RIGHT.state, GROUP, DeNormZips(LEFT,ROWS(RIGHT)));
stateZips;

Viz_Layout := record
  string12 country;
  dataset(StateRecord) _data__hidden;
  varstring pie__javascript;
end;

d3 := CellFormatter.d3('_data__hidden', 'middleinitial', 'stat');
dataset([{'USA', choosen(stateZips, 3), d3.CirclePacking}], Viz_Layout);
