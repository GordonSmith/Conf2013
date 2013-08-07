s :=   record
    string50 a;
    string50 b;
  end;

r := record
	s c;
    string50 d;
    string50 e;
end;

d := dataset([{{'a', 'b'}, 'd', 'e'}], r);
d;