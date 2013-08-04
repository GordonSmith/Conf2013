import $;

$.StateInitial_Layout PrimeStats($.Layout_Person L) := TRANSFORM
  SELF.stat := 1;
  SELF := L;
END;

PeopleStatsDataset := project($.Dataset_Person, PrimeStats(LEFT));
SortedTable := SORT(PeopleStatsDataset, RECORD);

$.StateInitial_Layout calcStat($.StateInitial_Layout L, $.StateInitial_Layout R) := TRANSFORM
  SELF.stat := L.stat + 1;
  SELF := L;
END;

export StateInitial_Rollup := ROLLUP(SortedTable, calcStat(LEFT,RIGHT), state, middleinitial); 
