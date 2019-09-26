unit test_harness;

interface
uses sysutils;

type
  ProcArray =  array of procedure;

procedure Summary;
procedure FinalSummary;
procedure TestCase(msg: string);
procedure Test(msg: string; var condition: boolean);
procedure RunTests(tests: ProcArray);

implementation

var
  nPass,nFail,nTotalPass,nTotalFail: integer;

procedure Summary;
begin
  writeln('  Passed: ',nPass);
  writeln('  Failed: ',nFail);
end;

procedure FinalSummary;
begin
  if ((nPass > 0) or (nFail > 0)) then
    Summary();
  nTotalPass := nTotalPass + nPass;
  nTotalFail := nTotalFail + nFail;
  writeln();
  writeln('  Total Passed: ',nTotalPass);
  writeln('  Total Failed: ',nTotalFail);
end;

procedure TestCase(msg: string);
begin
  if ((nPass > 0) or (nFail > 0)) then
  begin
    Summary();
    nTotalPass := nTotalPass + nPass;
    nTotalFail := nTotalFail + nFail;
    nPass := 0;
    nFail := 0;
    writeln;
  end;
  writeln(msg);
end;

procedure Test(msg: string; var condition: boolean);
  var
    pass_fail: string;
begin
  if (condition) then
    begin
      nPass := nPass + 1;
      pass_fail := 'pass';
    end
  else
    begin
      nFail := nFail + 1;
      pass_fail := 'fail';
    end;
  writeln('  ',msg,'...',pass_fail);
end;

procedure RunTests(tests: ProcArray);
  var i,itest: integer;
begin
  nPass := 0;
  nFail := 0;
  nTotalPass := 0;
  nTotalFail := 0;
  if paramcount > 0 then
  begin
    for i := 1 to paramcount do
    begin
      itest := StrToInt(ParamStr(i));
      if itest < length(tests) then
        tests[itest]()
      else
        writeln('No test for ',itest);
    end;
  end
  else
  begin
    for i := 0 to high(tests) do
      tests[i]();
  end;
  FinalSummary();

end;

end.
