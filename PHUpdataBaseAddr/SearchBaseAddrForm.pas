unit SearchBaseAddrForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  Vcl.ExtCtrls, Vcl.DBCtrls, cxGraphics, cxControls,

  cxEdit, cxGridCustomTableView,
  cxGridDBTableView, cxGridLevel, cxClasses,
  cxGrid,

  Vcl.Mask,
  Data.Bind.Components, Data.Bind.DBScope,
  Vcl.Buttons, Vcl.ActnList, JvToolEdit,
  cxPropertiesStore, dxStatusBar, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator,
  cxDBData, Data.Bind.EngExt, Vcl.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Vcl.Bind.Editors, System.Actions, JvExMask,
  cxGridTableView, cxGridCustomView;

type
  TForm1 = class(TForm)
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1DBColumn: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn1: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn2: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn3: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn4: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn5: TcxGridDBColumn;
    cxGrid2DBTableView1DBColumn6: TcxGridDBColumn;
    pnl1: TPanel;
    lbledtBaseAddrName: TLabeledEdit;
    lbledtIndex: TLabeledEdit;
    lbledtOffset: TLabeledEdit;
    lbledtRange: TLabeledEdit;
    lbledtFeatureCode: TLabeledEdit;
    lbledtGameName: TLabeledEdit;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    btnAddSearchBaseAddr: TButton;
    lbl1: TLabel;
    DBLookupComboBox1: TDBLookupComboBox;
    btnEditGame: TSpeedButton;
    ActionList1: TActionList;
    actOpenSearchResultForm: TAction;
    BindSourceDB2: TBindSourceDB;
    LinkControlToField1: TLinkControlToField;
    pnl2: TPanel;
    lbl2: TLabel;
    btnLookSearchResult: TSpeedButton;
    dbedtFeatureCode: TDBEdit;
    edtFileName1: TJvFilenameEdit;
    lbl3: TLabel;
    btnUpdateFile: TSpeedButton;
    btnUpdataBaseAddr: TSpeedButton;
    cxPropertiesStore1: TcxPropertiesStore;
    dxStatusBar1: TdxStatusBar;
    procedure FormShow(Sender: TObject);
    procedure btnEditGameClick(Sender: TObject);
    procedure actOpenSearchResultFormExecute(Sender: TObject);
    procedure cxGrid2DBTableView1EditDblClick(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
    procedure btnAddSearchBaseAddrClick(Sender: TObject);
    procedure btnUpdataBaseAddrClick(Sender: TObject);
    procedure btnUpdateFileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


uses DBGame, SearchResultForm, EditGameForm;

procedure TForm1.actOpenSearchResultFormExecute(Sender: TObject);
begin
  frmSearchResult.Caption := Format('特征码:%s', [dbedtFeatureCode.Text]);
  frmSearchResult.Show;
end;

procedure TForm1.btnAddSearchBaseAddrClick(Sender: TObject);
// const
// sql = 'INSERT INTO 游戏基址(游戏名称,基址名称,索引,偏移,搜寻范围,特征码) VALUES(:Gamename, :baseaddrName,:index,:offset,:range,:featureCode)';
begin
  // DBGame.DataModule1.fdqryBaseAddr.ExecSQL(sql,
  // [lbledtGameName.Text, lbledtBaseAddrName.Text, lbledtIndex.Text,
  // lbledtOffset.Text, lbledtRange.Text,
  // lbledtFeatureCode.Text
  // ]);
  // DBGame.DataModule1.fdqryBaseAddr.Open('SELECT * FROM 游戏基址');

  // DataModule1.fdqryBaseAddr.ExecSQL
  // ('SELECT 基址名称 FROM 游戏基址 WHERE  基址名称= :name',
  // [lbledtGameName.Text]) ;
  // if DBGame.DataModule1.fdqryBaseAddr.Locate('基址名称', lbledtBaseAddrName.Text) then
  // begin
  // ShowMessage('不能添加重复的基址名称');
  // Exit;
  // end;
  DBGame.DataModule1.fdqryBaseAddr.AppendRecord
    ([lbledtGameName.Text, lbledtBaseAddrName.Text, 00000000, lbledtIndex.Text,
    lbledtOffset.Text, lbledtRange.Text,
    lbledtFeatureCode.Text]);
  DBGame.DataModule1.fdqryBaseAddr.Open();
end;

procedure TForm1.btnEditGameClick(Sender: TObject);
begin
  frmEditGame.Show;
end;

procedure TForm1.btnUpdataBaseAddrClick(Sender: TObject);
begin
  DBGame.DataModule1.UpdataFeatureCode;
  ShowMessage('更新基址完毕');
end;

procedure TForm1.btnUpdateFileClick(Sender: TObject);
var
  curpos: Integer;
  s: string;
  strlist: TStringList;
  filename: string;
begin
  filename := edtFileName1.Text;
  if filename.IsEmpty then
  begin
    ShowMessage('文件名不能为空');
    Exit;
  end;
  strlist := TStringList.Create;
  try
    strlist.Add('const');
    with DataModule1 do
    begin
      curpos := fdqryBaseAddr.RecNo;
      fdqryBaseAddr.First;
      while not fdqryBaseAddr.Eof do
      begin
        s := fdqryBaseAddr.FieldValues['基址名称'] + '=' +
          fdqryBaseAddr.FieldValues['基址'];
        strlist.Add(s);
        fdqryBaseAddr.Next;
      end;
      fdqryBaseAddr.RecNo := curpos;
      strlist.SaveToFile('c:\\mycode.inc');
      ShowMessage('文件更新完毕');
    end;
  finally
    strlist.Free;
  end;

end;

procedure TForm1.cxGrid2DBTableView1EditDblClick(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem; AEdit: TcxCustomEdit);
begin
  // actOpenSearchResultFormExecute(Self);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  DBGame.DataModule1.fdqryGame.Active := True;
  DBGame.DataModule1.fdqryBaseAddr.Active := True;
  DBGame.DataModule1.fdqrySearchResult.Active := True;
end;

end.
