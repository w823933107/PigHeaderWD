{

  2016/5/7
  =====================
  +TMyObj����ڴ���صĺ���
  2016/4/27
  =====================
  *�Ƴ�ע������ܹ���
  *����TMyObj.OcrEx��������
  2016/3/20
  =====================
  *���������˳�ʱdll������δ�ͷ�,����ڴ�й¶�Ĵ���

}

unit uObj;

interface

uses
  System.Generics.Collections, Winapi.Windows, Winapi.ActiveX,
  System.Win.ComObj, System.SysUtils, Vcl.Clipbrd;

const

  // --------һЩ�����������Ϣ---------------
  // Ĭ��ע����
  cRegCode = 'gxhxwme5e07ca5bc2945976a2be4a9cabdcb81';
  // ע��汾��Ϣ,ͨ��������������
  cRegVer = 'pighead';
  // �շѲ��·��
  cChargeFullPath = '.\Bin\Charge.dll';
  // ��Ѳ��·��
  cFreeFullPath = '.\Bin\Free.dll';
  // ��ʹ���·��
  cTsFullPath = '.\Bin\Ts.dll';
  // ---------------com�ĳ���ֵ,�����޸�
  // cPluginClassName: string = 'dm.dmsoft';
  CLASS_TSPlugInterface: TGUID = '{BCE4A484-C3BC-418B-B1F6-69D6987C126B}';
  CLASS_DMPluginInterface: TGUID = '{26037A0E-7CBD-4FFF-9C63-56F2D0770214}';

type

  // ����COM��һЩ������
  TComService = class
  strict private
    // �洢dll�����ʺ�,ģ����
    class var FDllDictionary: TDictionary<string, THandle>;
  strict private
    // ��dll�д���com
    class function CreateComObjFromDll(CLASS_ID: TGUID; ADllHandle: HMODULE)
      : IDispatch; static;
    // �����˳����ͷż��ص�dll
    class destructor Destroy;
  public
    // ʹ��ϵͳ�Դ���ע�᷽ʽ�����Լ���װ������dll����������һ���ģ��������ֻ��ע�Ṧ��
    class procedure RegisterComServer(const aDllName: string);
    // �ж��Ƿ�ע��
    class function IsReg(const aComClassName: string): Boolean;
    // ע��ͷ�ע��
    class function RegCom(const aPath: string; const aReg: Boolean)
      : Boolean; overload;
    // ����dll·��ע��
    class function RegCom(const aPath: string): Boolean; overload;
    // ����·��ж��
    class function UnregCom(const aPath: string): Boolean;
    // ��ע������Զ�������
    class function NoRegCreateComObj(const CLASS_ID: TGUID;
      const aDllPath: string): IDispatch;
    // ����������������
    class function CreateOleObj(const ClassName: string): IDispatch;
    // ����·���ͷ���ע��dll
    class procedure FreeDll(const aDllPath: string);
    // �ͷ����е�dll
    class procedure FreeAllDll;
    // ����TRegSvr.exeע��
    class procedure RegCommond(const aFileName: string; const aDoReg: Boolean);
  end;

  // ��̬���ýṹ���ɶ���ֱ�ӽ�������
  TObjConfig = record
  private
    class constructor Create();
  public
  class var
    ChargeFullPath: string; // �շѲ��ȫ·��
    FreeFullPath: string; // ��Ѳ��ȫ·��
    TsFullPath: string;
    RegCode: string;
    RegVer: string;
    // �ṩ�ⲿ����f2�ܵı���֧��,ͨ�����а��ȡ��ʵ·��
    class procedure GetF2GuardRealDir(const aAppName: string); static;
  end;

  // MyObjInterf��Ԫ������������
  // �ṩ��TMyObjʹ��
  TOcrStr = record
    Str: string;
    X, Y: Integer;
  end;

  // ��ѽӿ�

  IFreeObj = interface;

  // �շѽӿ�
  IChargeObj = interface;

  // ��ʹ����ӿ�
  ITsObj = interface;

  // ������չ�Ķ���
  TMyObj = class
  private
    FObj: IChargeObj;
  public

    X1, Y1, X2, Y2: Integer; // ȫ�ֵ���ͼ��Χ
  public
    constructor Create(aObj: IChargeObj);
    destructor Destroy; override;
    // ��ȡ�ַ����������� ,���ذ����ַ���������Ķ�̬����
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

  // ���󹤳�
  TObjFactory = class
  public
    class function CreateFreeObj: IFreeObj;
    class function CreateChargeObj: IChargeObj;
    class function CreateTsObj: ITsObj;
    class function CreateMyObj(aObj: IChargeObj): TMyObj;
  end;

  IFreeObj = interface(IDispatch)
    ['{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}']
    // �˴����ɸ���,��������,��ʾ�ӿڲ�֧��

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
    // �˴����ɸ���,��������,��ʾ�ӿڲ�֧��
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
  // ���ص���Ҳ���Զ��ͷ�,���ǿ�Ƶ��ÿ��ܻ����
  // FreeAllDll;
  FreeAndNil(FDllDictionary); // �ͷŶ���
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
      raise Exception.CreateFmt('%s���·��������', [aDllPath]);
  end;

