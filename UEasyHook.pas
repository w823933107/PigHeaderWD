unit UEasyHook;

interface

{ *
  ������ c++�в���ָ�������var����ת��
  ����TRACED_HOOK_HANDLE = ^_HOOK_TRACE_INFO_;������ GetMemory(SizeOf(HOOk_TRACE_INFO))�����ڴ�
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
  EASYHOOK_INJECT_NET_DEFIBRILLATOR = $20000000; // ��������CreateAndInject()

type
  NTSTATUS = Cardinal;

  // -------_LOCAL_HOOK_INFO_------------
  // ����ָ��
  PLOCAL_HOOK_INFO = ^_LOCAL_HOOK_INFO_;

  _LOCAL_HOOK_INFO_ = record

  end;

  // �������
  LOCAL_HOOK_INFO = _LOCAL_HOOK_INFO_;

  // ------------------
  // ------_HOOK_TRACE_INFO_ ���Ӿ����Ϣ-----------
  // ����ָ����
  TRACED_HOOK_HANDLE = ^_HOOK_TRACE_INFO_;

  _HOOK_TRACE_INFO_ = record
    Link: PLOCAL_HOOK_INFO;
  end;

  // �������
  HOOk_TRACE_INFO = _HOOK_TRACE_INFO_;

  // ----------------------
  // ------_MODULE_INFORMATION_ ģ����Ϣ----------------
  // ����ָ��
  PMODULE_INFORMATION = ^MODULE_INFORMATION;

  _MODULE_INFORMATION_ = record
    Next: PMODULE_INFORMATION;
    BaseAddress: PUCHAR;
    ImageSize: ULONG;
    Path: array [0 .. 255] of Char;
    ModuleName: PAnsiChar; // ������Ҫ�Ķ�
  end;

  // �������
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
  // ��ȡ���һ�δ�����
function RtlGetLastError(): NTSTATUS; stdcall;
// ��ȡ���һ�δ�����Ϣ�ַ���
function RtlGetLastErrorString(): PWChar; stdcall;
function RtlGetLastErrorStringCopy(): PWChar; stdcall;
{ -------------------------------------------------------------------------------
  ������:    LhInstallHook
  ˵��: ��װ����
  ����:
  InEntryPoint:  �����ĵ�ַ
  InHookProc:   ��Ҫ����װ�Ĺ���,�Լ�����ĺ���
  InCallBack:    �Ժ�ص���ʹ��LhBarrierGetCallback���лص�����
  OutHandle:    ������ӵĸ��پ��,�����ȷ����ڴ�,ֻ�е���ж�ع��Ӻ�����ͷ��ڴ�
  ����ֵ:    NTSTATUS
  ����STATUS_NO_MEMORY �޷������ڴ���ڵ�
  ����STATUS_NOT_SUPPORTED Ŀ����ڵ�����˲�֧�ֵ�ָ��
  ����STATUS_INSUFFICIENT_RESOURCES ���������ҹ�����
  ------------------------------------------------------------------------------- }

function LhInstallHook(InEntryPoint, InHookProc, InCallBack: PVOID;
  OutHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhUninstallAllHooks
  ˵��: �Ƴ���ǰ�������еĹ���,�ͷ�������Դ,����Ҫ����LhWaitForPendingRemovals()���ܽ���
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhUninstallAllHooks(): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhUninstallHook
  ˵��: ж�����еĹ��� ,֮����������� LhWaitForPendingRemovals����,Ȼ����ȥ����һЩ��Դ
  ����:      InHandle ���ٹ��Ӿ������������Ѿ��Ƴ�,�÷����Խ�����STATUS_SUCCESS
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhUninstallHook(InHandle: TRACED_HOOK_HANDLE): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhWaitForPendingRemovals
  ˵��: ѭ���ȴ�ֱ������ȫ���ͷ��Ƴ�,�����Ժ����ͷ�һЩ��Դ�Ƚϰ�ȫ
  ����:
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhWaitForPendingRemovals(): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  ������:    LhSetInclusiveACL
  ˵��:      �ֲ���װ�Ĺ����а��������ų����߳������ȫ�ֵİ��������ų��γɵ��߳�����
  ���н������߲���,���õ����ӵ��߳�����
  ����:
  InThreadIdList ����
  InThreadCount �����С
  InHandle ��װ���ӵĸ��پֲ�
  ����ֵ:    NTSTATUS
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
  ������:    LhIsThreadIntercepted
  ˵��:�߳��Ƿ񱻽ٳ�
  ����:      InHook: ���Ӿ��
  InThreadId: �߳�ID
  var OutResult: �Ƿ�ע��
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }

function LhIsThreadIntercepted(InHook: TRACED_HOOK_HANDLE; InThreadId: ULONG;
  var OutResult: BOOL): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  ������:    LhBarrierGetCallback
  ˵��:  ����LhInstallHook֮ǰ����ĺ���,
  ����:      var OutValue: PVOID
  ����ֵ:    NTSTATUS    ʧ�ܷ���STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetCallback(var OutValue: PVOID): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhBarrierGetReturnAddress
  ˵��:
  ����:      OutValue  �õ�Hook�����ĵ�ַ
  ����ֵ:    NTSTATUS   ʧ�ܷ���STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetReturnAddress(var OutValue: PVOID): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  ������:    LhBarrierGetAddressOfReturnAddress
  ˵��:
  ����:      OutValue  Hook�����ĵ�ַ�ĵ�ַ
  ����ֵ:    NTSTATUS  ʧ�ܷ���STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierGetAddressOfReturnAddress(var OutValue: PPVOID)
  : NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhBarrierBeginStackTrace
  ˵��:
  ����:      OutBackup: PPVOID
  ����ֵ:    NTSTATUS    ʧ�ܷ���STATUS_NOT_SUPPORTED
  ------------------------------------------------------------------------------- }

