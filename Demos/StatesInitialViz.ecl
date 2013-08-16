import Bundles.d3;
import SampleData.GenData;

states := dedup(sort(GenData.Dataset_Person, state), state);

Viz_Layout := record
  string2 state;
  integer NumRows;
  dataset(GenData.StateInitial_Layout) _data;
  varstring bar__javascript;
  varstring pie__javascript;
  varstring bubble__javascript;
end;

d3Chart := d3.Chart('_data', 'middleinitial', 'stat');
Viz_Layout TransStates(GenData.Layout_Person L) := TRANSFORM
	SELF.NumRows := 0;
	SELF._data := [];
    SELF.bar__javascript := d3Chart.BarChart;
    SELF.pie__javascript := d3Chart.pie;
    SELF.bubble__javascript := d3Chart.bubble;
	SELF := L;
END;

vizStates := project(states, TransStates(LEFT));

Viz_Layout DeNormStates(Viz_Layout L, dataset(GenData.StateInitial_Layout) R) := TRANSFORM
	SELF.NumRows := count(R);
	SELF._data := R;
	SELF := L;
END;
states;
DENORMALIZE(vizStates, GenData.StateInitial_Rollup, LEFT.state = RIGHT.state, GROUP, DeNormStates(LEFT,ROWS(RIGHT)));

