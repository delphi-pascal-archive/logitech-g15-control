program G15Demo;

uses
  Forms,
  uG15demo in 'uG15demo.pas' {Form1},
  uG15 in 'uG15.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
