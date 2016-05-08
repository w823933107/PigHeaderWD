unit UEasyHook;

interface

{ *
  经测试 c++中参数指针可以用var进行转换
  其中TRACED_HOOK_HANDLE = ^_HOOK_TRACE_INFO_;可以用 GetMemory(SizeOf(HOOk_TRACE_INFO))分配内存
  * }
uses
  Winapi.Windows;

const
  // MAX_HOOK_COUNT = 128;
  MAX_ACE_COUNT = 128;

  // MAX_THREAD_COUNT = 128;
  // MAX_PASSTHRU_SIZE = 1024 * 64;

  STATUS_SUCCESS = $0;
  STATUS_NOT_SUPPORTED = $C00000BB;
  STATUS_INTERNAL_ERROR = $C00000E5;
  STATUS_PROCEDURE_NOT_FOUND = $C000007A;
  STATUS_NOINTERFACE = $C00002B9;
  STATUS_INFO_LENGTH_MISMATCH = $C0000004;
  STATUS_BUFFER_TOO_SMALL = $C0000023;
  STATUS_INVALID_PARAMETER = $C000000D;
  STATUS_INSUFFICIENT_RESOURCES = $C000009A;
  STATUS_UNHANDLED_EXCEPTION = $C0000144;
  STATUS_NOT_FOUND = $C0000225;
  STATUS_NOT_IMPLEMENTED = $C0000002;
  STATUS_ACCESS_DENIED = $C0000022;
  STATUS_ALREADY_REGISTERED = $C0000718;
  STATUS_WOW_ASSERTION = $C0009898;
  STATUS_BUFFER_OVERFLOW = $80000005;
  STATUS_DLL_INIT_FAILED = $C0000142;

  STATUS_INVALID_PARAMETER_1 = $C00000EF;
  STATUS_INVALID_PARAMETER_2 = $C00000F0;
  STATUS_INVALID_PARAMETER_3 = $C00000F1;
  STATUS_INVALID_PARAMETER_4 = $C00000F2;
  STATUS_INVALID_PARAMETER_5 = $C00000F3;
  STATUS_INVALID_PARAMETER_6 = $C00000F4;
  STATUS_INVALID_PARAMETER_7 = $C00000F5;
  STATUS_INVALID_PARAMETER_8 = $C00000F6;

  EASYHOOK_INJECT_DEFAULT = $00000000;
  EASYHOOK_INJECT_STEALTH = $10000000;
  EASYHOOK_INJECT_NET_DEFIBRILLATOR = $20000000; // 仅能用在CreateAndInject()

type
  NTSTATUS = Cardinal;

  // -------_LOCAL_HOOK_INFO_------------
  // 定义指针
  PLOCAL_HOOK_INFO = ^_LOCAL_HOOK_INFO_;

  _LOCAL_HOOK_INFO_ = record

  end;

  // 定义别名
  LOCAL_HOOK_INFO = _LOCAL_HOOK_INFO_;

  // ------------------
  // ------_HOOK_TRACE_INFO_ 钩子句柄信息-----------
  // 定义指针句柄
  TRACED_HOOK_HANDLE = ^_HOOK_TRACE_INFO_;

  _HOOK_TRACE_INFO_ = record
    Link: PLOCAL_HOOK_INFO;
  end;

  // 定义别名
  HOOk_TRACE_INFO = _HOOK_TRACE_INFO_;

  // ----------------------
  // ------_MODULE_INFORMATION_ 模块信息----------------
  // 定义指针
  PMODULE_INFORMATION = ^MODULE_INFORMATION;

  _MODULE_INFORMATION_ = record
    Next: PMODULE_INFORMATION;
    BaseAddress: PUCHAR;
    ImageSize: ULONG;
    Path: array [0 .. 255] of Char;
    ModuleName: PAnsiChar; // 可能需要改动
  end;

  // 定义别名
  MODULE_INFORMATION = _MODULE_INFORMATION_;

  PTHREAD_START_ROUNTINE = function(lpThreadParameter: PVOID): DWORD; stdcall;
  LPTHREAD_START_ROUTINE = ^PTHREAD_START_ROUNTINE;
  // LPTHREAD_START_ROUTINE = PVOID;

  _TEST_FUNC_HOOKS_OPTIONS = record
    Filename: LPSTR;
    FilterByName: LPSTR;
  end;

  TEST_FUNC_HOOKS_OPTIONS = _TEST_FUNC_HOOKS_OPTIONS;
  PTEST_FUNC_HOOKS_RESULT = ^TEST_FUNC_HOOKS_RESULT;

  _TEST_FUNC_HOOKS_RESULT = record
    FnName: LPSTR;
    ModuleRedirect: LPSTR;
    FnAddress: PVOID;
    RelocAddress: PVOID;
    EntryDisasm: LPSTR;
    RelocDisasm: LPSTR;
    Error: LPSTR;
  end;

  TEST_FUNC_HOOKS_RESULT = _TEST_FUNC_HOOKS_RESULT;

  _REMOTE_ENTRY_INFO_ = record
    HostPid: ULONG;
    UserData: PUCHAR;
    UserDataSize: ULONG;
  end;

  REMOTE_ENTRY_INFO = _REMOTE_ENTRY_INFO_;

  _UNICODE_STRING = record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: LPWSTR;
  end;

  UNICODE_STRING = _UNICODE_STRING;
  PUNICODE_STRING = UNICODE_STRING;
  // 获取最后一次错误码
