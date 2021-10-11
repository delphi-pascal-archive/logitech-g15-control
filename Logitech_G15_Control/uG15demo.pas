unit uG15demo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, uG15;

type
  TForm1 = class(TForm)
    lbG15Panel: TLabel;
    gbKeyLight: TGroupBox;
    rbKeyOff: TRadioButton;
    rbKeyLow: TRadioButton;
    rbKeyHigh: TRadioButton;
    gbLCD: TGroupBox;
    rbLCDOff: TRadioButton;
    rbLCDLow: TRadioButton;
    rbLCDHigh: TRadioButton;
    gbMKeys: TGroupBox;
    cbM1: TCheckBox;
    cbM2: TCheckBox;
    cbM3: TCheckBox;
    cbMR: TCheckBox;
    tbContrast: TTrackBar;
    lbContrast: TLabel;
    btLogo: TButton;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure rbKeyLightClick(Sender: TObject);
    procedure rbLCDLightClick(Sender: TObject);
    procedure cbMKeysClick(Sender: TObject);
    procedure tbContrastChange(Sender: TObject);
    procedure btLogoClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    G15: TG15;
    procedure G15Detected(Sender: TObject);
    procedure KeyboardBacklightChange(Sender: TObject);
    procedure LCDBacklightChange(Sender: TObject);
    procedure MKeyLightChange(Sender: TObject; MKey: TG15SpecialKey);
    procedure SpecialKeyPress(Sender: TObject; Key: TG15SpecialKey);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  G15:=TG15.Create(Self);
  G15.OnKeyboardBacklightChange:=KeyboardBacklightChange;
  G15.OnLCDBacklightChange:=LCDBacklightChange;
  G15.OnMKeyLightChange:=MKeyLightChange;
  G15.OnG15Detected:=G15Detected;
  G15.OnSpecialKeyPress:=SpecialKeyPress;

  KeyboardBacklightChange(Self);
  LCDBacklightChange(Self);
end;

procedure TForm1.rbKeyLightClick(Sender: TObject);
begin
  G15.KeyboardBacklight:=TG15Backlight(TComponent(Sender).Tag);
end;

procedure TForm1.rbLCDLightClick(Sender: TObject);
begin
  G15.LCDBacklight:=TG15Backlight(TComponent(Sender).Tag);
end;

procedure TForm1.cbMKeysClick(Sender: TObject);
begin
  G15.M1Light:=G15LightBoolean[cbM1.Checked];
  G15.M2Light:=G15LightBoolean[cbM2.Checked];
  G15.M3Light:=G15LightBoolean[cbM3.Checked];
  G15.MRLight:=G15LightBoolean[cbMR.Checked];
end;

procedure TForm1.tbContrastChange(Sender: TObject);
begin
  G15.Contrast:=tbContrast.Position;
end;

procedure TForm1.btLogoClick(Sender: TObject);
begin
  G15.ShowG15Logo;
end;

procedure TForm1.G15Detected(Sender: TObject);
var
  i,j: Integer;
begin
  lbG15Panel.Caption:='G15Panel: OK';
  for i:=0 to ControlCount-1 do
   begin
     Controls[i].Enabled:=True;
     if Controls[i] is TGroupBox then
      With (Controls[i] as TGroupBox) do
       for j:=0 to ControlCount-1 do Controls[j].Enabled:=True;
   end;
end;

procedure TForm1.KeyboardBacklightChange(Sender: TObject);
begin
  Case G15.KeyboardBacklight of
   gblOff: rbKeyOff.Checked:=True;
   gblLow: rbKeyLow.Checked:=True;
   gblHigh: rbKeyHigh.Checked:=True;
  end;
end;

procedure TForm1.LCDBacklightChange(Sender: TObject);
begin
  Case G15.LCDBacklight of
   gblOff: rbLCDOff.Checked:=True;
   gblLow: rbLCDLow.Checked:=True;
   gblHigh: rbLCDHigh.Checked:=True;
  end;
end;

procedure TForm1.MKeyLightChange(Sender: TObject; MKey: TG15SpecialKey);
begin
  cbM1.Checked:=(G15.M1Light=gltOn);
  cbM2.Checked:=(G15.M2Light=gltOn);
  cbM3.Checked:=(G15.M3Light=gltOn);
  cbMR.Checked:=(G15.MRLight=gltOn);
end;

procedure TForm1.SpecialKeyPress(Sender: TObject; Key: TG15SpecialKey);
begin
  Memo1.Lines.Add('Appuie sur la touche "' + G15SpecialKeyName[Key] + '"')
end;

end.
