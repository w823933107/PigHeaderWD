object frmSearchResult: TfrmSearchResult
  Left = 411
  Top = 231
  BorderStyle = bsToolWindow
  Caption = 'frmSearchResult'
  ClientHeight = 325
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 13
  object cxGrid3: TcxGrid
    Left = 0
    Top = 0
    Width = 414
    Height = 325
    Align = alClient
    TabOrder = 0
    object cxGrid3DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      Navigator.Visible = True
      DataController.DataSource = DataModule1.dsSearchResult
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsSelection.InvertSelect = False
      OptionsSelection.MultiSelect = True
      OptionsSelection.CellMultiSelect = True
      OptionsView.GroupByBox = False
      object cxGrid3DBTableView1DBColumn: TcxGridDBColumn
        DataBinding.FieldName = #22522#22336#21517#31216
        Width = 162
      end
      object cxGrid3DBTableView1DBColumn1: TcxGridDBColumn
        DataBinding.FieldName = #32467#26524#22320#22336
        VisibleForCustomization = False
        Width = 234
      end
    end
    object cxGrid3Level1: TcxGridLevel
      GridView = cxGrid3DBTableView1
    end
  end
end