function RtlGetLastError(): NTSTATUS; stdcall;
// 获取最后一次错误信息字符串
function RtlGetLastErrorString(): PWChar; stdcall;
function RtlGetLastErrorStringCopy(): PWChar; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    LhInstallHook
  说明: 安装钩子
  参数:
  InEntryPoint:  函数的地址
  InHookProc:   需要被安装的钩子,自己定义的函数
  InCallBack:    以后回调可使用LhBarrierGetCallback进行回调操作
  OutHandle:    输出钩子的跟踪句柄,必须先分配内存,只有调用卸载钩子后才能释放内存
  返回值:    NTSTATUS
  返回STATUS_NO_MEMORY 无法分配内存入口点
  返回STATUS_NOT_SUPPORTED 目标入口点包含了不支持的指令
  返回STATUS_INSUFFICIENT_RESOURCES 超出了最大挂钩数量
  ------------------------------------------------------------------------------- }

function LhInstallHook(InEntryPoint, InHookProc, InCallBack: PVOID;
  OutHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhUninstallAllHooks
  说明: 移除当前进程所有的钩子,释放所有资源,你需要调用LhWaitForPendingRemovals()才能进行
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhUninstallAllHooks(): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhUninstallHook
  说明: 卸载所有的钩子 ,之后您必须调用 LhWaitForPendingRemovals方法,然后再去清理一些资源
  参数:      InHandle 跟踪钩子句柄。如果钩子已经移除,该方法仍将返回STATUS_SUCCESS
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhUninstallHook(InHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhWaitForPendingRemovals
  说明: 循环等待直到钩子全部释放移除,这样以后再释放一些资源比较安全
  参数:
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhWaitForPendingRemovals(): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    LhSetInclusiveACL
  说明:      局部安装的钩子中包含或者排除的线程数组和全局的包含或者排除形成的线程数组
  进行交集或者并集,最后得到钩子的线程数组
  参数:
  InThreadIdList 数组
  InThreadCount 数组大小
  InHandle 安装钩子的跟踪局部
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhSetInclusiveACL(InThreadIdList: PULONG; InThreadCount: ULONG;
  InHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;
function LhSetExclusiveACL(InThreadIdList: PULONG; InThreadCount: ULONG;
  InHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;
function LhSetGlobalInclusiveACL(InThreadIdList: PULONG; InThreadCount: ULONG)
  : NTSTATUS; stdcall;
function LhSetGlobalExclusiveACL(InThreadIdList: PULONG; InThreadCount: ULONG)
  : NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhIsThreadIntercepted
  说明:线程是否被劫持
  参数:      InHook: 钩子句柄
  InThreadId: 线程ID
  var OutResult: 是否被注入
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhIsThreadIntercepted(InHook: TRACED_HOOK_HANDLE; InThreadId: ULONG;
  var OutResult: BOOL): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    LhBarrierGetCallback
  说明:  返回LhInstallHook之前传入的函数,
  参数:      var OutValue: PVOID
  返回值:    NTSTATUS    失败返回STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetCallback(var OutValue: PVOID): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhBarrierGetReturnAddress
  说明:
  参数:      OutValue  得到Hook操作的地址
  返回值:    NTSTATUS   失败返回STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetReturnAddress(var OutValue: PVOID): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    LhBarrierGetAddressOfReturnAddress
  说明:
  参数:      OutValue  Hook操作的地址的地址
  返回值:    NTSTATUS  失败返回STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetAddressOfReturnAddress(var OutValue: PPVOID)
  : NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhBarrierBeginStackTrace
  说明:
  参数:      OutBackup: PPVOID
  返回值:    NTSTATUS    失败返回STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierBeginStackTrace(OutBackup: PPVOID): NTSTATUS; stdcall;

function LhBarrierEndStackTrace(): NTSTATUS; stdcall;
// 更新模块信息 ,似乎不可用,不知道在驱动中行不行
function LhUpdateModuleInformation(): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhBarrierPointerToModule
  说明:   根据指针得到模块链表
  参数:
  InPointer: PVOID;
  var OutModule: MODULE_INFORMATION ;
  返回值:    NTSTATUS     失败返回STATUS_NOT_FOUND
  ------------------------------------------------------------------------------- }

function LhBarrierPointerToModule(InPointer: PVOID;
  var OutModule: MODULE_INFORMATION): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhEnumModules
  说明:此函数通常调用两次,第一次设置OutModuleArr为nil,InMaxModuleCount为0,将
  获得OutModuleCount的大小,第二次再设置下OutModeuleArr的大小为刚才获取的,如果你
  缓冲设置的太小了那么将返回STATUS_BUFFER_TOO_SMALL,但是数组内仍然会填满列举的内容
  注意:在内核模式下需要性能,所以只能返回指针,你需要调用LhBarrierPointerToModule
  将地址转换为模块链表
  参数:
  OutModuleArr: PULONG;     模块数组
  InMaxModuleCount: ULONG;  数组大小
  var OutModuleCount: ULONG ;    返回模块数量
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhEnumModules(OutModuleArr: PULONG; InMaxModuleCount: ULONG;
  var OutModuleCount: ULONG): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhBarrierGetCallingModule
  说明:
  参数:       OutModule: MODULE_INFORMATION 保存模块信息
  返回值:    NTSTATUS   失败返回STATUS_NOT_FOUND
  ------------------------------------------------------------------------------- }

function LhBarrierGetCallingModule(var OutModule: MODULE_INFORMATION)
  : NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    LhBarrierCallStackTrace
  说明:  创建一个调用堆栈跟踪,该方法只能用在XP上,而且只能返回指针,
  因为内核模式没有足够的堆栈可以使用
  参数:
  var OutMethodArr: PVOID; 返回所有调用栈的数组 该参数不能为nil
  InMaxMethodCount: ULONG; 最大设置为64,用来设置缓冲大小
  var OutMethodCount: ULONG  返回数组大小
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhBarrierCallStackTrace(OutMethodArr: PPVOID; InMaxMethodCount: ULONG;
  var OutMethodCount: ULONG): NTSTATUS; stdcall;
// 是否有效
function DbgIsAvailable(): Boolean; stdcall;
// 是否激活
function DbgIsEnabled(): Boolean; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    DbgAttachDebugger
  说明:  当你需要用easyhook进行相对寻址是进程附加调试
  参数:
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function DbgAttachDebugger(): NTSTATUS; stdcall;
function DbgDetachDebugger(): NTSTATUS; stdcall;

// 将线程句柄转换为线程ID
function DbgGetThreadIdByHandle(InThreadHandle: PVOID; var OutThreadId: ULONG)
  : NTSTATUS; stdcall;
// 将进程ID转换为进程句柄,句柄就是指针,ID是标志,是唯一的
function DbgGetProcessIdByHandle(InProcessHandle: PVOID;
  var OutProcessId: ULONG): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  过程名:    DbgHandleToObjectName
  说明: 获取句柄的对象名词,需要两次调用该方法,第一次得到缓冲,OutNameBuffer
  设置为nil第二次真正获取
  参数:
  InNameHandle: PVOID;      句柄
  var OutNameBuffer: PUNICODE_STRING;  获取对象的名称
  InBufferSize: ULONG;         //对象的缓冲大小
  var OutRequiredSize: ULONG    //接收对象的缓冲大小,第一次时获取
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }

function DbgHandleToObjectName(InNameHandle: PVOID;
  var OutNameBuffer: PUNICODE_STRING; InBufferSize: ULONG;
  var OutRequiredSize: ULONG): NTSTATUS; stdcall;

function TestFuncHooks(pId: ULONG; module: PChar;
  options: TEST_FUNC_HOOKS_OPTIONS; var OutResults: PTEST_FUNC_HOOKS_RESULT;
  var ResultCount: Integer): NTSTATUS; stdcall;
function ReleaseTestFuncHookResults(var results: TEST_FUNC_HOOKS_OPTIONS;
  Count: Integer): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    RhCreateStealthRemoteThread
  说明:      创建远程隐形线程,创建后原来的线程继续执行,但是被注入了一些东西
  参数:
  InTargetPID: ULONG;  目标进程ID
  InRemoteRoutine: TFNThreadStartRoutine;  要注入的函数
  InRemoteParam: PVOID;              要注入的函数的参数
  var OutRemoteThread: THandle      返回远程创建的线程句柄
  返回值:    NTSTATUS
  STATUS_WOW_ASSERTION
  通过64位系统,但是不支持
  STATUS_NOT_FOUND
  没有发现目标进程
  STATUS_ACCESS_DENIED
  目标进程无法访问
  STATUS_NOT_SUPPORTED
  没有运行的线程目标
  ------------------------------------------------------------------------------- }