function LhBarrierBeginStackTrace(OutBackup: PPVOID): NTSTATUS; stdcall;

function LhBarrierEndStackTrace(): NTSTATUS; stdcall;
// ����ģ����Ϣ ,�ƺ�������,��֪�����������в���
function LhUpdateModuleInformation(): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhBarrierPointerToModule
  ˵��:   ����ָ��õ�ģ������
  ����:
  InPointer: PVOID;
  var OutModule: MODULE_INFORMATION ;
  ����ֵ:    NTSTATUS     ʧ�ܷ���STATUS_NOT_FOUND
  ------------------------------------------------------------------------------- }

function LhBarrierPointerToModule(InPointer: PVOID;
  var OutModule: MODULE_INFORMATION): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhEnumModules
  ˵��:�˺���ͨ����������,��һ������OutModuleArrΪnil,InMaxModuleCountΪ0,��
  ���OutModuleCount�Ĵ�С,�ڶ�����������OutModeuleArr�Ĵ�СΪ�ղŻ�ȡ��,�����
  �������õ�̫С����ô������STATUS_BUFFER_TOO_SMALL,������������Ȼ�������оٵ�����
  ע��:���ں�ģʽ����Ҫ����,����ֻ�ܷ���ָ��,����Ҫ����LhBarrierPointerToModule
  ����ַת��Ϊģ������
  ����:
  OutModuleArr: PULONG;     ģ������
  InMaxModuleCount: ULONG;  �����С
  var OutModuleCount: ULONG ;    ����ģ������
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhEnumModules(OutModuleArr: PULONG; InMaxModuleCount: ULONG;
  var OutModuleCount: ULONG): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhBarrierGetCallingModule
  ˵��:
  ����:       OutModule: MODULE_INFORMATION ����ģ����Ϣ
  ����ֵ:    NTSTATUS   ʧ�ܷ���STATUS_NOT_FOUND
  ------------------------------------------------------------------------------- }

function LhBarrierGetCallingModule(var OutModule: MODULE_INFORMATION)
  : NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    LhBarrierCallStackTrace
  ˵��:  ����һ�����ö�ջ����,�÷���ֻ������XP��,����ֻ�ܷ���ָ��,
  ��Ϊ�ں�ģʽû���㹻�Ķ�ջ����ʹ��
  ����:
  var OutMethodArr: PVOID; �������е���ջ������ �ò�������Ϊnil
  InMaxMethodCount: ULONG; �������Ϊ64,�������û����С
  var OutMethodCount: ULONG  ���������С
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }
function LhBarrierCallStackTrace(OutMethodArr: PPVOID; InMaxMethodCount: ULONG;
  var OutMethodCount: ULONG): NTSTATUS; stdcall;
// �Ƿ���Ч
function DbgIsAvailable(): Boolean; stdcall;
// �Ƿ񼤻�
function DbgIsEnabled(): Boolean; stdcall;
{ -------------------------------------------------------------------------------
  ������:    DbgAttachDebugger
  ˵��:  ������Ҫ��easyhook�������Ѱַ�ǽ��̸��ӵ���
  ����:
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }
function DbgAttachDebugger(): NTSTATUS; stdcall;
function DbgDetachDebugger(): NTSTATUS; stdcall;

// ���߳̾��ת��Ϊ�߳�ID
function DbgGetThreadIdByHandle(InThreadHandle: PVOID; var OutThreadId: ULONG)
  : NTSTATUS; stdcall;
// ������IDת��Ϊ���̾��,�������ָ��,ID�Ǳ�־,��Ψһ��
function DbgGetProcessIdByHandle(InProcessHandle: PVOID;
  var OutProcessId: ULONG): NTSTATUS; stdcall;

