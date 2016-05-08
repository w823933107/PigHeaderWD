{

  2016/5/7
  =====================
  +TMyObj添加内存相关的函数
  2016/4/27
  =====================
  *移除注册码加密功能
  *修正TMyObj.OcrEx函数错误
  2016/3/20
  =====================
  *修正程序退出时dll管理器未释放,造成内存泄露的错误

}

unit uObj;

interface

uses
  System.Generics.Collections, Winapi.Windows, Winapi.ActiveX,
  System.Win.ComObj, System.SysUtils, Vcl.Clipbrd;

const

  // --------一些插件的配置信息---------------
  // 默认注册码
  cRegCode = 'gxhxwme5e07ca5bc2945976a2be4a9cabdcb81';
  // 注册版本信息,通常可以随意设置
  cRegVer = 'pighead';
  // 收费插件路径
  cChargeFullPath = '.\Bin\Charge.dll';
  // 免费插件路径
  cFreeFullPath = '.\Bin\Free.dll';
  // 天使插件路径
  cTsFullPath = '.\Bin\Ts.dll';
  // ---------------com的常量值,不能修改
  // cPluginClassName: string = 'dm.dmsoft';
  CLASS_TSPlugInterface: TGUID = '{BCE4A484-C3BC-418B-B1F6-69D6987C126B}';
  CLASS_DMPluginInterface: TGUID = '{26037A0E-7CBD-4FFF-9C63-56F2D0770214}';