function RhCreateStealthRemoteThread(InTargetPID: ULONG;
  InRemoteRoutine: TFNThreadStartRoutine; InRemoteParam: PVOID;
  var OutRemoteThread: THandle): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    RhInjectLibrary
  说明:
  参数:
  InTargetPID: ULONG;  目标进程
  InWakeUpTID: ULONG;   仅用于内部使用,设置为0
  InInjectionOptions: ULONG;   注入设置
  EASYHOOK_INJECT_DEFAULT = $00000000; 非托管的dll
  EASYHOOK_INJECT_STEALTH = $10000000;使用的是.NET的dll
  EASYHOOK_INJECT_NET_DEFIBRILLATOR = $20000000;  仅能用在CreateAndInject(),创建隐藏线程,失败了请使用默认设置
  InLibraryPath_x86: PWChar; 32位系统dll路径,不使用则设置为nil
  InLibraryPath_x64: PWChar;  64位系统dll路径,不使用则设置为nil
  InPassThruBuffer: PVOID; 入口处传递的的参数指针,不使用设置为nil
  InPassThruSize: ULONG    入口处传递的参数大小 ,不使用设置为nil
  返回值:    NTSTATUS
  STATUS_INVALID_PARAMETER_5
  64位dll入口无法获取,dll无法加载或缺失
  STATUS_INVALID_PARAMETER_4
  64位dll入口无法获取,dll无法加载或缺失
  STATUS_WOW_ASSERTION
  64位通过但不支持
  STATUS_NOT_FOUND
  没有发现目标进程
  STATUS_ACCESS_DENIED
  目标进程无法正常访问或远程线程创建失败了
  ------------------------------------------------------------------------------- }

