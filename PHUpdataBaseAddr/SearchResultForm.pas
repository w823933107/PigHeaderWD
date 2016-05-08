unit SearchResultForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,

  cxGridLevel,
  cxGridDBTableView, cxClasses,
  cxGrid, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridCustomView;

type
  TfrmSearchResult = class(TForm)
    cxGrid3: TcxGrid;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3DBTableView1DBColumn: TcxGridDBColumn;
    cxGrid3DBTableView1DBColumn1: TcxGridDBColumn;
    cxGrid3Level1: TcxGridLevel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSearchResult: TfrmSearchResult;

implementation

{$R *.dfm}



end.
