program SearchWDBaseAddr;

uses
  Vcl.Forms,
  SearchBaseAddrForm in 'SearchBaseAddrForm.pas' {Form1},
  uObj in 'uObj.pas',
  uSearch in 'uSearch.pas',
  DBGame in 'DBGame.pas' {DataModule1: TDataModule},
  SearchResultForm in 'SearchResultForm.pas' {frmSearchResult},
  EditGameForm in 'EditGameForm.pas' {frmEditGame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TfrmSearchResult, frmSearchResult);
  Application.CreateForm(TfrmEditGame, frmEditGame);
  Application.Run;
end.
