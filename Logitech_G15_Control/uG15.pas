{
  uG15.pas
  Gestionnaire de clavier G15 de Logitech

  Auteur: Delphitness (delphitness@gmail.com)
  Mise en garde:  l'auteur ne pourra être tenu pour responsable en cas
                  de détérioration du matériel suite à l'utilisation
                  (bonne ou mauvaise) de ce composant.
  Utilisation: - libre de droit pour un usage privé et pour les
                 applications gratuites.
                 Merci de faire figurer mon nom dans les crédits et
                 de m'en informer ;-)
               - utilisation et reproduction, même partielle,
                 INTERDITE sans la permission écrite de l'auteur
                 dans le cadre de logiciels commerciaux.
}

unit uG15;

interface

uses Classes, SysUtils, JvHidControllerClass;

type
  TG15Backlight = (gblOff, gblLow, gblHigh);
  TG15LightToggle = (gltOff, gltOn);
  TG15SpecialKey = (gskM1, gskM2, gskM3, gskMR, // touches "M"
                      gskG1, gskG2, gskG3, gskG4, gskG5, gskG6, // touches "G"
                      gskA, gskB, gskC, gskD, gskSwitch, // touches applet
                      gskLight // touche rétro-éclairage
                     );
  TG15SpecialKeyEvent = procedure(Sender: TObject; SpecialKey: TG15SpecialKey) of object;
  EG15Error = class(Exception);
  EG15ReadError = class(EG15Error);
  EG15WriteError = class(EG15Error);
  TG15 = class(TComponent)
  private
    FHidController: TJvHidDeviceController;
    FG15Panel: TJvHidDevice;
    FWriteBuffer: array[0..3] of Byte;
    FLightState: array[0..3] of Byte;
    FKeyboardBacklight: TG15Backlight;
    FLCDBacklight: TG15Backlight;
    FM1Light, FM2Light, FM3Light, FMRLight: TG15LightToggle;

    FOnG15Detected: TNotifyEvent;
    FOnG15Removed: TNotifyEvent;
    FOnKeyboardBacklightChange: TNotifyEvent;
    FOnLCDBacklightChange: TNotifyEvent;
    FOnMKeyLightChange: TG15SpecialKeyEvent;
    FOnSpecialKeyPress: TG15SpecialKeyEvent;

    procedure SetOnG15Detected(const Value: TNotifyEvent);
    procedure SetKeyboardBacklight(const Value: TG15Backlight);
    procedure SendCommand(b1, b2, b3, b4: Integer);
    procedure SetLCDBacklight(const Value: TG15Backlight);
    procedure SetM1Light(const Value: TG15LightToggle);
    procedure SetM2Light(const Value: TG15LightToggle);
    procedure SetM3Light(const Value: TG15LightToggle);
    procedure SetMRLight(const Value: TG15LightToggle);
    procedure SetContrast(const Value: Byte);
    function GetIsPresent: Boolean;
  protected
    procedure HidCtlArrival(HidDev: TJvHidDevice);
    procedure HidCtlRemoval(HidDev: TJvHidDevice);
    procedure HidData(HidDev: TJvHidDevice; ReportID: Byte; const Data: Pointer; Size: Word);
    procedure DoG15Detected;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateLightState;
    procedure ShowG15Logo;
  published
    property KeyboardBacklight: TG15Backlight
      read FKeyboardBacklight write SetKeyboardBacklight;
    property LCDBacklight: TG15Backlight read FLCDBacklight write SetLCDBacklight;
    property M1Light: TG15LightToggle read FM1Light write SetM1Light;
    property M2Light: TG15LightToggle read FM2Light write SetM2Light;
    property M3Light: TG15LightToggle read FM3Light write SetM3Light;
    property MRLight: TG15LightToggle read FMRLight write SetMRLight;
    property Contrast: Byte write SetContrast;
    property IsPresent: Boolean read GetIsPresent;

    property OnG15Detected: TNotifyEvent read FOnG15Detected write SetOnG15Detected;
    property OnG15Removed: TNotifyEvent read FOnG15Removed write FOnG15Removed;
    property OnKeyboardBacklightChange: TNotifyEvent
      read FOnKeyboardBacklightChange write FOnKeyboardBacklightChange;
    property OnLCDBacklightChange: TNotifyEvent
      read FOnLCDBacklightChange write FOnLCDBacklightChange;
    property OnMKeyLightChange: TG15SpecialKeyEvent
      read FOnMKeyLightChange write FOnMKeyLightChange;
    property OnSpecialKeyPress: TG15SpecialKeyEvent
      read FOnSpecialKeyPress write FOnSpecialKeyPress;
  end;

