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
  addRange: string; // ��Χ
  Data: string; // ������
  index: Integer; // ����
  offset: Integer; // ƫ��
  curpos: Integer; // ��ǰ�α�λ��
  outAddr: string; // ���صĵ�ַ
  arrRet: TArray<string>; // ���صĽ����
  s: string;
begin
  curpos := fdqryBaseAddr.RecNo;
  fdqryBaseAddr.First;
  fdqrySearchResult.ExecSQL('DELETE FROM �������');
  while not fdqryBaseAddr.Eof do
  begin
    baseAddrName := fdqryBaseAddr.FieldValues['��ַ����'];
    addRange := fdqryBaseAddr.FieldValues['��Ѱ��Χ'];
    Data := fdqryBaseAddr.FieldValues['������'];
    index := fdqryBaseAddr.FieldValues['����'];
    offset := fdqryBaseAddr.FieldValues['ƫ��'];
    arrRet := FSearch.Search(addRange, Data, index, offset, outAddr);
    fdqryBaseAddr.Edit;
    fdqryBaseAddr.FieldValues['��ַ'] := outAddr;
    fdqryBaseAddr.Post;
    for s in arrRet do
    begin
      fdqrySearchResult.ExecSQL
        ('INSERT INTO �������(��ַ����,�����ַ) VALUES(:name, :ret)',
        [baseAddrName, format('%.8x', [('$' + s).ToInteger])]);
    end;
    fdqryBaseAddr.Next;
  end;
  fdqrySearchResult.Open('SELECT * FROM �������');
  fdqryBaseAddr.RecNo := curpos;
end;

procedure TDataModule1.UpdataFeatureCode;
var
  aGameClass, aGameTitle: string;
begin
  aGameTitle := fdqryGame.FieldByName('��Ϸ����').AsString;
  aGameClass := fdqryGame.FieldByName('��Ϸ����').AsString;
  FSearch := TSearch.Create(aGameClass, aGameTitle);
  try
    SearchFeatureCode;
  finally
    FSearch.Free;
  end;
end;

end.