function RhInjectLibrary(InTargetPID: ULONG; InWakeUpTID: ULONG;
  InInjectionOptions: ULONG; InLibraryPath_x86: PWChar;
  InLibraryPath_x64: PWChar; InPassThruBuffer: PVOID; InPassThruSize: ULONG)
  : NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  过程名:    RhCreateAndInject
  说明:  创建一个暂停的注入,可进行一些初始化设置, RhWakeUpProcessin 进行唤醒操作
  目标进程此时并未打开,可对其设置一些命令行参数进程操作
  参数:
  InEXEPath: PWChar;  一个相对或绝对路径EXE文件的创建过程
  InCommandLine: PWChar;   可选的命令行参数用于创建过程
  InProcessCreationFlags: ULONG;
  InInjectionOptions: ULONG; InLibraryPath_x86:
  PWChar; InLibraryPath_x64: PWChar;
  InPassThruBuffer: PVOID;
  InPassThruSize: ULONG;
  var OutProcessId: ULONG
  返回值:    NTSTATUS
  ------------------------------------------------------------------------------- }
function RhCreateAndInject(InEXEPath: PWChar; InCommandLine: PWChar;
  InProcessCreationFlags: ULONG; InInjectionOptions: ULONG;
  InLibraryPath_x86: PWChar; InLibraryPath_x64: PWChar; InPassThruBuffer: PVOID;
  InPassThruSize: ULONG; var OutProcessId: ULONG): NTSTATUS; stdcall;