const
  G15LightBoolean: array[Boolean] of TG15LightToggle = (gltOff, gltOn);
  G15SpecialKeyName: array[TG15SpecialKey] of String =
    ('M1','M2','M3','MR','G1','G2','G3','G4','G5','G6',
     'A','B','C','D','Switch','Light');

implementation

{ TG15 }

constructor TG15.Create(AOwner: TComponent);
begin
  inherited;
  FHidController:=TJvHidDeviceController.Create(Self);
  FHidController.OnArrival:=HidCtlArrival;
  FHidController.OnRemoval:=HidCtlRemoval;
end;

destructor TG15.Destroy;
begin
  inherited;
end;

procedure TG15.DoG15Detected;
begin
  if Assigned(FOnG15Detected) then FOnG15Detected(Self);
end;

function TG15.GetIsPresent: Boolean;
begin
  Result:=Assigned(FG15Panel);
end;

procedure TG15.HidCtlArrival(HidDev: TJvHidDevice);
begin
  if (HidDev.ProductName = 'G15 GamePanel LCD') and (HidDev.Caps.FeatureReportByteLength>0) then
   begin
     FG15Panel:=HidDev;
     HidDev.CheckOut;
     HidDev.OnData:=HidData;
     HidDev.NumInputBuffers:=128;
     HidDev.NumOverlappedBuffers:=128;
     DoG15Detected;
     UpdateLightState;
   end;
end;

procedure TG15.HidCtlRemoval(HidDev: TJvHidDevice);
begin
  if HidDev = FG15Panel then
   begin
     FG15Panel:=nil;
     if Assigned(FOnG15Removed) then FOnG15Removed(Self);
   end;
end;

procedure TG15.HidData(HidDev: TJvHidDevice; ReportID: Byte;
  const Data: Pointer; Size: Word);
var
  b1,b2: Byte;
begin
  if (ReportID<>2) or (Size<2) then Exit;
  b1:=Byte(PChar(Data)[0]);
  b2:=Byte(PChar(Data)[1]);
  if Assigned(FOnSpecialKeyPress) then
   begin
     Case b1 of
      1  : FOnSpecialKeyPress(Self,gskG1);
      2  : FOnSpecialKeyPress(Self,gskG2);
      4  : FOnSpecialKeyPress(Self,gskG3);
      8  : FOnSpecialKeyPress(Self,gskG4);
      16 : FOnSpecialKeyPress(Self,gskG5);
      32 : FOnSpecialKeyPress(Self,gskG6);
      64 : FOnSpecialKeyPress(Self,gskM1);
      128: FOnSpecialKeyPress(Self,gskM2);
     end;
     Case b2 of
      1  : FOnSpecialKeyPress(Self,gskLight);
      2  : FOnSpecialKeyPress(Self,gskA);
      4  : FOnSpecialKeyPress(Self,gskB);
      8  : FOnSpecialKeyPress(Self,gskC);
      16 : FOnSpecialKeyPress(Self,gskD);
      32 : FOnSpecialKeyPress(Self,gskM3);
      64 : FOnSpecialKeyPress(Self,gskMR);
      128: FOnSpecialKeyPress(Self,gskSwitch);
     end;
   end;
  UpdateLightState;
end;

procedure TG15.SendCommand(b1, b2, b3, b4: Integer);
begin
  if not Assigned(FG15Panel) then Exit;
  FWriteBuffer[0]:=b1;
  FWriteBuffer[1]:=b2;
  FWriteBuffer[2]:=b3;
  FWriteBuffer[3]:=b4;
  if not FG15Panel.SetFeature(FWriteBuffer[0],4) then
   Raise EG15WriteError.Create(SysErrorMessage(GetLastError));
end;

procedure TG15.SetContrast(const Value: Byte);
var
  tmp: Byte;
begin
  if Value>8 then tmp:=24 else tmp:=32-Value;
  SendCommand(2,32,129,tmp);
end;