type

  // 关于COM的一些服务函数
  TComService = class
  strict private
    // 存储dll的名词和,模块句柄
    class var FDllDictionary: TDictionary<string, THandle>;
  strict private
    // 从dll中创建com
    class function CreateComObjFromDll(CLASS_ID: TGUID; ADllHandle: HMODULE)
      : IDispatch; static;
    // 程序退出后释放加载的dll
    class destructor Destroy;
  public
    // 使用系统自带的注册方式，和自己封装的利用dll导出函数是一样的，但是这个只有注册功能
    class procedure RegisterComServer(const aDllName: string);
    // 判断是否注册
    class function IsReg(const aComClassName: string): Boolean;
    // 注册和反注册
    class function RegCom(const aPath: string; const aReg: Boolean)
      : Boolean; overload;
    // 根据dll路径注册
    class function RegCom(const aPath: string): Boolean; overload;
    // 根据路径卸载
    class function UnregCom(const aPath: string): Boolean;
    // 免注册调用自动化对象
    class function NoRegCreateComObj(const CLASS_ID: TGUID;
      const aDllPath: string): IDispatch;
    // 根据类名创建对象
    class function CreateOleObj(const ClassName: string): IDispatch;
    // 根据路径释放免注册dll
    class procedure FreeDll(const aDllPath: string);
    // 释放所有的dll
    class procedure FreeAllDll;
    // 利用TRegSvr.exe注册
    class procedure RegCommond(const aFileName: string; const aDoReg: Boolean);
  end;

  // 静态配置结构，可对其直接进行配置
  TObjConfig = record
  private
    class constructor Create();
  public
  class var
    ChargeFullPath: string; // 收费插件全路径
    FreeFullPath: string; // 免费插件全路径
    TsFullPath: string;
    RegCode: string;
    RegVer: string;
    // 提供外部功能f2盾的保护支持,通过剪切板获取真实路径
    class procedure GetF2GuardRealDir(const aAppName: string); static;
  end;

  // MyObjInterf单元的类型再声明
  // 提供给TMyObj使用
  TOcrStr = record
    Str: string;
    X, Y: Integer;
  end;

  // 免费接口

  IFreeObj = interface;

  // 收费接口
  IChargeObj = interface;

  // 天使插件接口
  ITsObj = interface;

  // 自已拓展的对象
  TMyObj = class
  private
    FObj: IChargeObj;
  public

    X1, Y1, X2, Y2: Integer; // 全局的找图范围
  public
    constructor Create(aObj: IChargeObj);
    destructor Destroy; override;
    // 获取字符串及其坐标 ,返回包含字符串和坐标的动态数组
    function OcrEx(X1, Y1, X2, Y2: Integer; color_format: string; sim: Double;
      out OutStr: string): TArray<TOcrStr>;
    function FindData(hwnd: Integer; const addr_range: WideString;
      const data: WideString): TArray<string>;
    function FindDataEx(hwnd: Integer; const addr_range: WideString;
      const data: WideString; step: Integer; multi_thread: Integer;
      mode: Integer): TArray<string>;
    // function FindPic(aName: string): Integer; overload;
    // function FindPic(aName: string; out aOutX, aOutY: Integer)
    // : Integer; overload;
    // function FindPic(const ax1, ay1, ax2, ay2: Integer; aPicName: string)
    // : Integer; overload;
    // function FindPic(const ax1, ay1, ax2, ay2: Integer; aPicName: string;
    // out aOutX, aOutY: Integer): Integer; overload;
    // function FindPic(const ax1, ay1, ax2, ay2: Integer;
    // aPicName, aColor: string; const aSim: Double; aDir: Integer)
    // : Integer; overload;
  end;

  // 对象工厂
  TObjFactory = class
  public
    class function CreateFreeObj: IFreeObj;
    class function CreateChargeObj: IChargeObj;
    class function CreateTsObj: ITsObj;
    class function CreateMyObj(aObj: IChargeObj): TMyObj;
  end;

  IFreeObj = interface(IDispatch)
    ['{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}']
    // 此处不可更改,否则会出错,提示接口不支持

    function Ver: WideString; safecall;
    function SetPath(const path: WideString): Integer; safecall;
    function Ocr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function FindStr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function GetResultCount(const Str: WideString): Integer; safecall;
    function GetResultPos(const Str: WideString; index: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function StrStr(const s: WideString; const Str: WideString)
      : Integer; safecall;
    function SendCommand(const cmd: WideString): Integer; safecall;
    function UseDict(index: Integer): Integer; safecall;
    function GetBasePath: WideString; safecall;
    function SetDictPwd(const pwd: WideString): Integer; safecall;
    function OcrInFile(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function Capture(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function KeyPress(vk: Integer): Integer; safecall;
    function KeyDown(vk: Integer): Integer; safecall;
    function KeyUp(vk: Integer): Integer; safecall;
    function LeftClick: Integer; safecall;
    function RightClick: Integer; safecall;
    function MiddleClick: Integer; safecall;
    function LeftDoubleClick: Integer; safecall;
    function LeftDown: Integer; safecall;
    function LeftUp: Integer; safecall;
    function RightDown: Integer; safecall;
    function RightUp: Integer; safecall;
    function MoveTo(X: Integer; Y: Integer): Integer; safecall;
    function MoveR(rx: Integer; ry: Integer): Integer; safecall;
    function GetColor(X: Integer; Y: Integer): WideString; safecall;
    function GetColorBGR(X: Integer; Y: Integer): WideString; safecall;
    function RGB2BGR(const rgb_color: WideString): WideString; safecall;
    function BGR2RGB(const bgr_color: WideString): WideString; safecall;
    function UnBindWindow: Integer; safecall;
    function CmpColor(X: Integer; Y: Integer; const color: WideString;
      sim: Double): Integer; safecall;
    function ClientToScreen(hwnd: Integer; var X: OleVariant; var Y: OleVariant)
      : Integer; safecall;
    function ScreenToClient(hwnd: Integer; var X: OleVariant; var Y: OleVariant)
      : Integer; safecall;
    function ShowScrMsg(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const msg: WideString; const color: WideString): Integer; safecall;
    function SetMinRowGap(row_gap: Integer): Integer; safecall;
    function SetMinColGap(col_gap: Integer): Integer; safecall;
    function FindColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer; out X: OleVariant;
      out Y: OleVariant): Integer; safecall;
    function FindColorEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function SetWordLineHeight(line_height: Integer): Integer; safecall;
    function SetWordGap(word_gap: Integer): Integer; safecall;
    function SetRowGapNoDict(row_gap: Integer): Integer; safecall;
    function SetColGapNoDict(col_gap: Integer): Integer; safecall;
    function SetWordLineHeightNoDict(line_height: Integer): Integer; safecall;
    function SetWordGapNoDict(word_gap: Integer): Integer; safecall;
    function GetWordResultCount(const Str: WideString): Integer; safecall;
    function GetWordResultPos(const Str: WideString; index: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function GetWordResultStr(const Str: WideString; index: Integer)
      : WideString; safecall;
    function GetWords(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function GetWordsNoDict(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString): WideString; safecall;
    function SetShowErrorMsg(show: Integer): Integer; safecall;
    function GetClientSize(hwnd: Integer; out width: OleVariant;
      out height: OleVariant): Integer; safecall;
    function MoveWindow(hwnd: Integer; X: Integer; Y: Integer)
      : Integer; safecall;
    function GetColorHSV(X: Integer; Y: Integer): WideString; safecall;
    function GetAveRGB(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : WideString; safecall;
    function GetAveHSV(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : WideString; safecall;
    function GetForegroundWindow: Integer; safecall;
    function GetForegroundFocus: Integer; safecall;
    function GetMousePointWindow: Integer; safecall;
    function GetPointWindow(X: Integer; Y: Integer): Integer; safecall;
    function EnumWindow(parent: Integer; const title: WideString;
      const class_name: WideString; filter: Integer): WideString; safecall;
    function GetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetWindow(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetSpecialWindow(flag: Integer): Integer; safecall;
    function SetWindowText(hwnd: Integer; const text: WideString)
      : Integer; safecall;
    function SetWindowSize(hwnd: Integer; width: Integer; height: Integer)
      : Integer; safecall;
    function GetWindowRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function GetWindowTitle(hwnd: Integer): WideString; safecall;
    function GetWindowClass(hwnd: Integer): WideString; safecall;
    function SetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function CreateFoobarRect(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer): Integer; safecall;
    function CreateFoobarRoundRect(hwnd: Integer; X: Integer; Y: Integer;
      w: Integer; h: Integer; rw: Integer; rh: Integer): Integer; safecall;
    function CreateFoobarEllipse(hwnd: Integer; X: Integer; Y: Integer;
      w: Integer; h: Integer): Integer; safecall;
    function CreateFoobarCustom(hwnd: Integer; X: Integer; Y: Integer;
      const pic: WideString; const trans_color: WideString; sim: Double)
      : Integer; safecall;
    function FoobarFillRect(hwnd: Integer; X1: Integer; Y1: Integer;
      X2: Integer; Y2: Integer; const color: WideString): Integer; safecall;
    function FoobarDrawText(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer; const text: WideString; const color: WideString;
      align: Integer): Integer; safecall;
    function FoobarDrawPic(hwnd: Integer; X: Integer; Y: Integer;
      const pic: WideString; const trans_color: WideString): Integer; safecall;
    function FoobarUpdate(hwnd: Integer): Integer; safecall;
    function FoobarLock(hwnd: Integer): Integer; safecall;
    function FoobarUnlock(hwnd: Integer): Integer; safecall;
    function FoobarSetFont(hwnd: Integer; const font_name: WideString;
      size: Integer; flag: Integer): Integer; safecall;
    function FoobarTextRect(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer): Integer; safecall;
    function FoobarPrintText(hwnd: Integer; const text: WideString;
      const color: WideString): Integer; safecall;
    function FoobarClearText(hwnd: Integer): Integer; safecall;
    function FoobarTextLineGap(hwnd: Integer; gap: Integer): Integer; safecall;
    function Play(const file_: WideString): Integer; safecall;
    function FaqCapture(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      quality: Integer; delay: Integer; time: Integer): Integer; safecall;
    function FaqRelease(handle: Integer): Integer; safecall;
    function FaqSend(const server: WideString; handle: Integer;
      request_type: Integer; time_out: Integer): WideString; safecall;
    function Beep(fre: Integer; delay: Integer): Integer; safecall;
    function FoobarClose(hwnd: Integer): Integer; safecall;
    function MoveDD(dx: Integer; dy: Integer): Integer; safecall;
    function FaqGetSize(handle: Integer): Integer; safecall;
    function LoadPic(const pic_name: WideString): Integer; safecall;
    function FreePic(const pic_name: WideString): Integer; safecall;
    function GetScreenData(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : Integer; safecall;
    function FreeScreenData(handle: Integer): Integer; safecall;
    function WheelUp: Integer; safecall;
    function WheelDown: Integer; safecall;
    function SetMouseDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function SetKeypadDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function GetEnv(index: Integer; const name: WideString)
      : WideString; safecall;
    function SetEnv(index: Integer; const name: WideString;
      const value: WideString): Integer; safecall;
    function SendString(hwnd: Integer; const Str: WideString): Integer;
      safecall;
    function DelEnv(index: Integer; const name: WideString): Integer; safecall;
    function GetPath: WideString; safecall;
    function SetDict(index: Integer; const dict_name: WideString)
      : Integer; safecall;
    function FindPic(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindPicEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function SetClientSize(hwnd: Integer; width: Integer; height: Integer)
      : Integer; safecall;
    function ReadInt(hwnd: Integer; const addr: WideString; type_: Integer)
      : Integer; safecall;
    function ReadFloat(hwnd: Integer; const addr: WideString): Single; safecall;
    function ReadDouble(hwnd: Integer; const addr: WideString): Double;
      safecall;
    function FindInt(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer)
      : WideString; safecall;
    function FindFloat(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single): WideString; safecall;
    function FindDouble(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double): WideString; safecall;
    function FindString(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer): WideString; safecall;
    function GetModuleBaseAddr(hwnd: Integer; const module_name: WideString)
      : Integer; safecall;
    function MoveToEx(X: Integer; Y: Integer; w: Integer; h: Integer)
      : WideString; safecall;
    function MatchPicName(const pic_name: WideString): WideString; safecall;
    function AddDict(index: Integer; const dict_info: WideString)
      : Integer; safecall;
    function EnterCri: Integer; safecall;
    function LeaveCri: Integer; safecall;
    function WriteInt(hwnd: Integer; const addr: WideString; type_: Integer;
      v: Integer): Integer; safecall;
    function WriteFloat(hwnd: Integer; const addr: WideString; v: Single)
      : Integer; safecall;
    function WriteDouble(hwnd: Integer; const addr: WideString; v: Double)
      : Integer; safecall;
    function WriteString(hwnd: Integer; const addr: WideString; type_: Integer;
      const v: WideString): Integer; safecall;
    function AsmAdd(const asm_ins: WideString): Integer; safecall;
    function AsmClear: Integer; safecall;
    function AsmCall(hwnd: Integer; mode: Integer): Integer; safecall;
    function FindMultiColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const first_color: WideString; const offset_color: WideString;
      sim: Double; dir: Integer; out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function FindMultiColorEx(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const first_color: WideString;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function AsmCode(base_addr: Integer): WideString; safecall;
    function Assemble(const asm_code: WideString; base_addr: Integer;
      is_upper: Integer): WideString; safecall;
    function SetWindowTransparent(hwnd: Integer; v: Integer): Integer; safecall;
    function ReadData(hwnd: Integer; const addr: WideString; len: Integer)
      : WideString; safecall;
    function WriteData(hwnd: Integer; const addr: WideString;
      const data: WideString): Integer; safecall;
    function FindData(hwnd: Integer; const addr_range: WideString;
      const data: WideString): WideString; safecall;
    function SetPicPwd(const pwd: WideString): Integer; safecall;
    function Log(const info: WideString): Integer; safecall;
    function FindStrE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindColorE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function FindPicE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function FindMultiColorE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const first_color: WideString; const offset_color: WideString;
      sim: Double; dir: Integer): WideString; safecall;
    function SetExactOcr(exact_ocr: Integer): Integer; safecall;
    function ReadString(hwnd: Integer; const addr: WideString; type_: Integer;
      len: Integer): WideString; safecall;
    function FoobarTextPrintDir(hwnd: Integer; dir: Integer): Integer; safecall;
    function OcrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function SetDisplayInput(const mode: WideString): Integer; safecall;
    function GetTime: Integer; safecall;
    function GetScreenWidth: Integer; safecall;
    function GetScreenHeight: Integer; safecall;
    function BindWindowEx(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString;
      const public_desc: WideString; mode: Integer): Integer; safecall;
    function GetDiskSerial: WideString; safecall;
    function Md5(const Str: WideString): WideString; safecall;
    function GetMac: WideString; safecall;
    function ActiveInputMethod(hwnd: Integer; const id: WideString)
      : Integer; safecall;
    function CheckInputMethod(hwnd: Integer; const id: WideString)
      : Integer; safecall;
    function FindInputMethod(const id: WideString): Integer; safecall;
    function GetCursorPos(out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function BindWindow(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString; mode: Integer)
      : Integer; safecall;
    function FindWindow(const class_name: WideString;
      const title_name: WideString): Integer; safecall;
    function GetScreenDepth: Integer; safecall;
    function SetScreen(width: Integer; height: Integer; depth: Integer)
      : Integer; safecall;
    function ExitOs(type_: Integer): Integer; safecall;
    function GetDir(type_: Integer): WideString; safecall;
    function GetOsType: Integer; safecall;
    function FindWindowEx(parent: Integer; const class_name: WideString;
      const title_name: WideString): Integer; safecall;
    function SetExportDict(index: Integer; const dict_name: WideString)
      : Integer; safecall;
    function GetCursorShape: WideString; safecall;
    function DownCpu(rate: Integer): Integer; safecall;
    function GetCursorSpot: WideString; safecall;
    function SendString2(hwnd: Integer; const Str: WideString)
      : Integer; safecall;
    function FaqPost(const server: WideString; handle: Integer;
      request_type: Integer; time_out: Integer): Integer; safecall;
    function FaqFetch: WideString; safecall;
    function FetchWord(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; const word: WideString): WideString; safecall;
    function CaptureJpg(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString; quality: Integer): Integer; safecall;
    function FindStrWithFont(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindStrWithFontE(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer)
      : WideString; safecall;
    function FindStrWithFontEx(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer)
      : WideString; safecall;
    function GetDictInfo(const Str: WideString; const font_name: WideString;
      font_size: Integer; flag: Integer): WideString; safecall;
    function SaveDict(index: Integer; const file_: WideString)
      : Integer; safecall;
    function GetWindowProcessId(hwnd: Integer): Integer; safecall;
    function GetWindowProcessPath(hwnd: Integer): WideString; safecall;
    function LockInput(lock: Integer): Integer; safecall;
    function GetPicSize(const pic_name: WideString): WideString; safecall;
    function GetID: Integer; safecall;
    function CapturePng(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function CaptureGif(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString; delay: Integer; time: Integer): Integer;
      safecall;
    function ImageToBmp(const pic_name: WideString; const bmp_name: WideString)
      : Integer; safecall;
    function FindStrFast(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindStrFastEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function EnableDisplayDebug(enable_debug: Integer): Integer; safecall;
    function CapturePre(const file_: WideString): Integer; safecall;
    function RegEx(const code: WideString; const Ver: WideString;
      const ip: WideString): Integer; safecall;
    function GetMachineCode: WideString; safecall;
    function SetClipboard(const data: WideString): Integer; safecall;
    function GetClipboard: WideString; safecall;
    function GetNowDict: Integer; safecall;
    function Is64Bit: Integer; safecall;
    function GetColorNum(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): Integer; safecall;
    function EnumWindowByProcess(const process_name: WideString;
      const title: WideString; const class_name: WideString; filter: Integer)
      : WideString; safecall;
    function GetDictCount(index: Integer): Integer; safecall;
    function GetLastError: Integer; safecall;
    function GetNetTime: WideString; safecall;
    function EnableGetColorByCapture(en: Integer): Integer; safecall;
    function CheckUAC: Integer; safecall;
    function SetUAC(uac: Integer): Integer; safecall;
    function DisableFontSmooth: Integer; safecall;
    function CheckFontSmooth: Integer; safecall;
    function SetDisplayAcceler(level: Integer): Integer; safecall;
    function FindWindowByProcess(const process_name: WideString;
      const class_name: WideString; const title_name: WideString)
      : Integer; safecall;
    function FindWindowByProcessId(process_id: Integer;
      const class_name: WideString; const title_name: WideString)
      : Integer; safecall;
    function ReadIni(const section: WideString; const key: WideString;
      const file_: WideString): WideString; safecall;
    function WriteIni(const section: WideString; const key: WideString;
      const v: WideString; const file_: WideString): Integer; safecall;
    function RunApp(const path: WideString; mode: Integer): Integer; safecall;
    function delay(mis: Integer): Integer; safecall;
    function FindWindowSuper(const spec1: WideString; flag1: Integer;
      type1: Integer; const spec2: WideString; flag2: Integer; type2: Integer)
      : Integer; safecall;
    function ExcludePos(const all_pos: WideString; type_: Integer; X1: Integer;
      Y1: Integer; X2: Integer; Y2: Integer): WideString; safecall;
    function FindNearestPos(const all_pos: WideString; type_: Integer;
      X: Integer; Y: Integer): WideString; safecall;
    function SortPosDistance(const all_pos: WideString; type_: Integer;
      X: Integer; Y: Integer): WideString; safecall;
    function FindPicMem(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindPicMemEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function FindPicMemE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function AppendPicAddr(const pic_info: WideString; addr: Integer;
      size: Integer): WideString; safecall;
    function WriteFile(const file_: WideString; const content: WideString)
      : Integer; safecall;
    function Stop(id: Integer): Integer; safecall;
    function SetDictMem(index: Integer; addr: Integer; size: Integer)
      : Integer; safecall;
    function GetNetTimeSafe: WideString; safecall;
    function ForceUnBindWindow(hwnd: Integer): Integer; safecall;
    function ReadIniPwd(const section: WideString; const key: WideString;
      const file_: WideString; const pwd: WideString): WideString; safecall;
    function WriteIniPwd(const section: WideString; const key: WideString;
      const v: WideString; const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function DecodeFile(const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function KeyDownChar(const key_str: WideString): Integer; safecall;
    function KeyUpChar(const key_str: WideString): Integer; safecall;
    function KeyPressChar(const key_str: WideString): Integer; safecall;
    function KeyPressStr(const key_str: WideString; delay: Integer)
      : Integer; safecall;
    function EnableKeypadPatch(en: Integer): Integer; safecall;
    function EnableKeypadSync(en: Integer; time_out: Integer): Integer;
      safecall;
    function EnableMouseSync(en: Integer; time_out: Integer): Integer; safecall;
    function DmGuard(en: Integer; const type_: WideString): Integer; safecall;
    function FaqCaptureFromFile(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const file_: WideString; quality: Integer): Integer;
      safecall;
    function FindIntEx(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer;
      step: Integer; multi_thread: Integer; mode: Integer): WideString;
      safecall;
    function FindFloatEx(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDoubleEx(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindStringEx(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDataEx(hwnd: Integer; const addr_range: WideString;
      const data: WideString; step: Integer; multi_thread: Integer;
      mode: Integer): WideString; safecall;
    function EnableRealMouse(en: Integer; mousedelay: Integer;
      mousestep: Integer): Integer; safecall;
    function EnableRealKeypad(en: Integer): Integer; safecall;
    function SendStringIme(const Str: WideString): Integer; safecall;
    function FoobarDrawLine(hwnd: Integer; X1: Integer; Y1: Integer;
      X2: Integer; Y2: Integer; const color: WideString; style: Integer;
      width: Integer): Integer; safecall;
    function FindStrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function IsBind(hwnd: Integer): Integer; safecall;
    function SetDisplayDelay(t: Integer): Integer; safecall;
    function GetDmCount: Integer; safecall;
    function DisableScreenSave: Integer; safecall;
    function DisablePowerSave: Integer; safecall;
    function SetMemoryHwndAsProcessId(en: Integer): Integer; safecall;
    function FindShape(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindShapeE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function FindShapeEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function FindStrS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindStrExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindStrFastExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindPicS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindPicExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function ClearDict(index: Integer): Integer; safecall;
    function GetMachineCodeNoMac: WideString; safecall;
    function GetClientRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function EnableFakeActive(en: Integer): Integer; safecall;
    function GetScreenDataBmp(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; out data: OleVariant; out size: OleVariant)
      : Integer; safecall;
    function EncodeFile(const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function GetCursorShapeEx(type_: Integer): WideString; safecall;
    function FaqCancel: Integer; safecall;
    function IntToData(int_value: Integer; type_: Integer): WideString;
      safecall;
    function FloatToData(float_value: Single): WideString; safecall;
    function DoubleToData(double_value: Double): WideString; safecall;
    function StringToData(const string_value: WideString; type_: Integer)
      : WideString; safecall;
    function SetMemoryFindResultToFile(const file_: WideString)
      : Integer; safecall;
    function EnableBind(en: Integer): Integer; safecall;
    function SetSimMode(mode: Integer): Integer; safecall;
    function LockMouseRect(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : Integer; safecall;
    function SendPaste(hwnd: Integer): Integer; safecall;
    function IsDisplayDead(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      t: Integer): Integer; safecall;
    function GetKeyState(vk: Integer): Integer; safecall;
    function CopyFile(const src_file: WideString; const dst_file: WideString;
      over: Integer): Integer; safecall;
    function IsFileExist(const file_: WideString): Integer; safecall;
    function DeleteFile(const file_: WideString): Integer; safecall;
    function MoveFile(const src_file: WideString; const dst_file: WideString)
      : Integer; safecall;
    function CreateFolder(const folder_name: WideString): Integer; safecall;
    function DeleteFolder(const folder_name: WideString): Integer; safecall;
    function GetFileLength(const file_: WideString): Integer; safecall;
    function ReadFile(const file_: WideString): WideString; safecall;
    function WaitKey(key_code: Integer; time_out: Integer): Integer; safecall;
    function DeleteIni(const section: WideString; const key: WideString;
      const file_: WideString): Integer; safecall;
    function DeleteIniPwd(const section: WideString; const key: WideString;
      const file_: WideString; const pwd: WideString): Integer; safecall;
    function EnableSpeedDx(en: Integer): Integer; safecall;
    function EnableIme(en: Integer): Integer; safecall;
    function Reg(const code: WideString; const Ver: WideString)
      : Integer; safecall;
    function SelectFile: WideString; safecall;
    function SelectDirectory: WideString; safecall;
    function LockDisplay(lock: Integer): Integer; safecall;
    function FoobarSetSave(hwnd: Integer; const file_: WideString; en: Integer;
      const header: WideString): Integer; safecall;
    function EnumWindowSuper(const spec1: WideString; flag1: Integer;
      type1: Integer; const spec2: WideString; flag2: Integer; type2: Integer;
      sort: Integer): WideString; safecall;
    function DownloadFile(const url: WideString; const save_file: WideString;
      timeout: Integer): Integer; safecall;
    function EnableKeypadMsg(en: Integer): Integer; safecall;
    function EnableMouseMsg(en: Integer): Integer; safecall;
    function RegNoMac(const code: WideString; const Ver: WideString)
      : Integer; safecall;
    function RegExNoMac(const code: WideString; const Ver: WideString;
      const ip: WideString): Integer; safecall;
    function SetEnumWindowDelay(delay: Integer): Integer; safecall;
    function FindMulColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): Integer; safecall;
    function GetDict(index: Integer; font_index: Integer): WideString; safecall;
  end;

  IChargeObj = interface(IDispatch)
    ['{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}']
    // 此处不可更改,否则会出错,提示接口不支持
    function Ver: WideString; safecall;
    function SetPath(const path: WideString): Integer; safecall;
    function Ocr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function FindStr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function GetResultCount(const Str: WideString): Integer; safecall;
    function GetResultPos(const Str: WideString; index: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function StrStr(const s: WideString; const Str: WideString)
      : Integer; safecall;
    function SendCommand(const cmd: WideString): Integer; safecall;
    function UseDict(index: Integer): Integer; safecall;
    function GetBasePath: WideString; safecall;
    function SetDictPwd(const pwd: WideString): Integer; safecall;
    function OcrInFile(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function Capture(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function KeyPress(vk: Integer): Integer; safecall;
    function KeyDown(vk: Integer): Integer; safecall;
    function KeyUp(vk: Integer): Integer; safecall;
    function LeftClick: Integer; safecall;
    function RightClick: Integer; safecall;
    function MiddleClick: Integer; safecall;
    function LeftDoubleClick: Integer; safecall;
    function LeftDown: Integer; safecall;
    function LeftUp: Integer; safecall;
    function RightDown: Integer; safecall;
    function RightUp: Integer; safecall;
    function MoveTo(X: Integer; Y: Integer): Integer; safecall;
    function MoveR(rx: Integer; ry: Integer): Integer; safecall;
    function GetColor(X: Integer; Y: Integer): WideString; safecall;
    function GetColorBGR(X: Integer; Y: Integer): WideString; safecall;
    function RGB2BGR(const rgb_color: WideString): WideString; safecall;
    function BGR2RGB(const bgr_color: WideString): WideString; safecall;
    function UnBindWindow: Integer; safecall;
    function CmpColor(X: Integer; Y: Integer; const color: WideString;
      sim: Double): Integer; safecall;
    function ClientToScreen(hwnd: Integer; var X: OleVariant; var Y: OleVariant)
      : Integer; safecall;
    function ScreenToClient(hwnd: Integer; var X: OleVariant; var Y: OleVariant)
      : Integer; safecall;
    function ShowScrMsg(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const msg: WideString; const color: WideString): Integer; safecall;
    function SetMinRowGap(row_gap: Integer): Integer; safecall;
    function SetMinColGap(col_gap: Integer): Integer; safecall;
    function FindColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer; out X: OleVariant;
      out Y: OleVariant): Integer; safecall;
    function FindColorEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function SetWordLineHeight(line_height: Integer): Integer; safecall;
    function SetWordGap(word_gap: Integer): Integer; safecall;
    function SetRowGapNoDict(row_gap: Integer): Integer; safecall;
    function SetColGapNoDict(col_gap: Integer): Integer; safecall;
    function SetWordLineHeightNoDict(line_height: Integer): Integer; safecall;
    function SetWordGapNoDict(word_gap: Integer): Integer; safecall;
    function GetWordResultCount(const Str: WideString): Integer; safecall;
    function GetWordResultPos(const Str: WideString; index: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function GetWordResultStr(const Str: WideString; index: Integer)
      : WideString; safecall;
    function GetWords(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function GetWordsNoDict(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString): WideString; safecall;
    function SetShowErrorMsg(show: Integer): Integer; safecall;
    function GetClientSize(hwnd: Integer; out width: OleVariant;
      out height: OleVariant): Integer; safecall;
    function MoveWindow(hwnd: Integer; X: Integer; Y: Integer)
      : Integer; safecall;
    function GetColorHSV(X: Integer; Y: Integer): WideString; safecall;
    function GetAveRGB(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : WideString; safecall;
    function GetAveHSV(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : WideString; safecall;
    function GetForegroundWindow: Integer; safecall;
    function GetForegroundFocus: Integer; safecall;
    function GetMousePointWindow: Integer; safecall;
    function GetPointWindow(X: Integer; Y: Integer): Integer; safecall;
    function EnumWindow(parent: Integer; const title: WideString;
      const class_name: WideString; filter: Integer): WideString; safecall;
    function GetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetWindow(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetSpecialWindow(flag: Integer): Integer; safecall;
    function SetWindowText(hwnd: Integer; const text: WideString)
      : Integer; safecall;
    function SetWindowSize(hwnd: Integer; width: Integer; height: Integer)
      : Integer; safecall;
    function GetWindowRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function GetWindowTitle(hwnd: Integer): WideString; safecall;
    function GetWindowClass(hwnd: Integer): WideString; safecall;
    function SetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function CreateFoobarRect(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer): Integer; safecall;
    function CreateFoobarRoundRect(hwnd: Integer; X: Integer; Y: Integer;
      w: Integer; h: Integer; rw: Integer; rh: Integer): Integer; safecall;
    function CreateFoobarEllipse(hwnd: Integer; X: Integer; Y: Integer;
      w: Integer; h: Integer): Integer; safecall;
    function CreateFoobarCustom(hwnd: Integer; X: Integer; Y: Integer;
      const pic: WideString; const trans_color: WideString; sim: Double)
      : Integer; safecall;
    function FoobarFillRect(hwnd: Integer; X1: Integer; Y1: Integer;
      X2: Integer; Y2: Integer; const color: WideString): Integer; safecall;
    function FoobarDrawText(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer; const text: WideString; const color: WideString;
      align: Integer): Integer; safecall;
    function FoobarDrawPic(hwnd: Integer; X: Integer; Y: Integer;
      const pic: WideString; const trans_color: WideString): Integer; safecall;
    function FoobarUpdate(hwnd: Integer): Integer; safecall;
    function FoobarLock(hwnd: Integer): Integer; safecall;
    function FoobarUnlock(hwnd: Integer): Integer; safecall;
    function FoobarSetFont(hwnd: Integer; const font_name: WideString;
      size: Integer; flag: Integer): Integer; safecall;
    function FoobarTextRect(hwnd: Integer; X: Integer; Y: Integer; w: Integer;
      h: Integer): Integer; safecall;
    function FoobarPrintText(hwnd: Integer; const text: WideString;
      const color: WideString): Integer; safecall;
    function FoobarClearText(hwnd: Integer): Integer; safecall;
    function FoobarTextLineGap(hwnd: Integer; gap: Integer): Integer; safecall;
    function Play(const file_: WideString): Integer; safecall;
    function FaqCapture(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      quality: Integer; delay: Integer; time: Integer): Integer; safecall;
    function FaqRelease(handle: Integer): Integer; safecall;
    function FaqSend(const server: WideString; handle: Integer;
      request_type: Integer; time_out: Integer): WideString; safecall;
    function Beep(fre: Integer; delay: Integer): Integer; safecall;
    function FoobarClose(hwnd: Integer): Integer; safecall;
    function MoveDD(dx: Integer; dy: Integer): Integer; safecall;
    function FaqGetSize(handle: Integer): Integer; safecall;
    function LoadPic(const pic_name: WideString): Integer; safecall;
    function FreePic(const pic_name: WideString): Integer; safecall;
    function GetScreenData(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : Integer; safecall;
    function FreeScreenData(handle: Integer): Integer; safecall;
    function WheelUp: Integer; safecall;
    function WheelDown: Integer; safecall;
    function SetMouseDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function SetKeypadDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function GetEnv(index: Integer; const name: WideString)
      : WideString; safecall;
    function SetEnv(index: Integer; const name: WideString;
      const value: WideString): Integer; safecall;
    function SendString(hwnd: Integer; const Str: WideString): Integer;
      safecall;
    function DelEnv(index: Integer; const name: WideString): Integer; safecall;
    function GetPath: WideString; safecall;
    function SetDict(index: Integer; const dict_name: WideString)
      : Integer; safecall;
    function FindPic(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindPicEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function SetClientSize(hwnd: Integer; width: Integer; height: Integer)
      : Integer; safecall;
    function ReadInt(hwnd: Integer; const addr: WideString; type_: Integer)
      : Integer; safecall;
    function ReadFloat(hwnd: Integer; const addr: WideString): Single; safecall;
    function ReadDouble(hwnd: Integer; const addr: WideString): Double;
      safecall;
    function FindInt(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer)
      : WideString; safecall;
    function FindFloat(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single): WideString; safecall;
    function FindDouble(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double): WideString; safecall;
    function FindString(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer): WideString; safecall;
    function GetModuleBaseAddr(hwnd: Integer; const module_name: WideString)
      : Integer; safecall;
    function MoveToEx(X: Integer; Y: Integer; w: Integer; h: Integer)
      : WideString; safecall;
    function MatchPicName(const pic_name: WideString): WideString; safecall;
    function AddDict(index: Integer; const dict_info: WideString)
      : Integer; safecall;
    function EnterCri: Integer; safecall;
    function LeaveCri: Integer; safecall;
    function WriteInt(hwnd: Integer; const addr: WideString; type_: Integer;
      v: Integer): Integer; safecall;
    function WriteFloat(hwnd: Integer; const addr: WideString; v: Single)
      : Integer; safecall;
    function WriteDouble(hwnd: Integer; const addr: WideString; v: Double)
      : Integer; safecall;
    function WriteString(hwnd: Integer; const addr: WideString; type_: Integer;
      const v: WideString): Integer; safecall;
    function AsmAdd(const asm_ins: WideString): Integer; safecall;
    function AsmClear: Integer; safecall;
    function AsmCall(hwnd: Integer; mode: Integer): Integer; safecall;
    function FindMultiColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const first_color: WideString; const offset_color: WideString;
      sim: Double; dir: Integer; out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function FindMultiColorEx(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const first_color: WideString;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function AsmCode(base_addr: Integer): WideString; safecall;
    function Assemble(const asm_code: WideString; base_addr: Integer;
      is_upper: Integer): WideString; safecall;
    function SetWindowTransparent(hwnd: Integer; v: Integer): Integer; safecall;
    function ReadData(hwnd: Integer; const addr: WideString; len: Integer)
      : WideString; safecall;
    function WriteData(hwnd: Integer; const addr: WideString;
      const data: WideString): Integer; safecall;
    function FindData(hwnd: Integer; const addr_range: WideString;
      const data: WideString): WideString; safecall;
    function SetPicPwd(const pwd: WideString): Integer; safecall;
    function Log(const info: WideString): Integer; safecall;
    function FindStrE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindColorE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function FindPicE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function FindMultiColorE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const first_color: WideString; const offset_color: WideString;
      sim: Double; dir: Integer): WideString; safecall;
    function SetExactOcr(exact_ocr: Integer): Integer; safecall;
    function ReadString(hwnd: Integer; const addr: WideString; type_: Integer;
      len: Integer): WideString; safecall;
    function FoobarTextPrintDir(hwnd: Integer; dir: Integer): Integer; safecall;
    function OcrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function SetDisplayInput(const mode: WideString): Integer; safecall;
    function GetTime: Integer; safecall;
    function GetScreenWidth: Integer; safecall;
    function GetScreenHeight: Integer; safecall;
    function BindWindowEx(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString;
      const public_desc: WideString; mode: Integer): Integer; safecall;
    function GetDiskSerial: WideString; safecall;
    function Md5(const Str: WideString): WideString; safecall;
    function GetMac: WideString; safecall;
    function ActiveInputMethod(hwnd: Integer; const id: WideString)
      : Integer; safecall;
    function CheckInputMethod(hwnd: Integer; const id: WideString)
      : Integer; safecall;
    function FindInputMethod(const id: WideString): Integer; safecall;
    function GetCursorPos(out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function BindWindow(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString; mode: Integer)
      : Integer; safecall;
    function FindWindow(const class_name: WideString;
      const title_name: WideString): Integer; safecall;
    function GetScreenDepth: Integer; safecall;
    function SetScreen(width: Integer; height: Integer; depth: Integer)
      : Integer; safecall;
    function ExitOs(type_: Integer): Integer; safecall;
    function GetDir(type_: Integer): WideString; safecall;
    function GetOsType: Integer; safecall;
    function FindWindowEx(parent: Integer; const class_name: WideString;
      const title_name: WideString): Integer; safecall;
    function SetExportDict(index: Integer; const dict_name: WideString)
      : Integer; safecall;
    function GetCursorShape: WideString; safecall;
    function DownCpu(rate: Integer): Integer; safecall;
    function GetCursorSpot: WideString; safecall;
    function SendString2(hwnd: Integer; const Str: WideString)
      : Integer; safecall;
    function FaqPost(const server: WideString; handle: Integer;
      request_type: Integer; time_out: Integer): Integer; safecall;
    function FaqFetch: WideString; safecall;
    function FetchWord(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; const word: WideString): WideString; safecall;
    function CaptureJpg(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString; quality: Integer): Integer; safecall;
    function FindStrWithFont(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindStrWithFontE(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer)
      : WideString; safecall;
    function FindStrWithFontEx(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const Str: WideString; const color: WideString; sim: Double;
      const font_name: WideString; font_size: Integer; flag: Integer)
      : WideString; safecall;
    function GetDictInfo(const Str: WideString; const font_name: WideString;
      font_size: Integer; flag: Integer): WideString; safecall;
    function SaveDict(index: Integer; const file_: WideString)
      : Integer; safecall;
    function GetWindowProcessId(hwnd: Integer): Integer; safecall;
    function GetWindowProcessPath(hwnd: Integer): WideString; safecall;
    function LockInput(lock: Integer): Integer; safecall;
    function GetPicSize(const pic_name: WideString): WideString; safecall;
    function GetID: Integer; safecall;
    function CapturePng(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function CaptureGif(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString; delay: Integer; time: Integer): Integer;
      safecall;
    function ImageToBmp(const pic_name: WideString; const bmp_name: WideString)
      : Integer; safecall;
    function FindStrFast(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindStrFastEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function EnableDisplayDebug(enable_debug: Integer): Integer; safecall;
    function CapturePre(const file_: WideString): Integer; safecall;
    function RegEx(const code: WideString; const Ver: WideString;
      const ip: WideString): Integer; safecall;
    function GetMachineCode: WideString; safecall;
    function SetClipboard(const data: WideString): Integer; safecall;
    function GetClipboard: WideString; safecall;
    function GetNowDict: Integer; safecall;
    function Is64Bit: Integer; safecall;
    function GetColorNum(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): Integer; safecall;
    function EnumWindowByProcess(const process_name: WideString;
      const title: WideString; const class_name: WideString; filter: Integer)
      : WideString; safecall;
    function GetDictCount(index: Integer): Integer; safecall;
    function GetLastError: Integer; safecall;
    function GetNetTime: WideString; safecall;
    function EnableGetColorByCapture(en: Integer): Integer; safecall;
    function CheckUAC: Integer; safecall;
    function SetUAC(uac: Integer): Integer; safecall;
    function DisableFontSmooth: Integer; safecall;
    function CheckFontSmooth: Integer; safecall;
    function SetDisplayAcceler(level: Integer): Integer; safecall;
    function FindWindowByProcess(const process_name: WideString;
      const class_name: WideString; const title_name: WideString)
      : Integer; safecall;
    function FindWindowByProcessId(process_id: Integer;
      const class_name: WideString; const title_name: WideString)
      : Integer; safecall;
    function ReadIni(const section: WideString; const key: WideString;
      const file_: WideString): WideString; safecall;
    function WriteIni(const section: WideString; const key: WideString;
      const v: WideString; const file_: WideString): Integer; safecall;
    function RunApp(const path: WideString; mode: Integer): Integer; safecall;
    function delay(mis: Integer): Integer; safecall;
    function FindWindowSuper(const spec1: WideString; flag1: Integer;
      type1: Integer; const spec2: WideString; flag2: Integer; type2: Integer)
      : Integer; safecall;
    function ExcludePos(const all_pos: WideString; type_: Integer; X1: Integer;
      Y1: Integer; X2: Integer; Y2: Integer): WideString; safecall;
    function FindNearestPos(const all_pos: WideString; type_: Integer;
      X: Integer; Y: Integer): WideString; safecall;
    function SortPosDistance(const all_pos: WideString; type_: Integer;
      X: Integer; Y: Integer): WideString; safecall;
    function FindPicMem(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindPicMemEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function FindPicMemE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_info: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function AppendPicAddr(const pic_info: WideString; addr: Integer;
      size: Integer): WideString; safecall;
    function WriteFile(const file_: WideString; const content: WideString)
      : Integer; safecall;
    function Stop(id: Integer): Integer; safecall;
    function SetDictMem(index: Integer; addr: Integer; size: Integer)
      : Integer; safecall;
    function GetNetTimeSafe: WideString; safecall;
    function ForceUnBindWindow(hwnd: Integer): Integer; safecall;
    function ReadIniPwd(const section: WideString; const key: WideString;
      const file_: WideString; const pwd: WideString): WideString; safecall;
    function WriteIniPwd(const section: WideString; const key: WideString;
      const v: WideString; const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function DecodeFile(const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function KeyDownChar(const key_str: WideString): Integer; safecall;
    function KeyUpChar(const key_str: WideString): Integer; safecall;
    function KeyPressChar(const key_str: WideString): Integer; safecall;
    function KeyPressStr(const key_str: WideString; delay: Integer)
      : Integer; safecall;
    function EnableKeypadPatch(en: Integer): Integer; safecall;
    function EnableKeypadSync(en: Integer; time_out: Integer): Integer;
      safecall;
    function EnableMouseSync(en: Integer; time_out: Integer): Integer; safecall;
    function DmGuard(en: Integer; const type_: WideString): Integer; safecall;
    function FaqCaptureFromFile(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const file_: WideString; quality: Integer): Integer;
      safecall;
    function FindIntEx(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer;
      step: Integer; multi_thread: Integer; mode: Integer): WideString;
      safecall;
    function FindFloatEx(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDoubleEx(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindStringEx(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDataEx(hwnd: Integer; const addr_range: WideString;
      const data: WideString; step: Integer; multi_thread: Integer;
      mode: Integer): WideString; safecall;
    function EnableRealMouse(en: Integer; mousedelay: Integer;
      mousestep: Integer): Integer; safecall;
    function EnableRealKeypad(en: Integer): Integer; safecall;
    function SendStringIme(const Str: WideString): Integer; safecall;
    function FoobarDrawLine(hwnd: Integer; X1: Integer; Y1: Integer;
      X2: Integer; Y2: Integer; const color: WideString; style: Integer;
      width: Integer): Integer; safecall;
    function FindStrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function IsBind(hwnd: Integer): Integer; safecall;
    function SetDisplayDelay(t: Integer): Integer; safecall;
    function GetDmCount: Integer; safecall;
    function DisableScreenSave: Integer; safecall;
    function DisablePowerSave: Integer; safecall;
    function SetMemoryHwndAsProcessId(en: Integer): Integer; safecall;
    function FindShape(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer;
      out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindShapeE(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function FindShapeEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const offset_color: WideString; sim: Double; dir: Integer)
      : WideString; safecall;
    function FindStrS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindStrExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double;
      out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindStrFastExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const Str: WideString; const color: WideString; sim: Double)
      : WideString; safecall;
    function FindPicS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out X: OleVariant; out Y: OleVariant): WideString; safecall;
    function FindPicExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function ClearDict(index: Integer): Integer; safecall;
    function GetMachineCodeNoMac: WideString; safecall;
    function GetClientRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function EnableFakeActive(en: Integer): Integer; safecall;
    function GetScreenDataBmp(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; out data: OleVariant; out size: OleVariant)
      : Integer; safecall;
    function EncodeFile(const file_: WideString; const pwd: WideString)
      : Integer; safecall;
    function GetCursorShapeEx(type_: Integer): WideString; safecall;
    function FaqCancel: Integer; safecall;
    function IntToData(int_value: Integer; type_: Integer): WideString;
      safecall;
    function FloatToData(float_value: Single): WideString; safecall;
    function DoubleToData(double_value: Double): WideString; safecall;
    function StringToData(const string_value: WideString; type_: Integer)
      : WideString; safecall;
    function SetMemoryFindResultToFile(const file_: WideString)
      : Integer; safecall;
    function EnableBind(en: Integer): Integer; safecall;
    function SetSimMode(mode: Integer): Integer; safecall;
    function LockMouseRect(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : Integer; safecall;
    function SendPaste(hwnd: Integer): Integer; safecall;
    function IsDisplayDead(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      t: Integer): Integer; safecall;
    function GetKeyState(vk: Integer): Integer; safecall;
    function CopyFile(const src_file: WideString; const dst_file: WideString;
      over: Integer): Integer; safecall;
    function IsFileExist(const file_: WideString): Integer; safecall;
    function DeleteFile(const file_: WideString): Integer; safecall;
    function MoveFile(const src_file: WideString; const dst_file: WideString)
      : Integer; safecall;
    function CreateFolder(const folder_name: WideString): Integer; safecall;
    function DeleteFolder(const folder_name: WideString): Integer; safecall;
    function GetFileLength(const file_: WideString): Integer; safecall;
    function ReadFile(const file_: WideString): WideString; safecall;
    function WaitKey(key_code: Integer; time_out: Integer): Integer; safecall;
    function DeleteIni(const section: WideString; const key: WideString;
      const file_: WideString): Integer; safecall;
    function DeleteIniPwd(const section: WideString; const key: WideString;
      const file_: WideString; const pwd: WideString): Integer; safecall;
    function EnableSpeedDx(en: Integer): Integer; safecall;
    function EnableIme(en: Integer): Integer; safecall;
    function Reg(const code: WideString; const Ver: WideString)
      : Integer; safecall;
    function SelectFile: WideString; safecall;
    function SelectDirectory: WideString; safecall;
    function LockDisplay(lock: Integer): Integer; safecall;
    function FoobarSetSave(hwnd: Integer; const file_: WideString; en: Integer;
      const header: WideString): Integer; safecall;
    function EnumWindowSuper(const spec1: WideString; flag1: Integer;
      type1: Integer; const spec2: WideString; flag2: Integer; type2: Integer;
      sort: Integer): WideString; safecall;
    function DownloadFile(const url: WideString; const save_file: WideString;
      timeout: Integer): Integer; safecall;
    function EnableKeypadMsg(en: Integer): Integer; safecall;
    function EnableMouseMsg(en: Integer): Integer; safecall;
    function RegNoMac(const code: WideString; const Ver: WideString)
      : Integer; safecall;
    function RegExNoMac(const code: WideString; const Ver: WideString;
      const ip: WideString): Integer; safecall;
    function SetEnumWindowDelay(delay: Integer): Integer; safecall;
    function FindMulColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): Integer; safecall;
    function GetDict(index: Integer; font_index: Integer): WideString; safecall;
    function GetBindWindow: Integer; safecall;
    function FoobarStartGif(hwnd: Integer; X: Integer; Y: Integer;
      const pic_name: WideString; repeat_limit: Integer; delay: Integer)
      : Integer; safecall;
    function FoobarStopGif(hwnd: Integer; X: Integer; Y: Integer;
      const pic_name: WideString): Integer; safecall;
    function FreeProcessMemory(hwnd: Integer): Integer; safecall;
    function ReadFileData(const file_: WideString; start_pos: Integer;
      end_pos: Integer): WideString; safecall;
    function VirtualAllocEx(hwnd: Integer; addr: Integer; size: Integer;
      type_: Integer): Integer; safecall;
    function VirtualFreeEx(hwnd: Integer; addr: Integer): Integer; safecall;
    function GetCommandLine(hwnd: Integer): WideString; safecall;
    function TerminateProcess(pid: Integer): Integer; safecall;
    function GetNetTimeByIp(const ip: WideString): WideString; safecall;
    function EnumProcess(const name: WideString): WideString; safecall;
    function GetProcessInfo(pid: Integer): WideString; safecall;
    function ReadIntAddr(hwnd: Integer; addr: Integer; type_: Integer)
      : Integer; safecall;
    function ReadDataAddr(hwnd: Integer; addr: Integer; len: Integer)
      : WideString; safecall;
    function ReadDoubleAddr(hwnd: Integer; addr: Integer): Double; safecall;
    function ReadFloatAddr(hwnd: Integer; addr: Integer): Single; safecall;
    function ReadStringAddr(hwnd: Integer; addr: Integer; type_: Integer;
      len: Integer): WideString; safecall;
    function WriteDataAddr(hwnd: Integer; addr: Integer; const data: WideString)
      : Integer; safecall;
    function WriteDoubleAddr(hwnd: Integer; addr: Integer; v: Double)
      : Integer; safecall;
    function WriteFloatAddr(hwnd: Integer; addr: Integer; v: Single)
      : Integer; safecall;
    function WriteIntAddr(hwnd: Integer; addr: Integer; type_: Integer;
      v: Integer): Integer; safecall;
    function WriteStringAddr(hwnd: Integer; addr: Integer; type_: Integer;
      const v: WideString): Integer; safecall;
    function Delays(min_s: Integer; max_s: Integer): Integer; safecall;
    function FindColorBlock(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; count: Integer; width: Integer;
      height: Integer; out X: OleVariant; out Y: OleVariant): Integer; safecall;
    function FindColorBlockEx(X1: Integer; Y1: Integer; X2: Integer;
      Y2: Integer; const color: WideString; sim: Double; count: Integer;
      width: Integer; height: Integer): WideString; safecall;
    function OpenProcess(pid: Integer): Integer; safecall;
    function EnumIniSection(const file_: WideString): WideString; safecall;
    function EnumIniSectionPwd(const file_: WideString; const pwd: WideString)
      : WideString; safecall;
    function EnumIniKey(const section: WideString; const file_: WideString)
      : WideString; safecall;
    function EnumIniKeyPwd(const section: WideString; const file_: WideString;
      const pwd: WideString): WideString; safecall;
    function SwitchBindWindow(hwnd: Integer): Integer; safecall;
    function InitCri: Integer; safecall;
    function SendStringIme2(hwnd: Integer; const Str: WideString; mode: Integer)
      : Integer; safecall;
    function EnumWindowByProcessId(pid: Integer; const title: WideString;
      const class_name: WideString; filter: Integer): WideString; safecall;
    function GetDisplayInfo: WideString; safecall;
    function EnableFontSmooth: Integer; safecall;
    function OcrExOne(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double): WideString; safecall;
    function SetAero(en: Integer): Integer; safecall;
    function FoobarSetTrans(hwnd: Integer; trans: Integer;
      const color: WideString; sim: Double): Integer; safecall;
    function EnablePicCache(en: Integer): Integer; safecall;
    function GetInfo(const cmd: WideString; const param: WideString)
      : WideString; safecall;
    function FaqIsPosted: Integer; safecall;
    function LoadPicByte(addr: Integer; size: Integer; const name: WideString)
      : Integer; safecall;
    function MiddleDown: Integer; safecall;
    function MiddleUp: Integer; safecall;
    function FaqCaptureString(const Str: WideString): Integer; safecall;
    function VirtualProtectEx(hwnd: Integer; addr: Integer; size: Integer;
      type_: Integer; old_protect: Integer): Integer; safecall;
    function SetMouseSpeed(speed: Integer): Integer; safecall;
    function GetMouseSpeed: Integer; safecall;
    function EnableMouseAccuracy(en: Integer): Integer; safecall;
  end;

  ITsObj = interface(IDispatch)
    ['{F3E95C10-606A-474E-BB4A-B9CCBF7DB559}']
    function BindWindow(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString; mode: Integer)
      : Integer; safecall;
    function BindWindowEx(hwnd: Integer; const display: WideString;
      const mouse: WideString; const keypad: WideString;
      const publics: WideString; mode: Integer): Integer; safecall;
    function UnBindWindow: Integer; safecall;
    function KeyDown(vk_code: Integer): Integer; safecall;
    function KeyUp(vk_code: Integer): Integer; safecall;
    function KeyPress(vk_code: Integer): Integer; safecall;
    function LeftDown: Integer; safecall;
    function LeftUp: Integer; safecall;
    function LeftClick: Integer; safecall;
    function MoveTo(X: Integer; Y: Integer): Integer; safecall;
    function FindPic(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out intX: OleVariant; out intY: OleVariant)
      : Integer; safecall;
    function RightClick: Integer; safecall;
    function RightDown: Integer; safecall;
    function FindColor(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer; out intX: OleVariant;
      out intY: OleVariant): Integer; safecall;
    function RightUp: Integer; safecall;
    function GetColor(X: Integer; Y: Integer): WideString; safecall;
    function GetCursorShape: WideString; safecall;
    function SetPath(const path: WideString): Integer; safecall;
    function TSGuardProtect(enable: Integer; const type_: WideString)
      : Integer; safecall;
    function KeyPressStr(const key_str: WideString; delay: Integer)
      : Integer; safecall;
    function SendString(hwnd: Integer; const Str: WideString): Integer;
      safecall;
    function SendString2(hwnd: Integer; const Str: WideString)
      : Integer; safecall;
    function KeyPressChar(const key_str: WideString): Integer; safecall;
    function KeyDownChar(const key_str: WideString): Integer; safecall;
    function KeyUpChar(const key_str: WideString): Integer; safecall;
    function GetCursorPos(out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function MoveR(rx: Integer; ry: Integer): Integer; safecall;
    function Ver: WideString; safecall;
    function GetPath: WideString; safecall;
    function MiddleClick: Integer; safecall;
    function WheelDown: Integer; safecall;
    function WheelUp: Integer; safecall;
    function Capture(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function CaptureJpg(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function CapturePng(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString): Integer; safecall;
    function LockInput(lock: Integer): Integer; safecall;
    function Ocr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color_format: WideString; sim: Single): WideString; safecall;
    function SetDict(index: Integer; const file_: WideString): Integer;
      safecall;
    function UseDict(index: Integer): Integer; safecall;
    function ClearDict(index: Integer): Integer; safecall;
    function FindStr(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Single;
      out intX: OleVariant; out intY: OleVariant): Integer; safecall;
    function FindStrFast(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Single;
      out intX: OleVariant; out intY: OleVariant): Integer; safecall;
    function GetNowDict: Integer; safecall;
    function GetBasePath: WideString; safecall;
    function IsDisplayDead(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      t: Integer): Integer; safecall;
    function FindPicEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function FindStrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double)
      : WideString; safecall;
    function CaptureGif(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const file_: WideString; delay: Integer; time: Integer): Integer;
      safecall;
    function DownCpu(rate: Integer): Integer; safecall;
    function SetKeypadDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function SetMouseDelay(const type_: WideString; delay: Integer)
      : Integer; safecall;
    function CmpColor(X: Integer; Y: Integer; const color: WideString;
      sim: Double): Integer; safecall;
    function SendStringIme(const Str: WideString): Integer; safecall;
    function FindColorEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function EnumWindow(parent: Integer; const title: WideString;
      const class_name: WideString; filter: Integer): WideString; safecall;
    function EnumWindowByProcess(const process_name: WideString;
      const title: WideString; const class_name: WideString; filter: Integer)
      : WideString; safecall;
    function EnumProcess(const name: WideString): WideString; safecall;
    function ClientToScreen(ClientToScreen: Integer; var X: OleVariant;
      var Y: OleVariant): Integer; safecall;
    function FindWindow(const class_name: WideString; const title: WideString)
      : Integer; safecall;
    function FindWindowByProcess(const process_name: WideString;
      const class_name: WideString; const title: WideString): Integer; safecall;
    function FindWindowByProcessId(process_id: Integer;
      const class_name: WideString; const title: WideString): Integer; safecall;
    function FindWindowEx(parent: Integer; const class_name: WideString;
      const title: WideString): Integer; safecall;
    function GetClientRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function GetClientSize(hwnd: Integer; out width: OleVariant;
      out height: OleVariant): Integer; safecall;
    function GetForegroundFocus: Integer; safecall;
    function GetForegroundWindow: Integer; safecall;
    function GetMousePointWindow: Integer; safecall;
    function GetPointWindow(X: Integer; Y: Integer): Integer; safecall;
    function GetProcessInfo(pid: Integer): WideString; safecall;
    function GetSpecialWindow(flag: Integer): Integer; safecall;
    function GetWindow(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetWindowClass(hwnd: Integer): WideString; safecall;
    function GetWindowProcessId(hwnd: Integer): Integer; safecall;
    function GetWindowProcessPath(hwnd: Integer): WideString; safecall;
    function GetWindowRect(hwnd: Integer; out X1: OleVariant;
      out Y1: OleVariant; out X2: OleVariant; out Y2: OleVariant)
      : Integer; safecall;
    function GetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetWindowTitle(hwnd: Integer): WideString; safecall;
    function MoveWindow(hwnd: Integer; X: Integer; Y: Integer)
      : Integer; safecall;
    function ScreenToClient(hwnd: Integer; out X: OleVariant; out Y: OleVariant)
      : Integer; safecall;
    function SendPaste(hwnd: Integer): Integer; safecall;
    function SetClientSize(hwnd: Integer; width: Integer; hight: Integer)
      : Integer; safecall;
    function SetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function SetWindowSize(hwnd: Integer; width: Integer; height: Integer)
      : Integer; safecall;
    function SetWindowText(hwnd: Integer; const title: WideString)
      : Integer; safecall;
    function SetWindowTransparent(hwnd: Integer; trans: Integer)
      : Integer; safecall;
    function SetClipboard(const value: WideString): Integer; safecall;
    function GetClipboard: WideString; safecall;
    function DoubleToData(value: Double): WideString; safecall;
    function FloatToData(value: Single): WideString; safecall;
    function IntToData(value: Integer; type_: Integer): WideString; safecall;
    function StringToData(const value: WideString; type_: Integer)
      : WideString; safecall;
    function FindData(hwnd: Integer; const addr_range: WideString;
      const data: WideString): WideString; safecall;
    function FindDouble(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double): WideString; safecall;
    function FindFloat(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single): WideString; safecall;
    function FindInt(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer)
      : WideString; safecall;
    function FindString(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer): WideString; safecall;
    function ReadData(hwnd: Integer; const addr: WideString; len: Integer)
      : WideString; safecall;
    function OcrEx(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const color_format: WideString; sim: Double): WideString; safecall;
    function ReadDouble(hwnd: Integer; const addr: WideString): Double;
      safecall;
    function ReadFloat(hwnd: Integer; const addr: WideString): Single; safecall;
    function ReadInt(hwnd: Integer; const addr: WideString; type_: Integer)
      : Integer; safecall;
    function ReadString(hwnd: Integer; const addr: WideString; type_: Integer;
      len: Integer): WideString; safecall;
    function TerminateProcess(pid: Integer): Integer; safecall;
    function VirtualAllocEx(hwnd: Integer; addr: Integer; size: Integer;
      type_: Integer): Integer; safecall;
    function VirtualFreeEx(hwnd: Integer; addr: Integer): Integer; safecall;
    function WriteDouble(hwnd: Integer; const addr: WideString; v: Double)
      : Integer; safecall;
    function WriteFloat(hwnd: Integer; const addr: WideString; v: Single)
      : Integer; safecall;
    function WriteInt(hwnd: Integer; const addr: WideString; type_: Integer;
      v: Integer): Integer; safecall;
    function WriteString(hwnd: Integer; const addr: WideString; type_: Integer;
      const v: WideString): Integer; safecall;
    function WriteData(hwnd: Integer; const addr: WideString;
      const data: WideString): Integer; safecall;
    function IsBind(hwnd: Integer): Integer; safecall;
    function FindFloatEx(hwnd: Integer; const addr_range: WideString;
      float_value_min: Single; float_value_max: Single; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDoubleEx(hwnd: Integer; const addr_range: WideString;
      double_value_min: Double; double_value_max: Double; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindIntEx(hwnd: Integer; const addr_range: WideString;
      int_value_min: Integer; int_value_max: Integer; type_: Integer;
      step: Integer; multi_thread: Integer; mode: Integer): WideString;
      safecall;
    function FindDataEx(hwnd: Integer; const addr_range: WideString;
      const data: WideString; step: Integer; multi_thread: Integer;
      mode: Integer): WideString; safecall;
    function FindStringEx(hwnd: Integer; const addr_range: WideString;
      const string_value: WideString; type_: Integer; step: Integer;
      multi_thread: Integer; mode: Integer): WideString; safecall;
    function GetModuleBaseAddr(hwnd: Integer; const modulename: WideString)
      : Integer; safecall;
    function GetCommandLine(hwnd: Integer): WideString; safecall;
    function AsmAdd(const asm_ins: WideString): Integer; safecall;
    function AsmCall(hwnd: Integer; mode: Integer): Integer; safecall;
    function AsmClear: Integer; safecall;
    function AsmCode(base_addr: Integer): WideString; safecall;
    function Assemble(const asm_code: WideString; base_addr: Integer;
      is_upper: Integer): WideString; safecall;
    function MatchPicName(const pic_name: WideString): WideString; safecall;
    function SetShowErrorMsg(show: Integer): Integer; safecall;
    function Reg(const reg_code: WideString; type_: Integer): Integer; safecall;
    function GetMachineCode: WideString; safecall;
    function TSGuardProtectToHide(enble: Integer): Integer; safecall;
    function TSGuardProtectToHide2(enable: Integer): Integer; safecall;
    function TSGuardProtectToNP(enable: Integer): Integer; safecall;
    function delay(mis: Integer): Integer; safecall;
    function FindStrS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double;
      out intX: OleVariant; out intY: OleVariant): WideString; safecall;
    function FindStrFastS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double;
      out intX: OleVariant; out intY: OleVariant): WideString; safecall;
    function FindStrExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double)
      : WideString; safecall;
    function FindStrFastExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const string_: WideString; const color_format: WideString; sim: Double)
      : WideString; safecall;
    function FindPicS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer; out intX: OleVariant; out intY: OleVariant)
      : WideString; safecall;
    function FindPicExS(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
      const pic_name: WideString; const delta_color: WideString; sim: Double;
      dir: Integer): WideString; safecall;
    function SetDictPwd(const pwd: WideString): Integer; safecall;
    function SetPicPwd(const pwd: WideString): Integer; safecall;
    function LeftDoubleClick: Integer; safecall;
    function FreeProcessMemory(hwnd: Integer): Integer; safecall;
    function TSDXGraphicProtect(enable: Integer): Integer; safecall;
    function TSDXKmProtect(enable: Integer; const type_: WideString)
      : Integer; safecall;
    function CheckFontSmooth: Integer; safecall;
    function DisableFontSmooth: Integer; safecall;
    function GetScreenData(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer)
      : Integer; safecall;
    function EnableRealMouse(enable: LongWord; mousedelay: LongWord;
      mousestep: LongWord): LongWord; safecall;
    function EnableRealKeypad(enable: LongWord): LongWord; safecall;
    function MoveToEx(X: LongWord; Y: LongWord; w: LongWord; h: LongWord)
      : WideString; safecall;
    function CheckUAC: LongWord; safecall;
    function SetUAC(enable: LongWord): LongWord; safecall;
    function WaitKey(vk_code: LongWord; time_out: LongWord): LongWord; safecall;
    function FindMultiColor(X1: LongWord; Y1: LongWord; X2: LongWord;
      Y2: LongWord; const first_color: WideString;
      const offset_color: WideString; sim: Double; dir: LongWord;
      out intX: OleVariant; out intY: OleVariant): LongWord; safecall;
    function FindMultiColorEx(X1: LongWord; Y1: LongWord; X2: LongWord;
      Y2: LongWord; const first_color: WideString;
      const offset_color: WideString; sim: Double; dir: LongWord)
      : WideString; safecall;
    function SetSimMode(mode: LongWord): LongWord; safecall;
  end;

implementation

{ TWComService }

class function TComService.CreateComObjFromDll(CLASS_ID: TGUID;
  ADllHandle: HMODULE): IDispatch;
var
  lFactory: IClassFactory;
  lHRESULT: HRESULT;
  lDllGetClassObject: function(const CLSID, IID: TGUID; var Obj)
    : HRESULT; stdcall;
begin
  Result := nil;
  lDllGetClassObject := GetProcAddress(ADllHandle, 'DllGetClassObject');
  if Assigned(lDllGetClassObject) then
  begin
    lHRESULT := lDllGetClassObject(CLASS_ID, IClassFactory, lFactory);
    if lHRESULT = S_OK then
    begin
      lFactory.CreateInstance(nil, IDispatch, Result);
    end;
  end;

end;

class function TComService.CreateOleObj(const ClassName: string): IDispatch;
begin
  Result := CreateOleObject(ClassName);
end;

class destructor TComService.Destroy;
begin
  // 不必调用也会自动释放,如果强制调用可能会出错
  // FreeAllDll;
  FreeAndNil(FDllDictionary); // 释放对象
end;

class procedure TComService.FreeAllDll;
var
  lHandle: THandle;
begin
  if Assigned(FDllDictionary) then
  begin
    for lHandle in FDllDictionary.Values do
      FreeLibrary(lHandle);
    FreeAndNil(FDllDictionary);
  end;
end;

class procedure TComService.FreeDll(const aDllPath: string);
var
  lHandle: THandle;
begin
  if Assigned(FDllDictionary) then
  begin
    if FDllDictionary.TryGetValue(aDllPath, lHandle) then
    begin
      FreeLibrary(lHandle);
      FDllDictionary.Remove(aDllPath);
    end;

  end;

end;

class function TComService.IsReg(const aComClassName: string): Boolean;
begin
  Result := True;
  try
    CreateOleObject(aComClassName);
  except
    Result := False;
  end;
end;

class function TComService.NoRegCreateComObj(const CLASS_ID: TGUID;
  const aDllPath: string): IDispatch;
  procedure CheckPath;
  begin
    if not FileExists(aDllPath) then
      raise Exception.CreateFmt('%s插件路径不存在', [aDllPath]);
  end;

var
  lDllHandle: THandle;
begin
  Result := nil;
  CheckPath;
  // 判断是否已经加载
  if not Assigned(FDllDictionary) then
  begin
    FDllDictionary := TDictionary<string, THandle>.Create();
  end;

  // 未加载进行加载
  if not FDllDictionary.ContainsKey(aDllPath) then

  begin
    lDllHandle := SafeLoadLibrary(aDllPath);
    if lDllHandle = 0 then
      raise Exception.CreateFmt('加载%失败', [aDllPath]);

  end
  else
    // 已经加载从词典中获取句柄
    lDllHandle := FDllDictionary[aDllPath];
  // 创建对象
  Result := CreateComObjFromDll(CLASS_ID, lDllHandle);
  // 对象创建成功加入到词典
  if Assigned(Result) then
  begin
    if not FDllDictionary.ContainsKey(aDllPath) then
      FDllDictionary.Add(aDllPath, lDllHandle);
    { 如果存在更新,不存在则添加 }
  end;
  // Assert(result<>nil,'免注册对象创建失败');
  if Result = nil then
    raise Exception.Create('免注册对象创建失败');

end;

class function TComService.RegCom(const aPath: string;
  const aReg: Boolean): Boolean;
type
  TOleRegisterFunction = function: HRESULT; stdcall; // 注册或卸载函数原型
var
  hLibraryHandle: THandle; // 由LoadLibray返回的DLL或OCX句柄
  // hFunctionAddress: TFarProc; // DLL或OCX中的函数句柄，由GetProAddress返回
  RegFunction: TOleRegisterFunction; // 注册或卸载函数指针
begin
  Result := False;
  // 打开文件，返回DLL或OCX句柄

  hLibraryHandle := SafeLoadLibrary(aPath);
  if (hLibraryHandle > HINSTANCE_ERROR) then // DLLakg OCX句柄正确
    try
      // 返回注册或卸载函数指针
      if (aReg) then
        // 返回注册函数指针
        RegFunction := GetProcAddress(hLibraryHandle,
          PAnsiChar('DllRegisterServer'))
      else
        // 返回卸载函数指针
        RegFunction := GetProcAddress(hLibraryHandle,
          PAnsiChar('DllUnregisterServer'));
      // 判断注册或卸载函数是否存在
      if Assigned(RegFunction) then
      begin
        if (RegFunction = S_OK) then
          Result := True;
      end;
    finally
      // 关闭已打开的文件
      FreeLibrary(hLibraryHandle);
    end;

end;

class function TComService.RegCom(const aPath: string): Boolean;
begin
  Result := RegCom(aPath, True);
end;

class procedure TComService.RegCommond(const aFileName: string;
  const aDoReg: Boolean);
var
  flName: string;
  ret: Cardinal;
begin
  if aDoReg then
    flName := 'TRegSvr.exe ' + aFileName
  else
    flName := 'TRegSvr.exe -u ' + aFileName;
  ret := WinExec(PAnsiChar(AnsiString(flName)), SW_HIDE);
  if ret <= 31 then
    raise Exception.Create(SysErrorMessage(ret));
end;

class procedure TComService.RegisterComServer(const aDllName: string);
begin
  System.Win.ComObj.RegisterComServer(aDllName);
end;

class function TComService.UnregCom(const aPath: string): Boolean;
begin
  Result := RegCom(aPath, False);
end;

{ TObjConfig }
// f2盾支持的函数暂时用不到被移除
class procedure TObjConfig.GetF2GuardRealDir(const aAppName: string);
var
  aText: string;
begin
  if aAppName.IsEmpty then
    Exit;
  aText := Clipboard.AsText;
  if aText.Contains(aAppName) then
  begin
    ChDir(ExtractFileDir(aText));
  end;
end;

class constructor TObjConfig.Create;
begin
  TObjConfig.ChargeFullPath := cChargeFullPath;
  TObjConfig.FreeFullPath := cFreeFullPath;
  TObjConfig.TsFullPath := cTsFullPath;
  TObjConfig.RegCode := cRegCode;
  TObjConfig.RegVer := cRegVer;
end;

{ TObjFactory }

class function TObjFactory.CreateChargeObj: IChargeObj;
var
  iRet: Integer;
begin
  Result := TComService.NoRegCreateComObj(CLASS_DMPluginInterface,
    TObjConfig.ChargeFullPath) as IChargeObj;
  if not Assigned(Result) then
    raise Exception.Create('创建收费对象失败！');
  iRet := Result.Reg(TObjConfig.RegCode, TObjConfig.RegVer);
  if iRet <> 1 then
    raise Exception.CreateFmt('插件收费功能注册失败，错误码：%d', [iRet]);
end;

class function TObjFactory.CreateFreeObj: IFreeObj;
begin
  Result := TComService.NoRegCreateComObj(CLASS_DMPluginInterface,
    TObjConfig.FreeFullPath) as IFreeObj;
  if not Assigned(Result) then
    raise Exception.Create('对象创建失败！');
end;

class function TObjFactory.CreateMyObj(aObj: IChargeObj): TMyObj;
begin
  Result := TMyObj.Create(aObj);
end;

class function TObjFactory.CreateTsObj: ITsObj;
begin
  Result := TComService.NoRegCreateComObj(CLASS_TSPlugInterface,
    TObjConfig.TsFullPath) as ITsObj;
  if not Assigned(Result) then
    raise Exception.Create('对象创建失败！');
end;
{ TMyObj }

constructor TMyObj.Create(aObj: IChargeObj);
begin
  Assert(Assigned(aObj));
  FObj := aObj;
end;

destructor TMyObj.Destroy;
begin
  inherited;
end;

function TMyObj.FindData(hwnd: Integer; const addr_range,
  data: WideString): TArray<string>;
var
  Str: string;
begin
  Str := FObj.FindData(hwnd, addr_range, data);
  Result := Str.Split(['|']);
end;

function TMyObj.FindDataEx(hwnd: Integer; const addr_range, data: WideString;
  step, multi_thread, mode: Integer): TArray<string>;
var
  Str: string;
begin
  Str := FObj.FindDataEx(hwnd, addr_range, data, step, multi_thread, mode);
  Result := Str.Split(['|']);
end;

function TMyObj.OcrEx(X1, Y1, X2, Y2: Integer; color_format: string;
  sim: Double; out OutStr: string): TArray<TOcrStr>;
var
  Str: string;
  strAndPosArr: TArray<string>;
  arr: TArray<string>;
  I: Integer;
  ocrStr: TOcrStr;
begin
  OutStr := '';
  Str := FObj.OcrEx(X1, Y1, X2, Y2, color_format, sim); // 识别字
  strAndPosArr := Str.Split(['|']); // 进行一次分割
  Result := [];
  for I := Low(strAndPosArr) to High(strAndPosArr) do
  begin
    arr := strAndPosArr[I].Split(['$']); // 进行二次分割
    OutStr := OutStr + arr[0]; // 保存字串
    ocrStr.Str := arr[0];
    ocrStr.X := arr[1].ToInteger();
    ocrStr.Y := arr[2].ToInteger();
    Result := Result + [ocrStr];
  end;
end;

end.
