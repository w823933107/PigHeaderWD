unit DBGame;

interface

uses uSearch,
  System.SysUtils, System.Classes,


  Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Comp.UI, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TDataModule1 = class(TDataModule)
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDConnection1: TFDConnection;
    dsBaseAddr: TDataSource;
    dsGame: TDataSource;
    fdqryGame: TFDQuery;
    fdqryBaseAddr: TFDQuery;
    fdqrySearchResult: TFDQuery;
    dsSearchResult: TDataSource;
  private
    { Private declarations }
    FSearch: TSearch;
    procedure SearchFeatureCode;
  public
    { Public declarations }
    procedure UpdataFeatureCode;
  end;

var
  DataModule1: TDataModule1;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

{ TDataModule1 }

procedure TDataModule1.SearchFeatureCode;
var
  baseAddrName: string;
  addRange: string; // 范围
  Data: string; // 特征码
  index: Integer; // 索引
  offset: Integer; // 偏移
  curpos: Integer; // 当前游标位置
  outAddr: string; // 返回的地址
  arrRet: TArray<string>; // 返回的结果集
  s: string;
begin
  curpos := fdqryBaseAddr.RecNo;
  fdqryBaseAddr.First;
  fdqrySearchResult.ExecSQL('DELETE FROM 搜索结果');
  while not fdqryBaseAddr.Eof do
  begin
    baseAddrName := fdqryBaseAddr.FieldValues['基址名称'];
    addRange := fdqryBaseAddr.FieldValues['搜寻范围'];
    Data := fdqryBaseAddr.FieldValues['特征码'];
    index := fdqryBaseAddr.FieldValues['索引'];
    offset := fdqryBaseAddr.FieldValues['偏移'];
    arrRet := FSearch.Search(addRange, Data, index, offset, outAddr);
    fdqryBaseAddr.Edit;
    fdqryBaseAddr.FieldValues['基址'] := outAddr;
    fdqryBaseAddr.Post;
    for s in arrRet do
    begin
      fdqrySearchResult.ExecSQL
        ('INSERT INTO 搜索结果(基址名称,结果地址) VALUES(:name, :ret)',
        [baseAddrName, format('%.8x', [('$' + s).ToInteger])]);
    end;
    fdqryBaseAddr.Next;
  end;
  fdqrySearchResult.Open('SELECT * FROM 搜索结果');
  fdqryBaseAddr.RecNo := curpos;
end;

procedure TDataModule1.UpdataFeatureCode;
var
  aGameClass, aGameTitle: string;
begin
  aGameTitle := fdqryGame.FieldByName('游戏标题').AsString;
  aGameClass := fdqryGame.FieldByName('游戏类名').AsString;
  FSearch := TSearch.Create(aGameClass, aGameTitle);
  try
    SearchFeatureCode;
  finally
    FSearch.Free;
  end;
end;

end.