procedure TG15.SetKeyboardBacklight(const Value: TG15Backlight);
begin
  if Value<>FKeyboardBacklight then
   begin
     SendCommand(2,1,Byte(Value),0);
     UpdateLightState;
   end;
end;

procedure TG15.SetLCDBacklight(const Value: TG15Backlight);
begin
  if Value<>FLCDBacklight then
   begin
     SendCommand(2,2,Byte(Value) SHL 4,0);
     UpdateLightState;
   end;
end;

procedure TG15.SetM1Light(const Value: TG15LightToggle);
begin
  if FM1Light<>Value then
   begin
     SendCommand(2,4,(1-Byte(Value)) + (1-Byte(FM2Light)) SHL 1
       + (1-Byte(FM3Light)) SHL 2 + (1-Byte(FMRLight)) SHL 3,0);
     UpdateLightState;
   end;
end;

procedure TG15.SetM2Light(const Value: TG15LightToggle);
begin
  if FM2Light<>Value then
   begin
     SendCommand(2,4,(1-Byte(FM1Light)) + (1-Byte(Value)) SHL 1
       + (1-Byte(FM3Light)) SHL 2 + (1-Byte(FMRLight)) SHL 3,0);
     UpdateLightState;
   end;
end;

procedure TG15.SetM3Light(const Value: TG15LightToggle);
begin
  if FM3Light<>Value then
   begin
     SendCommand(2,4,(1-Byte(FM1Light)) + (1-Byte(FM2Light)) SHL 1
       + (1-Byte(Value)) SHL 2 + (1-Byte(FMRLight)) SHL 3,0);
     UpdateLightState;
   end;
end;

procedure TG15.SetMRLight(const Value: TG15LightToggle);
begin
  if FMRLight<>Value then
   begin
     SendCommand(2,4,(1-Byte(FM1Light)) + (1-Byte(FM2Light)) SHL 1
       + (1-Byte(FM3Light)) SHL 2 + (1-Byte(Value)) SHL 3,0);
     UpdateLightState;
   end;
end;

procedure TG15.SetOnG15Detected(const Value: TNotifyEvent);
begin
  FOnG15Detected:=Value;
  if Assigned(FG15Panel) then DoG15Detected;
end;

procedure TG15.ShowG15Logo;
begin
  SendCommand(2,64,0,0);
end;

procedure TG15.UpdateLightState;
var
  tm1, tm2, tm3, tmr: TG15LightToggle;
begin
  if not Assigned(FG15Panel) then Exit;
  FLightState[0]:=2;
  if not FG15Panel.GetFeature(FLightState[0],4) then
   Raise EG15ReadError.Create(SysErrorMessage(GetLastError));

  if FLightState[1]<>Byte(FKeyboardBacklight) then
   begin
     FKeyboardBacklight:=TG15Backlight(FLightState[1]);
     if Assigned(FOnKeyboardBacklightChange) then
      FOnKeyboardBacklightChange(Self);
   end;

  if FLightState[2]<>Byte(FLCDBacklight) then
   begin
     FLCDBacklight:=TG15Backlight(FLightState[2]);
     if Assigned(FOnLCDBacklightChange) then
      FOnLCDBacklightChange(Self);
   end;

  tm1:=G15LightBoolean[(FLightState[3] AND 1)=0];
  tm2:=G15LightBoolean[(FLightState[3] AND 2)=0];
  tm3:=G15LightBoolean[(FLightState[3] AND 4)=0];
  tmr:=G15LightBoolean[(FLightState[3] AND 8)=0];
  if tm1<>FM1Light then
   begin
     FM1Light:=tm1;
     if Assigned(FOnMKeyLightChange) then
      FOnMKeyLightChange(Self, gskM1);
   end;
  if tm2<>FM2Light then
   begin
     FM2Light:=tm2;
     if Assigned(FOnMKeyLightChange) then
      FOnMKeyLightChange(Self, gskM2);
   end;
  if tm3<>FM3Light then
   begin
     FM3Light:=tm3;
     if Assigned(FOnMKeyLightChange) then
      FOnMKeyLightChange(Self, gskM3);
   end;
  if tmr<>FMRLight then
   begin
     FMRLight:=tmr;
     if Assigned(FOnMKeyLightChange) then
      FOnMKeyLightChange(Self, gskMR);
   end;

end;

end.
