unit uSearch;

interface

uses uObj;

type
  TSearch = class
  private
    FObj: IChargeObj;
    FHwnd: Integer;
    FGameClass: string;
    FGameTitle: string;
    function GetHwnd: Boolean;
  public
    function Search(const addr_range: WideString;
      const data: WideString; const index, offset: Integer; var outAddr: string)
      : TArray<string>;
    constructor Create(aGameClass, aGameTitle: string);
    destructor Destroy; override;
  end;

implementation

uses system.SysUtils;
{ TSearch }

constructor TSearch.Create(aGameClass, aGameTitle: string);
begin
  FObj := TObjFactory.CreateChargeObj;
  FGameClass := aGameClass;
  FGameTitle := aGameTitle;
end;

destructor TSearch.Destroy;
begin
  FObj := nil;
  inherited;
end;

function TSearch.GetHwnd: Boolean;
begin
  FHwnd := FObj.FindWindow(FGameClass, FGameTitle);
  Result := FHwnd > 0;
end;

function TSearch.Search(const addr_range, data: WideString;
  const index, offset: Integer; var outAddr: string): TArray<string>;
var
  sRet: string;
  dataAddr: Integer;

begin
  Result := [];
  if GetHwnd then
  begin
    // CreateTask(
    // procedure(const task: IOmniTask)
    // begin
    //
    // end).Run.MsgWait();
    sRet := FObj.FindDataEx(FHwnd, addr_range,
      data, 1, 1, 0);
    if not sRet.IsEmpty then
    begin
      Result := sRet.Split(['|']); // 分割得到结果
      if Length(Result) < index then
        raise Exception.Create('获取错误');
      dataAddr := ('$' + Result[index]).ToInteger + offset;
      outAddr :=Format('%.8x',[FObj.ReadIntAddr(FHwnd, dataAddr, 0)]);
    end;
  end;
end;

end.
