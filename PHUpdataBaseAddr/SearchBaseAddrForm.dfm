object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #29482#22836#19968#38190#26356#26032#22522#22336
  ClientHeight = 385
  ClientWidth = 987
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid2: TcxGrid
    Left = 0
    Top = 86
    Width = 987
    Height = 243
    Align = alTop
    TabOrder = 0
    object cxGrid2DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Visible = True
      OnEditDblClick = cxGrid2DBTableView1EditDblClick
      DataController.DataSource = DataModule1.dsBaseAddr
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.InvertSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.CellMultiSelect = True
      OptionsView.GroupByBox = False
      object cxGrid2DBTableView1DBColumn: TcxGridDBColumn
        DataBinding.FieldName = #28216#25103#21517#31216
        Width = 141
      end
      object cxGrid2DBTableView1DBColumn1: TcxGridDBColumn
        DataBinding.FieldName = #22522#22336#21517#31216
        Width = 92
      end
      object cxGrid2DBTableView1DBColumn2: TcxGridDBColumn
        DataBinding.FieldName = #22522#22336
        Width = 79
      end
      object cxGrid2DBTableView1DBColumn3: TcxGridDBColumn
        DataBinding.FieldName = #32034#24341
      end
      object cxGrid2DBTableView1DBColumn4: TcxGridDBColumn
        DataBinding.FieldName = #20559#31227
        Width = 60
      end
      object cxGrid2DBTableView1DBColumn5: TcxGridDBColumn
        DataBinding.FieldName = #25628#23547#33539#22260
        Width = 188
      end
      object cxGrid2DBTableView1DBColumn6: TcxGridDBColumn
        DataBinding.FieldName = #29305#24449#30721
        Width = 338
      end
    end
    object cxGrid2Level1: TcxGridLevel
      GridView = cxGrid2DBTableView1
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 987
    Height = 86
    Align = alTop
    TabOrder = 1
    object lbl1: TLabel
      Left = 5
      Top = 13
      Width = 48
      Height = 13
      Caption = #36873#25321#28216#25103
    end
    object btnEditGame: TSpeedButton
      Left = 218
      Top = 10
      Width = 70
      Height = 22
      Caption = #28216#25103#32534#36753
      OnClick = btnEditGameClick
    end
    object lbledtBaseAddrName: TLabeledEdit
      Left = 131
      Top = 51
      Width = 121
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = #22522#22336#21517#31216
      TabOrder = 0
    end
    object lbledtIndex: TLabeledEdit
      Left = 256
      Top = 51
      Width = 46
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #32034#24341
      TabOrder = 1
      Text = '0'
    end
    object lbledtOffset: TLabeledEdit
      Left = 308
      Top = 51
      Width = 32
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #20559#31227
      TabOrder = 2
    end
    object lbledtRange: TLabeledEdit
      Left = 346
      Top = 51
      Width = 121
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #33539#22260
      TabOrder = 3
      Text = '00400000-7FFFFFFF'
    end
    object lbledtFeatureCode: TLabeledEdit
      Left = 473
      Top = 51
      Width = 237
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = #29305#24449#30721
      TabOrder = 4
    end
    object lbledtGameName: TLabeledEdit
      Left = 4
      Top = 51
      Width = 121
      Height = 21
      EditLabel.Width = 48
      EditLabel.Height = 13
      EditLabel.Caption = #28216#25103#21517#31216
      Enabled = False
      TabOrder = 5
    end
    object btnAddSearchBaseAddr: TButton
      Left = 716
      Top = 51
      Width = 82
      Height = 25
      Caption = #28155#21152#25628#23547#22522#22336
      TabOrder = 6
      OnClick = btnAddSearchBaseAddrClick
    end
    object DBLookupComboBox1: TDBLookupComboBox
      Left = 69
      Top = 10
      Width = 145
      Height = 21
      KeyField = #28216#25103#21517#31216
      ListField = #28216#25103#21517#31216
      ListSource = DataModule1.dsGame
      TabOrder = 7
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 329
    Width = 987
    Height = 56
    Align = alClient
    TabOrder = 2
    object lbl2: TLabel
      Left = 5
      Top = 9
      Width = 36
      Height = 13
      Caption = #29305#24449#30721
    end
    object btnLookSearchResult: TSpeedButton
      Left = 250
      Top = 9
      Width = 129
      Height = 22
      Action = actOpenSearchResultForm
    end
    object lbl3: TLabel
      Left = 394
      Top = 14
      Width = 48
      Height = 13
      Caption = #22522#22336#25991#20214
    end
    object btnUpdateFile: TSpeedButton
      Left = 578
      Top = 11
      Width = 73
      Height = 22
      Caption = #26356#26032#25991#20214
      OnClick = btnUpdateFileClick
    end
    object btnUpdataBaseAddr: TSpeedButton
      Left = 658
      Top = 11
      Width = 65
      Height = 22
      Caption = #26356#26032#22522#22336
      OnClick = btnUpdataBaseAddrClick
    end
    object dbedtFeatureCode: TDBEdit
      Left = 47
      Top = 8
      Width = 197
      Height = 21
      DataField = #29305#24449#30721
      DataSource = DataModule1.dsBaseAddr
      Enabled = False
      TabOrder = 0
    end
    object edtFileName1: TJvFilenameEdit
      Left = 446
      Top = 11
      Width = 121
      Height = 21
      TabOrder = 1
      Text = ''
    end
    object dxStatusBar1: TdxStatusBar
      Left = 1
      Top = 35
      Width = 985
      Height = 20
      Panels = <
        item
          PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
          PanelStyle.Font.Charset = GB2312_CHARSET
          PanelStyle.Font.Color = clGreen
          PanelStyle.Font.Height = -11
          PanelStyle.Font.Name = #21494#26681#21451#27611#31508#34892#20070'2.0'#29256
          PanelStyle.Font.Style = []
          PanelStyle.ParentFont = False
          Text = #29256#26435#24402#29482#22836#20351#29992','#20854#20182#20219#20309#20154#19981#24471#25797#33258#20351#29992
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
  end
  object BindSourceDB1: TBindSourceDB
    DataSet = DataModule1.fdqryBaseAddr
    ScopeMappings = <>
    Left = 96
    Top = 216
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    Left = 36
    Top = 541
    object LinkControlToField1: TLinkControlToField
      Category = 'Quick Bindings'
      DataSource = BindSourceDB2
      FieldName = #28216#25103#21517#31216
      Control = lbledtGameName
      Track = True
    end
  end
  object ActionList1: TActionList
    Left = 104
    Top = 152
    object actOpenSearchResultForm: TAction
      Caption = #26597#30475#29305#24449#30721#25152#26377#22320#22336
      OnExecute = actOpenSearchResultFormExecute
    end
  end
  object BindSourceDB2: TBindSourceDB
    DataSet = DataModule1.fdqryGame
    ScopeMappings = <>
    Left = 488
    Top = 192
  end
  object cxPropertiesStore1: TcxPropertiesStore
    Components = <
      item
        Component = edtFileName1
        Properties.Strings = (
          'Text')
      end>
    StorageName = 'cxPropertiesStore1'
    Left = 248
    Top = 144
  end
end