// 判断是否是64位系统
function RhIsX64System(): Boolean; stdcall;
// 检测进程是否为64位程序
function RhIsX64Process(InProcessId: ULONG; var OutResult: Boolean)
  : NTSTATUS; stdcall;
// 检测使用有管理员权限
function RhIsAdministrator(): Boolean; stdcall;
// 唤醒操作
function RhWakeUpProcess(): NTSTATUS; stdcall;
// 安装驱动支持,允许在驱动开发时调用easyhook的相关函数
function RhInstallSupportDriver(): NTSTATUS; stdcall;
// 安装驱动,并立即将其标记为删除
function RhInstallDriver(InDriverPath: PWChar; InDriverName: PWChar)
  : NTSTATUS; stdcall;
// 自定义的函数
function CreateTRACED_HOOK_HANDLE: TRACED_HOOK_HANDLE; overload;
procedure CreateTRACED_HOOK_HANDLE(var p: TRACED_HOOK_HANDLE); overload;
procedure FreeTRACED_HOOK_HANDLE(p: TRACED_HOOK_HANDLE);

implementation

function CreateTRACED_HOOK_HANDLE: TRACED_HOOK_HANDLE;
begin
  Result := AllocMem(SizeOf(HOOk_TRACE_INFO));
end;

procedure FreeTRACED_HOOK_HANDLE(p: TRACED_HOOK_HANDLE);
begin
  FreeMemory(p);
end;

procedure CreateTRACED_HOOK_HANDLE(var p: TRACED_HOOK_HANDLE); overload;
begin
  p := AllocMem(SizeOf(HOOk_TRACE_INFO));;
end;

{$IFDEF WIN32}
function RtlGetLastError; external 'EasyHook32.dll' name '_RtlGetLastError@0';
function RtlGetLastErrorString;
  external 'EasyHook32.dll' name '_RtlGetLastErrorString@0';
function RtlGetLastErrorStringCopy;
  external 'EasyHook32.dll' name '_RtlGetLastErrorStringCopy@0';
function LhInstallHook; external 'EasyHook32.dll' name '_LhInstallHook@16';
function LhUninstallAllHooks;
  external 'EasyHook32.dll' name '_LhUninstallAllHooks@0';
function LhUninstallHook; external 'EasyHook32.dll' name '_LhUninstallHook@4';
function LhWaitForPendingRemovals;
  external 'EasyHook32.dll' name '_LhWaitForPendingRemovals@0';
function LhSetInclusiveACL;
  external 'EasyHook32.dll' name '_LhSetInclusiveACL@12';
function LhSetExclusiveACL;
  external 'EasyHook32.dll' name '_LhSetExclusiveACL@12';
