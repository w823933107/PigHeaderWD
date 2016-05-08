object DataModule1: TDataModule1
  OldCreateOrder = False
  Height = 276
  Width = 495
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 160
    Top = 16
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 208
    Top = 16
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=wdSearch.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 112
    Top = 16
  end
  object dsBaseAddr: TDataSource
    DataSet = fdqryBaseAddr
    Left = 16
    Top = 16
  end
  object dsGame: TDataSource
    DataSet = fdqryGame
    Left = 64
    Top = 16
  end
  object fdqryGame: TFDQuery
    IndexFieldNames = #28216#25103#21517#31216
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM '#28216#25103)
    Left = 64
    Top = 64
  end
  object fdqryBaseAddr: TFDQuery
    IndexFieldNames = #28216#25103#21517#31216';'#22522#22336#21517#31216
    MasterSource = dsGame
    MasterFields = #28216#25103#21517#31216
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM '#28216#25103#22522#22336)
    Left = 16
    Top = 64
  end
  object fdqrySearchResult: TFDQuery
    IndexFieldNames = #22522#22336#21517#31216
    MasterSource = dsBaseAddr
    MasterFields = #22522#22336#21517#31216
    Connection = FDConnection1
    SQL.Strings = (
      'SELECT * FROM '#25628#32034#32467#26524)
    Left = 128
    Top = 64
  end
  object dsSearchResult: TDataSource
    DataSet = fdqrySearchResult
    Left = 64
    Top = 120
  end
end
