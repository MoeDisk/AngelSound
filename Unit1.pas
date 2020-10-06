unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, sStatusBar, acPNG, ExtCtrls, sSkinManager, sTabControl,
  sPageControl, StdCtrls, sGroupBox, sListBox, MPlayer, ShellAPI;

type
  TWavHeader = record
    rId : longint;
    rLen : longint;
    wId : longint;
    fId : longint;
    fLen : longint;
    wFormatTag : word;
    nChannels : word;
    nSamplesPerSec : longint;
    nAvgBytesPerSec : longint;
    nBlockAlign : word;
    wBitsPerSample : word;
    dId : longint;
    wSampleLength : longint;
  end;

  TForm1 = class(TForm)
    Image1: TImage;
    sStatusBar1: TsStatusBar;
    sSkinManager1: TsSkinManager;
    sPageControl1: TsPageControl;
    sTabSheet1: TsTabSheet;
    sListBox1: TsListBox;
    sGroupBox1: TsGroupBox;
    MediaPlayer1: TMediaPlayer;
    WavPlay: TButton;
    WavPause: TButton;
    WavRe: TButton;
    WavBro: TButton;
    WavDel: TButton;
    RecStart: TButton;
    RecStop: TButton;
    SR: TButton;
    RecSet: TButton;
    CMD: TButton;
    Timer1: TTimer;
    about: TButton;
    Label1: TLabel;
    procedure CreateWav(channels : word; resolution : word; rate : longint; fn : string);
    procedure WavDelClick(Sender: TObject);
    procedure WavReClick(Sender: TObject);
    procedure WavBroClick(Sender: TObject);
    procedure WavPauseClick(Sender: TObject);
    procedure WavPlayClick(Sender: TObject);
    procedure RecStartClick(Sender: TObject);
    procedure RecStopClick(Sender: TObject);
    procedure RecSetClick(Sender: TObject);
    procedure CMDClick(Sender: TObject);
    procedure SRClick(Sender: TObject);
    procedure aboutClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  wavid:String;

implementation

{$R *.dfm}

procedure TForm1.aboutClick(Sender: TObject);
begin
  Application.MessageBox
  ('ohayou.aimo.moe'+chr(13)+chr(10)+'moedisk@outlook.com',
  'Copyleft (/≧▽≦)/Aimo NPO.',MB_ICONINFORMATION+MB_OK);
end;

procedure TForm1.CMDClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'cmd.exe', ' ', nil, SW_SHOWNORMAL);
end;

procedure TForm1.CreateWav( channels : word;
resolution : word;
rate : longint;
fn : string);
var
wf : file of TWavHeader;
wh : TWavHeader;
begin
wh.rId := $46464952;
wh.rLen := 36;
wh.wId := $45564157;
wh.fId := $20746d66;
wh.fLen := 16;
wh.wFormatTag := 1;
wh.nChannels := channels;
wh.nSamplesPerSec := rate;
wh.nAvgBytesPerSec := channels*rate*(resolution div 8);
wh.nBlockAlign := channels*(resolution div 8);
wh.wBitsPerSample := resolution;
wh.dId := $61746164;
wh.wSampleLength := 0;

assignfile(wf,fn);
rewrite(wf);
write(wf,wh);
closefile(wf);
end;

procedure TForm1.RecSetClick(Sender: TObject);
begin
  WinExec('RunDLL32.exe Shell32.dll,Control_RunDLL Mmsys.cpl,,1', SW_SHOWNORMAL);
end;

procedure TForm1.RecStartClick(Sender: TObject);
begin
try
  label1.Caption:='录制中..';
  wavid:=FormatDateTime('mm-dd-hh-nn-ss', Now());
  CreateWav(1, 8, 11025, ('ASREC_'+wavid+'.wav'));
  MediaPlayer1.DeviceType := dtAutoSelect;
  MediaPlayer1.FileName := ('ASREC_'+wavid+'.wav');
  MediaPlayer1.Open;
  MediaPlayer1.StartRecording;
  RecStart.Enabled:=false;
  RecStop.Enabled:=true;
  except
  RecStart.Enabled:=True;
  RecStop.Enabled:=false;
  Application.MessageBox('初始化失败','メッセージ',MB_IConERROR+MB_OK);
end;
end;

procedure TForm1.RecStopClick(Sender: TObject);
begin
try
  label1.Caption:='待命中..';
  MediaPlayer1.Stop;
  MediaPlayer1.Save;
  MediaPlayer1.Close;
  Application.MessageBox('录好辣','メッセージ',MB_ICONINFORMATION+MB_OK);
  RecStart.Enabled:=True;
  RecStop.Enabled:=false;
  slistbox1.Items.Add('ASREC_'+wavid+'.wav');
  except
  Application.MessageBox('保存出错','メッセージ',MB_IConERROR+MB_OK);
  RecStart.Enabled:=True;
  RecStop.Enabled:=false;
end;
end;

procedure TForm1.SRClick(Sender: TObject);
var
s:string;
begin
  s := GetEnvironmentVariable('SYSTEMDRIVE');
  ShellExecute(Handle, 'explore', PChar(s+'\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories'), nil, nil, SW_SHOW);
end;

procedure TForm1.WavBroClick(Sender: TObject);
begin
  ShellExecute(Handle, 'explore', PChar(''), nil, nil, SW_SHOW);
end;

procedure TForm1.WavDelClick(Sender: TObject);
begin
if slistbox1.ItemIndex=-1 then
Application.MessageBox('还没有被选中项呐','メッセージ',MB_ICONINFORMATION+MB_OK)
else
begin
  Application.MessageBox('删除选中项吗','メッセージ',MB_ICONINFORMATION+MB_OK);
  MediaPlayer1.Close;
  DeleteFile(slistbox1.Items[slistbox1.ItemIndex]);
  slistbox1.Items.Delete(slistbox1.ItemIndex);
end;
end;

procedure TForm1.WavPauseClick(Sender: TObject);
begin
if slistbox1.ItemIndex=-1 then
Application.MessageBox('还没有被选中项呐','メッセージ',MB_ICONINFORMATION+MB_OK)
else
begin
  MediaPlayer1.Pause;
end;
end;

procedure TForm1.WavPlayClick(Sender: TObject);
var
path:String;
begin
if slistbox1.ItemIndex=-1 then
Application.MessageBox('还没有被选中项呐','メッセージ',MB_ICONINFORMATION+MB_OK)
else
begin
  path:=slistbox1.Items[slistbox1.ItemIndex];
  MediaPlayer1.FileName:=path;
  MediaPlayer1.Open;
  MediaPlayer1.Play;
end;
end;

procedure TForm1.WavReClick(Sender: TObject);
begin
if slistbox1.ItemIndex=-1 then
Application.MessageBox('还没有被选中项呐','メッセージ',MB_ICONINFORMATION+MB_OK)
else
begin
  MediaPlayer1.Resume;
end;
end;

end.