var
  lDllHandle: THandle;
begin
  Result := nil;
  CheckPath;
  // �ж��Ƿ��Ѿ�����
  if not Assigned(FDllDictionary) then
  begin
    FDllDictionary := TDictionary<string, THandle>.Create();
  end;

  // δ���ؽ��м���
  if not FDllDictionary.ContainsKey(aDllPath) then

  begin
    lDllHandle := SafeLoadLibrary(aDllPath);
    if lDllHandle = 0 then
      raise Exception.CreateFmt('����%ʧ��', [aDllPath]);

  end
  else
    // �Ѿ����شӴʵ��л�ȡ���
    lDllHandle := FDllDictionary[aDllPath];
  // ��������
  Result := CreateComObjFromDll(CLASS_ID, lDllHandle);
  // ���󴴽��ɹ����뵽�ʵ�
  if Assigned(Result) then
  begin
    if not FDllDictionary.ContainsKey(aDllPath) then
      FDllDictionary.Add(aDllPath, lDllHandle);
    { ������ڸ���,����������� }
  end;
  // Assert(result<>nil,'��ע����󴴽�ʧ��');
  if Result = nil then
    raise Exception.Create('��ע����󴴽�ʧ��');

end;

class function TComService.RegCom(const aPath: string;
  const aReg: Boolean): Boolean;
type
  TOleRegisterFunction = function: HRESULT; stdcall; // ע���ж�غ���ԭ��
var
  hLibraryHandle: THandle; // ��LoadLibray���ص�DLL��OCX���
  // hFunctionAddress: TFarProc; // DLL��OCX�еĺ����������GetProAddress����
  RegFunction: TOleRegisterFunction; // ע���ж�غ���ָ��
begin
  Result := False;
  // ���ļ�������DLL��OCX���

  hLibraryHandle := SafeLoadLibrary(aPath);
  if (hLibraryHandle > HINSTANCE_ERROR) then // DLLakg OCX�����ȷ
    try
      // ����ע���ж�غ���ָ��
      if (aReg) then
        // ����ע�ắ��ָ��
        RegFunction := GetProcAddress(hLibraryHandle,
          PAnsiChar('DllRegisterServer'))
      else
        // ����ж�غ���ָ��
        RegFunction := GetProcAddress(hLibraryHandle,
          PAnsiChar('DllUnregisterServer'));
      // �ж�ע���ж�غ����Ƿ����
      if Assigned(RegFunction) then
      begin
        if (RegFunction = S_OK) then
          Result := True;
      end;
    finally
      // �ر��Ѵ򿪵��ļ�
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
// f2��֧�ֵĺ�����ʱ�ò������Ƴ�
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
    raise Exception.Create('�����շѶ���ʧ�ܣ�');
  iRet := Result.Reg(TObjConfig.RegCode, TObjConfig.RegVer);
  if iRet <> 1 then
    raise Exception.CreateFmt('����շѹ���ע��ʧ�ܣ������룺%d', [iRet]);
end;

class function TObjFactory.CreateFreeObj: IFreeObj;
begin
  Result := TComService.NoRegCreateComObj(CLASS_DMPluginInterface,
    TObjConfig.FreeFullPath) as IFreeObj;
  if not Assigned(Result) then
    raise Exception.Create('���󴴽�ʧ�ܣ�');
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
    raise Exception.Create('���󴴽�ʧ�ܣ�');
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
  Str := FObj.OcrEx(X1, Y1, X2, Y2, color_format, sim); // ʶ����
  strAndPosArr := Str.Split(['|']); // ����һ�ηָ�
  Result := [];
  for I := Low(strAndPosArr) to High(strAndPosArr) do
  begin
    arr := strAndPosArr[I].Split(['$']); // ���ж��ηָ�
    OutStr := OutStr + arr[0]; // �����ִ�
    ocrStr.Str := arr[0];
    ocrStr.X := arr[1].ToInteger();
    ocrStr.Y := arr[2].ToInteger();
    Result := Result + [ocrStr];
  end;
end;

end.