{ -------------------------------------------------------------------------------
  ������:    DbgHandleToObjectName
  ˵��: ��ȡ����Ķ�������,��Ҫ���ε��ø÷���,��һ�εõ�����,OutNameBuffer
  ����Ϊnil�ڶ���������ȡ
  ����:
  InNameHandle: PVOID;      ���
  var OutNameBuffer: PUNICODE_STRING;  ��ȡ���������
  InBufferSize: ULONG;         //����Ļ����С
  var OutRequiredSize: ULONG    //���ն���Ļ����С,��һ��ʱ��ȡ
  ����ֵ:    NTSTATUS
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
  ������:    RhCreateStealthRemoteThread
  ˵��:      ����Զ�������߳�,������ԭ�����̼߳���ִ��,���Ǳ�ע����һЩ����
  ����:
  InTargetPID: ULONG;  Ŀ�����ID
  InRemoteRoutine: TFNThreadStartRoutine;  Ҫע��ĺ���
  InRemoteParam: PVOID;              Ҫע��ĺ����Ĳ���
  var OutRemoteThread: THandle      ����Զ�̴������߳̾��
  ����ֵ:    NTSTATUS
  STATUS_WOW_ASSERTION
  ͨ��64λϵͳ,���ǲ�֧��
  STATUS_NOT_FOUND
  û�з���Ŀ�����
  STATUS_ACCESS_DENIED
  Ŀ������޷�����
  STATUS_NOT_SUPPORTED
  û�����е��߳�Ŀ��
  ------------------------------------------------------------------------------- }

function RhCreateStealthRemoteThread(InTargetPID: ULONG;
  InRemoteRoutine: TFNThreadStartRoutine; InRemoteParam: PVOID;
  var OutRemoteThread: THandle): NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  ������:    RhInjectLibrary
  ˵��:
  ����:
  InTargetPID: ULONG;  Ŀ�����
  InWakeUpTID: ULONG;   �������ڲ�ʹ��,����Ϊ0
  InInjectionOptions: ULONG;   ע������
  EASYHOOK_INJECT_DEFAULT = $00000000; ���йܵ�dll
  EASYHOOK_INJECT_STEALTH = $10000000;ʹ�õ���.NET��dll
  EASYHOOK_INJECT_NET_DEFIBRILLATOR = $20000000;  ��������CreateAndInject(),���������߳�,ʧ������ʹ��Ĭ������
  InLibraryPath_x86: PWChar; 32λϵͳdll·��,��ʹ��������Ϊnil
  InLibraryPath_x64: PWChar;  64λϵͳdll·��,��ʹ��������Ϊnil
  InPassThruBuffer: PVOID; ��ڴ����ݵĵĲ���ָ��,��ʹ������Ϊnil
  InPassThruSize: ULONG    ��ڴ����ݵĲ�����С ,��ʹ������Ϊnil
  ����ֵ:    NTSTATUS
  STATUS_INVALID_PARAMETER_5
  64λdll����޷���ȡ,dll�޷����ػ�ȱʧ
  STATUS_INVALID_PARAMETER_4
  64λdll����޷���ȡ,dll�޷����ػ�ȱʧ
  STATUS_WOW_ASSERTION
  64λͨ������֧��
  STATUS_NOT_FOUND
  û�з���Ŀ�����
  STATUS_ACCESS_DENIED
  Ŀ������޷��������ʻ�Զ���̴߳���ʧ����
  ------------------------------------------------------------------------------- }

function RhInjectLibrary(InTargetPID: ULONG; InWakeUpTID: ULONG;
  InInjectionOptions: ULONG; InLibraryPath_x86: PWChar;
  InLibraryPath_x64: PWChar; InPassThruBuffer: PVOID; InPassThruSize: ULONG)
  : NTSTATUS; stdcall;
{ -------------------------------------------------------------------------------
  ������:    RhCreateAndInject
  ˵��:  ����һ����ͣ��ע��,�ɽ���һЩ��ʼ������, RhWakeUpProcessin ���л��Ѳ���
  Ŀ����̴�ʱ��δ��,�ɶ�������һЩ�����в������̲���
  ����:
  InEXEPath: PWChar;  һ����Ի����·��EXE�ļ��Ĵ�������
  InCommandLine: PWChar;   ��ѡ�������в������ڴ�������
  InProcessCreationFlags: ULONG;
  InInjectionOptions: ULONG; InLibraryPath_x86:
  PWChar; InLibraryPath_x64: PWChar;
  InPassThruBuffer: PVOID;
  InPassThruSize: ULONG;
  var OutProcessId: ULONG
  ����ֵ:    NTSTATUS
  ------------------------------------------------------------------------------- }
function RhCreateAndInject(InEXEPath: PWChar; InCommandLine: PWChar;
  InProcessCreationFlags: ULONG; InInjectionOptions: ULONG;
  InLibraryPath_x86: PWChar; InLibraryPath_x64: PWChar; InPassThruBuffer: PVOID;
  InPassThruSize: ULONG; var OutProcessId: ULONG): NTSTATUS; stdcall;
// �ж��Ƿ���64λϵͳ
function RhIsX64System(): Boolean; stdcall;
// �������Ƿ�Ϊ64λ����
function RhIsX64Process(InProcessId: ULONG; var OutResult: Boolean)
  : NTSTATUS; stdcall;
// ���ʹ���й���ԱȨ��
function RhIsAdministrator(): Boolean; stdcall;
// ���Ѳ���
function RhWakeUpProcess(): NTSTATUS; stdcall;
// ��װ����֧��,��������������ʱ����easyhook����غ���
function RhInstallSupportDriver(): NTSTATUS; stdcall;
// ��װ����,������������Ϊɾ��
function RhInstallDriver(InDriverPath: PWChar; InDriverName: PWChar)
  : NTSTATUS; stdcall;
// �Զ���ĺ���
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
