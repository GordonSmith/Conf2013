import $.CellFormatter;
import GenData;

Viz_Layout := record
  string2 state;
  integer NumRows;
  dataset(GenData.StateInitial_Layout) _data__hiddenX;
  varstring pie__javascript;
  varstring bubble__javascript;
end;

states := dedup(sort(GenData.Dataset_Person, state), state);

d3 := CellFormatter.d3('_data__hiddenx', 'middleinitial', 'stat');
Viz_Layout TransStates(GenData.Layout_Person L) := TRANSFORM
	SELF.NumRows := 0;
	SELF._data__hiddenX := [];
    SELF.pie__javascript := d3.pie;
    SELF.bubble__javascript := d3.bubble;
	SELF := L;
END;

vizStates := project(states, TransStates(LEFT));

Viz_Layout DeNormStates(Viz_Layout L, dataset(GenData.StateInitial_Layout) R) := TRANSFORM
	SELF.NumRows := count(R);
	SELF._data__hiddenX := R;
	SELF := L;
END;

DeNormedRecs := DENORMALIZE(vizStates, GenData.StateInitial_Rollup, LEFT.state = RIGHT.state, GROUP, DeNormStates(LEFT,ROWS(RIGHT)));
DeNormedRecs;

/*

d2 := dataset([
	{'FL', GenData.StateInitial_Rollup(state='FL'), d3.pie, d3.bubble},
	{'AL', GenData.StateInitial_Rollup(state='AL'), d3.pie, d3.bubble},
	{'FL', GenData.StateInitial_Rollup(state='FL'), d3.pie, d3.bubble}
	], Viz_Layout);

d2;
*/

/*
StateTable := table(PeopleDataset, {state});
States := dedup(sort(StateTable, RECORD), RECORD);
States;

ZipRecord := record
	string2 state;
	qstring2 zip2;
end;

ZipRecord zip2Trans(PeopleRecord L) := transform
	self.state := L.state;
	self.zip2 := L.zip[1..2];
end;

ZipTable := project(PeopleDataset, zip2Trans(LEFT));
Zips := dedup(sort(ZipTable, RECORD), RECORD);
count(Zips);
Zips;

OutRecord := record
  string2 state;
	dataset(PeopleRecord) people;
end;
*/
/*

CityRecord := record
  qstring20 city;
	dataset(PeopleRecord) 
end;

ZipRecord := record
  qstring5 zip;
	//dataset(CityRecord) cities;
end;

StatesRecord := record
  string2 state;
	dataset(ZipRecord) zips;
end;

SortedPeople := SORT(PeopleDataset, state, zip); //sort it first

StatesRecord denormPeople(PeopleRec L) := transform
end;

StatesDataset := 
 
PepoleStatsRecord := RECORD
	PeopleRecord;
  INTEGER4 stat;
END;

PepoleStatsRecord PrimeStats(PeopleRecord L) := TRANSFORM
  SELF.stat := 1;
  SELF := L;
END;

PepoleStatsDataset := project(PeopleDataset, PrimeStats(LEFT));

LnameTable := TABLE(PeopleDataset, MyRec); //create dataset to work with
SortedTable := SORT(PeopleDataset, state, middleinitial); //sort it first

MyRec Xform(MyRec L, MyRec R) := TRANSFORM
  SELF.PersonCount := L.PersonCount + 1;
  SELF := L;
END;

XtabOut := ROLLUP(SortedTable(state='FL'), LEFT.middleinitial=RIGHT.middleinitial, Xform(LEFT,RIGHT)); 

r2 := record
  string10 id;
	dataset(MyRec) _data__hiddenX;
	varstring pie__javascript;
	varstring bubble__javascript;
end;

d3 := CellFormatter.d3('_data__hiddenX', 'middleinitial', 'personcount');
d2 := dataset([{'1', XtabOut, d3.pie, d3.bubble}], r2);
d2;
//D3Bundle.pie(XtabOut, middleinitial, PersonCount)._output;
//D3Bundle.bubble(XtabOut, middleinitial, PersonCount)._output;
//D3Bundle.pie(XtabOut, middleinitial, PersonCount)._output;
*/