function LhSetGlobalInclusiveACL;
  external 'EasyHook32.dll' name '_LhSetGlobalInclusiveACL@8';
function LhSetGlobalExclusiveACL;
  external 'EasyHook32.dll' name '_LhSetGlobalExclusiveACL@8';
function LhIsThreadIntercepted;
  external 'EasyHook32.dll' name '_LhIsThreadIntercepted@12';
function LhBarrierGetCallback;
  external 'EasyHook32.dll' name '_LhBarrierGetCallback@4';
function LhBarrierGetReturnAddress;
  external 'EasyHook32.dll' name '_LhBarrierGetReturnAddress@4';
function LhBarrierGetAddressOfReturnAddress;
  external 'EasyHook32.dll' name '_LhBarrierGetAddressOfReturnAddress@4';
function LhBarrierBeginStackTrace;
  external 'EasyHook32.dll' name '_LhBarrierBeginStackTrace@4';
function LhBarrierEndStackTrace;
  external 'EasyHook32.dll' name '_LhBarrierEndStackTrace@4';
function LhUpdateModuleInformation;
  external 'EasyHook32.dll' name '_LhUpdateModuleInformation@0';
function LhBarrierPointerToModule;
  external 'EasyHook32.dll' name '_LhBarrierPointerToModule@8';
function LhEnumModules; external 'EasyHook32.dll' name '_LhEnumModules@12';
function LhBarrierGetCallingModule;
  external 'EasyHook32.dll' name '_LhBarrierGetCallingModule@4';
function LhBarrierCallStackTrace;
  external 'EasyHook32.dll' name '_LhBarrierCallStackTrace@12';
function DbgIsAvailable; external 'EasyHook32.dll' name '_DbgIsAvailable@0';
function DbgIsEnabled; external 'EasyHook32.dll' name '_DbgIsEnabled@0';
function DbgAttachDebugger;
  external 'EasyHook32.dll' name '_DbgAttachDebugger@0';
function DbgDetachDebugger;
  external 'EasyHook32.dll' name '_DbgDetachDebugger@0';
function DbgGetThreadIdByHandle;
  external 'EasyHook32.dll' name '_DbgGetThreadIdByHandle@8';
function DbgGetProcessIdByHandle;
  external 'EasyHook32.dll' name '_DbgGetProcessIdByHandle@8';
function DbgHandleToObjectName;
  external 'EasyHook32.dll' name '_DbgHandleToObjectName@16';
function TestFuncHooks; external 'EasyHook32.dll' name '_TestFuncHooks@24';
function ReleaseTestFuncHookResults;
  external 'EasyHook32.dll' name '_ReleaseTestFuncHookResults@8';
function RhCreateStealthRemoteThread;
  external 'EasyHook32.dll' name '_RhCreateStealthRemoteThread@16';
function RhInjectLibrary; external 'EasyHook32.dll' name '_RhInjectLibrary@28';
function RhCreateAndInject;
  external 'EasyHook32.dll' name '_RhCreateAndInject@36';
function RhIsX64System; external 'EasyHook32.dll' name '_RhIsX64System@0';
function RhIsX64Process; external 'EasyHook32.dll' name '_RhIsX64Process@8';
function RhIsAdministrator;
  external 'EasyHook32.dll' name '_RhIsAdministrator@0';
function RhWakeUpProcess; external 'EasyHook32.dll' name '_RhWakeUpProcess@0';
function RhInstallSupportDriver;
  external 'EasyHook32.dll' name '_RhInstallSupportDriver@0';
function RhInstallDriver; external 'EasyHook32.dll' name '_RhInstallDriver@8';
{$ENDIF}
{$IFDEF WIN64}
function RtlGetLastError; external 'EasyHook64.dll' name 'RtlGetLastError';
function RtlGetLastErrorString;
  external 'EasyHook64.dll' name 'RtlGetLastErrorString';
function RtlGetLastErrorStringCopy;
  external 'EasyHook64.dll' name 'RtlGetLastErrorStringCopy';
