export Layout_Person := RECORD
  UNSIGNED3 PersonID;
  QSTRING15 FirstName;
  QSTRING25 LastName;
  STRING1   MiddleInitial;
  STRING1   Gender;
  QSTRING42 Street;
  QSTRING20 City;
  STRING2   State;
  QSTRING5  Zip;
END;

