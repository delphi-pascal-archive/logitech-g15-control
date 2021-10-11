object Form1: TForm1
  Left = 218
  Top = 126
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Logitech G15 Control'
  ClientHeight = 434
  ClientWidth = 714
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object lbG15Panel: TLabel
    Left = 8
    Top = 8
    Width = 76
    Height = 17
    Caption = 'G15Panel: --'
  end
  object lbContrast: TLabel
    Left = 8
    Top = 144
    Width = 60
    Height = 17
    Caption = 'Contraste'
    Layout = tlCenter
  end
  object gbKeyLight: TGroupBox
    Left = 8
    Top = 32
    Width = 217
    Height = 97
    Caption = ' KeyLight '
    Enabled = False
    TabOrder = 0
    object rbKeyOff: TRadioButton
      Left = 10
      Top = 21
      Width = 75
      Height = 22
      Caption = 'Off'
      Enabled = False
      TabOrder = 0
      OnClick = rbKeyLightClick
    end
    object rbKeyLow: TRadioButton
      Tag = 1
      Left = 10
      Top = 42
      Width = 75
      Height = 22
      Caption = 'Low'
      Enabled = False
      TabOrder = 1
      OnClick = rbKeyLightClick
    end
    object rbKeyHigh: TRadioButton
      Tag = 2
      Left = 10
      Top = 63
      Width = 75
      Height = 22
      Caption = 'High'
      Enabled = False
      TabOrder = 2
      OnClick = rbKeyLightClick
    end
  end
  object gbLCD: TGroupBox
    Left = 232
    Top = 32
    Width = 225
    Height = 97
    Caption = ' LCDLight '
    Enabled = False
    TabOrder = 1
    object rbLCDOff: TRadioButton
      Left = 10
      Top = 21
      Width = 75
      Height = 22
      Caption = 'Off'
      Enabled = False
      TabOrder = 0
      OnClick = rbLCDLightClick
    end
    object rbLCDLow: TRadioButton
      Tag = 1
      Left = 10
      Top = 42
      Width = 75
      Height = 22
      Caption = 'Low'
      Enabled = False
      TabOrder = 1
      OnClick = rbLCDLightClick
    end
    object rbLCDHigh: TRadioButton
      Tag = 2
      Left = 10
      Top = 63
      Width = 75
      Height = 22
      Caption = 'High'
      Enabled = False
      TabOrder = 2
      OnClick = rbLCDLightClick
    end
  end
  object gbMKeys: TGroupBox
    Left = 464
    Top = 32
    Width = 241
    Height = 97
    Caption = ' Touches M '
    Enabled = False
    TabOrder = 2
    object cbM1: TCheckBox
      Tag = 1
      Left = 10
      Top = 21
      Width = 75
      Height = 22
      Caption = 'M1'
      Enabled = False
      TabOrder = 0
      OnClick = cbMKeysClick
    end
    object cbM2: TCheckBox
      Tag = 2
      Left = 10
      Top = 42
      Width = 75
      Height = 22
      Caption = 'M2'
      Enabled = False
      TabOrder = 1
      OnClick = cbMKeysClick
    end
    object cbM3: TCheckBox
      Tag = 4
      Left = 10
      Top = 63
      Width = 75
      Height = 22
      Caption = 'M3'
      Enabled = False
      TabOrder = 2
      OnClick = cbMKeysClick
    end
    object cbMR: TCheckBox
      Tag = 8
      Left = 126
      Top = 63
      Width = 74
      Height = 22
      Caption = 'MR'
      Enabled = False
      TabOrder = 3
      OnClick = cbMKeysClick
    end
  end
  object tbContrast: TTrackBar
    Left = 80
    Top = 144
    Width = 209
    Height = 25
    Enabled = False
    Max = 8
    Position = 4
    TabOrder = 3
    ThumbLength = 14
    OnChange = tbContrastChange
  end
  object btLogo: TButton
    Left = 296
    Top = 144
    Width = 161
    Height = 25
    Caption = 'Show logo'
    Enabled = False
    TabOrder = 4
    OnClick = btLogoClick
  end
  object Memo1: TMemo
    Left = 8
    Top = 176
    Width = 697
    Height = 249
    ScrollBars = ssVertical
    TabOrder = 5
  end
end