function LhInstallHook; external 'EasyHook64.dll' name 'LhInstallHook';
function LhUninstallAllHooks;
  external 'EasyHook64.dll' name 'LhUninstallAllHooks';
function LhUninstallHook; external 'EasyHook64.dll' name 'LhUninstallHook';
function LhWaitForPendingRemovals;
  external 'EasyHook64.dll' name 'LhWaitForPendingRemovals';
function LhSetInclusiveACL; external 'EasyHook64.dll' name 'LhSetInclusiveACL';
function LhSetExclusiveACL; external 'EasyHook64.dll' name 'LhSetExclusiveACL';
function LhSetGlobalInclusiveACL;
  external 'EasyHook64.dll' name 'LhSetGlobalInclusiveACL';
function LhSetGlobalExclusiveACL;
  external 'EasyHook64.dll' name 'LhSetGlobalExclusiveACL';
function LhIsThreadIntercepted;
  external 'EasyHook64.dll' name 'LhIsThreadIntercepted';
function LhBarrierGetCallback;
  external 'EasyHook64.dll' name 'LhBarrierGetCallback';
function LhBarrierGetReturnAddress;
  external 'EasyHook64.dll' name 'LhBarrierGetReturnAddress';
function LhBarrierGetAddressOfReturnAddress;
  external 'EasyHook64.dll' name 'LhBarrierGetAddressOfReturnAddress';
function LhBarrierBeginStackTrace;
  external 'EasyHook64.dll' name 'LhBarrierBeginStackTrace';
function LhBarrierEndStackTrace;
  external 'EasyHook64.dll' name 'LhBarrierEndStackTrace';
function LhUpdateModuleInformation;
  external 'EasyHook64.dll' name 'LhUpdateModuleInformation';
function LhBarrierPointerToModule;
  external 'EasyHook64.dll' name 'LhBarrierPointerToModule';
function LhEnumModules; external 'EasyHook64.dll' name 'LhEnumModules';
function LhBarrierGetCallingModule;
  external 'EasyHook64.dll' name 'LhBarrierGetCallingModule';
function LhBarrierCallStackTrace;
  external 'EasyHook64.dll' name 'LhBarrierCallStackTrace';
function DbgIsAvailable; external 'EasyHook64.dll' name 'DbgIsAvailable';
function DbgIsEnabled; external 'EasyHook64.dll' name 'DbgIsEnabled';
function DbgAttachDebugger; external 'EasyHook64.dll' name 'DbgAttachDebugger';
function DbgDetachDebugger; external 'EasyHook64.dll' name 'DbgDetachDebugger';
function DbgGetThreadIdByHandle;
  external 'EasyHook64.dll' name 'DbgGetThreadIdByHandle';
function DbgGetProcessIdByHandle;
  external 'EasyHook64.dll' name 'DbgGetProcessIdByHandle';
function DbgHandleToObjectName;
  external 'EasyHook64.dll' name 'DbgHandleToObjectName';
function TestFuncHooks; external 'EasyHook64.dll' name 'TestFuncHooks';
function ReleaseTestFuncHookResults;
  external 'EasyHook64.dll' name 'ReleaseTestFuncHookResults';
function RhCreateStealthRemoteThread;
  external 'EasyHook64.dll' name 'RhCreateStealthRemoteThread';
function RhInjectLibrary; external 'EasyHook64.dll' name 'RhInjectLibrary';
function RhCreateAndInject; external 'EasyHook64.dll' name 'RhCreateAndInject';
function RhIsX64System; external 'EasyHook64.dll' name 'RhIsX64System';
function RhIsX64Process; external 'EasyHook64.dll' name 'RhIsX64Process';
function RhIsAdministrator; external 'EasyHook64.dll' name 'RhIsAdministrator';
function RhWakeUpProcess; external 'EasyHook64.dll' name 'RhWakeUpProcess';
function RhInstallSupportDriver;
  external 'EasyHook64.dll' name 'RhInstallSupportDriver';
function RhInstallDriver; external 'EasyHook64.dll' name 'RhInstallDriver';
{$ENDIF}

end.
