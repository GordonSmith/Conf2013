import CellFormatter;
import GenData;

states := dedup(sort(GenData.Dataset_Person, state), state);

Viz_Layout := record
  string2 state;
  integer NumRows;
  dataset(GenData.StateInitial_Layout) _data__hidden;
  varstring pie__javascript;
  varstring bubble__javascript;
end;

d3 := CellFormatter.d3('_data__hidden', 'middleinitial', 'stat');
Viz_Layout TransStates(GenData.Layout_Person L) := TRANSFORM
	SELF.NumRows := 0;
	SELF._data__hidden := [];
    SELF.pie__javascript := d3.pie;
    SELF.bubble__javascript := d3.bubble;
	SELF := L;
END;

vizStates := project(states, TransStates(LEFT));

Viz_Layout DeNormStates(Viz_Layout L, dataset(GenData.StateInitial_Layout) R) := TRANSFORM
	SELF.NumRows := count(R);
	SELF._data__hidden := R;
	SELF := L;
END;

DENORMALIZE(vizStates, GenData.StateInitial_Rollup, LEFT.state = RIGHT.state, GROUP, DeNormStates(LEFT,ROWS(RIGHT)));
