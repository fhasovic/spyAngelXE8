unit Desktop_Remoto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Zlib,
  Dialogs, ExtCtrls, StdCtrls, ScktComp, ComCtrls, StreamManager, Vcl.ExtDlgs;
type
  TRemoto = class(TThread)
    procedure Execute; override;
  public
    Socket: TCustomWinSocket;
  private
  end;

type
  TForm2 = class(TForm)
    Panel1: TPanel;
    CheckBox2: TCheckBox;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Timer1: TTimer;
    CheckBox3: TCheckBox;
    Button1: TButton;
    SaveDialog: TSavePictureDialog;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    CheckBox1: TCheckBox;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox2KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox3KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckWCKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure RadioButton3Exit(Sender: TObject);
    procedure RadioButton1Exit(Sender: TObject);
    procedure RadioButton2Exit(Sender: TObject);
    procedure CheckBox2Exit(Sender: TObject);
    procedure CheckBox3Exit(Sender: TObject);
  private
    { Private declarations }
  public
    Socket, Socket2: TCustomWinSocket;
    Remoto: TRemoto;
    ResX, ResY: Integer;
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Principal;

{$R *.dfm}
{$SETPEFlAGS IMAGE_FILE_DEBUG_STRIPPED or IMAGE_FILE_LINE_NUMS_STRIPPED or
 IMAGE_FILE_LOCAL_SYMS_STRIPPED OR IMAGE_FILE_RELOCS_STRIPPED}

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}

// Descomprime dados
function DeCompressStream(SrcStream: TMemoryStream): boolean;
var
  InputStream, OutputStream: TMemoryStream;
  inbuffer, outbuffer: Pointer;
  count, outcount: longint;
begin
  inbuffer:=nil;
  count:=0;
  result := false;
  if not assigned(SrcStream) then
    exit;

  InputStream := TMemoryStream.Create;
  OutputStream := TMemoryStream.Create;
  try
    InputStream.LoadFromStream(SrcStream);
    count := InputStream.Size;
    getmem(inbuffer, count);
    InputStream.ReadBuffer(inbuffer^, count);
    Zlib.ZDecompress(inbuffer, count, outbuffer, outcount);
    OutputStream.Write(outbuffer^, outcount);
    SrcStream.Clear;
    SrcStream.LoadFromStream(OutputStream);
    result := true;
  finally
    InputStream.Free;
    OutputStream.Free;
    FreeMem(inbuffer, count);
    FreeMem(outbuffer, outcount);
  end;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Active = false then exit;
  if RadioButton1.Checked or RadioButton2.Checked then
  begin
    X := (X * ResX) div Image1.Width;
    Y := (Y * ResY) div Image1.Height;

    if Button = mbLeft then
      Socket.SendText(AnsiString('<|cursold|>' + intToStr(X) + '<|>' + intToStr(Y) + '<<|'))
    else
      Socket.SendText(AnsiString('<|cursord|>' + intToStr(X) + '<|>' + intToStr(Y) + '<<|'));
  end;
end;

procedure TForm2.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Active = false then exit;
  if RadioButton1.Checked or RadioButton2.Checked then
  begin
    X := (X * ResX) div Image1.Width;
    Y := (Y * ResY) div Image1.Height;
    if Button = mbLeft then
      Socket.SendText(AnsiString('<|cursolu|>' + intToStr(X) + '<|>' + intToStr(Y) + '<<|'))
    else
      Socket.SendText(AnsiString('<|cursoru|>' + intToStr(X) + '<|>' + intToStr(Y) + '<<|'));
  end;
end;

procedure TForm2.RadioButton1Exit(Sender: TObject);
begin
  ScrollBox1.SetFocus;
end;

procedure TForm2.RadioButton2Exit(Sender: TObject);
begin
  ScrollBox1.SetFocus;
end;

procedure TForm2.RadioButton3Exit(Sender: TObject);
begin
  ScrollBox1.SetFocus;
end;

procedure TForm2.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Active = false then exit;
  if RadioButton1.Checked then
  begin
    X := (X * ResX) div Image1.Width;
    Y := (Y * ResY) div Image1.Height;
    Socket.SendText(AnsiString('<|cursopos|>' + intToStr(X) + '<|>' + intToStr(Y) + '<<|'));
  end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
var
  i: byte;
begin
  if (Active) and (CheckBox2.Checked) then
  begin
    try
      for i := 8 To 222 do
      begin
        if GetAsyncKeyState(i) = -32767 then
        begin
          case i of
            8:
              Socket2.SendText('{BS}');
            9:
              Socket2.SendText('{TAB}');
            13:
              Socket2.SendText('{ENTER}');
            // 17 : memo1.text:=memo1.text+'[Ctrl]';
            27:
              Socket2.SendText('{ESCAPE}');
            32:
              Socket2.SendText(' '); // Space
            33:
              Socket2.SendText('{PGUP}');
            34:
              Socket2.SendText('{PGDN}');
            35:
              Socket2.SendText('{END}');
            36:
              Socket2.SendText('{HOME}');
            37:
              Socket2.SendText('{LEFT}');
            38:
              Socket2.SendText('{UP}');
            39:
              Socket2.SendText('{RIGHT}');
            40:
              Socket2.SendText('{DOWN}');
            44:
              Socket2.SendText('{PRTSC}');
            46:
              Socket2.SendText('{DEL}');
            145:
              Socket2.SendText('{SCROLLLOCK}');

            // Number 1234567890 Symbol !@#$%^&*()
            48:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText(')')
              else
                Socket2.SendText('0');
            49:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('!')
              else
                Socket2.SendText('1');
            50:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('@')
              else
                Socket2.SendText('2');
            51:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('#')
              else
                Socket2.SendText('3');
            52:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('$')
              else
                Socket2.SendText('4');
            53:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('%')
              else
                Socket2.SendText('5');
            54:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('^')
              else
                Socket2.SendText('6');
            55:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('&')
              else
                Socket2.SendText('7');
            56:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('*')
              else
                Socket2.SendText('8');
            57:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('(')
              else
                Socket2.SendText('0');
            65 .. 90: // a..z , A..Z
              begin
                if ((GetKeyState(VK_CAPITAL)) = 1) then
                  if GetKeyState(VK_SHIFT) < 0 then
                    Socket2.SendText(AnsiString(LowerCase(Chr(i)))) // a..z
                  else
                    Socket2.SendText(AnsiString(UpperCase(Chr(i)))) // A..Z
                else if GetKeyState(VK_SHIFT) < 0 then
                  Socket2.SendText(AnsiString(UpperCase(Chr(i)))) // A..Z
                else
                  Socket2.SendText(AnsiString(LowerCase(Chr(i)))); // a..z
              end;
            // Numpad
            96 .. 105:
              Socket2.SendText(AnsiString(intToStr(i - 96))); // Numpad  0..9
            106:
              Socket2.SendText('*');
            107:
              Socket2.SendText('&');
            109:
              Socket2.SendText('-');
            110:
              Socket2.SendText('.');
            111:
              Socket2.SendText('/');

            112 .. 123: // F1-F12
              Socket2.SendText(AnsiString('{F' + intToStr(i - 111) + '}'));

            186:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText(':')
              else
                Socket2.SendText(';');
            187:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('+')
              else
                Socket2.SendText('=');
            188:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('<')
              else
                Socket2.SendText(',');
            189:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('_')
              else
                Socket2.SendText('-');
            190:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('>')
              else
                Socket2.SendText('.');
            191:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('?')
              else
                Socket2.SendText('/');
            192:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('~')
              else
                Socket2.SendText('`');
            219:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('{')
              else
                Socket2.SendText('[');
            220:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('|')
              else
                Socket2.SendText('\');
            221:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('}')
              else
                Socket2.SendText(']');
            222:
              if GetKeyState(VK_SHIFT) < 0 then
                Socket2.SendText('"')
              else
                Socket2.SendText('''');
          end;
        end;
      end;
    except
      exit;
    end;
  end;

end;

procedure TForm2.CheckBox2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if SaveDialog.Execute then
    Image1.Picture.SaveToFile(SaveDialog.FileName+'.bmp');
end;

procedure TForm2.CheckBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure TForm2.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
    Socket.SendText(AnsiString('<|REQUESTKEYBOARD|>' + intToStr(Socket.Handle) + '<<|'));
end;

procedure TForm2.CheckBox2Exit(Sender: TObject);
begin
  ScrollBox1.SetFocus;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var
  L: TListItem;
begin
  Checkbox1.Checked:=False;
  CheckBox2.Checked := false;
  RadioButton1.Checked := false;
  Socket.SendText('<|Close2|>');
  L := Form1.LV1.FindCaption(0, intToStr(Socket.Handle), false, true, false);
  if L <> nil then begin
    L.SubItems.Objects[1] := nil;
    L.SubItems.Objects[2] := nil;
  end;
  Form2.Destroy;
end;

procedure TForm2.FormResize(Sender: TObject);
begin
  { image1.left := trunc((ScrollBox1.width - image1.width) / 2);
    image1.top := trunc((ScrollBox1.height - image1.height) / 2); }
end;

procedure TForm2.Image1DblClick(Sender: TObject);
begin
  if RadioButton1.Checked or RadioButton2.Checked then
    Socket.SendText('<|cursodc|>');
end;

{ TRemoto }
{guardamos a primeira imgagem recebida e comparamos os dados com as outras.}
procedure TRemoto.Execute;
var
  i: Integer;
  L: TListItem;
//  MyBuffer: array [0 .. 10000] of byte;
//  MyReceviceLength: Integer;
  S, dados2: String;
  MyFirstBmp, MySecondBmp, MyCompareBmp, UnPackStream, MyTempStream: TMemoryStream;
  MySize: longint;
//  recebendo: boolean;
begin
  MyFirstBmp := TMemoryStream.Create;
  UnPackStream := TMemoryStream.Create;
  MyTempStream := TMemoryStream.Create;
  MySecondBmp := TMemoryStream.Create;
  MyCompareBmp := TMemoryStream.Create;
  MySize := 0;

  for i := 0 to Form1.LV1.Items.count - 1 do
  begin
    if Form1.LV1.Items.Item[i].SubItems.Objects[1] = TCustomWinSocket(Socket)
    then
      L := Form1.LV1.Items.Item[i];
  end;

  While not Terminated and Socket.Connected do
  begin
    if Socket.ReceiveLength > 0 then
    begin

      S := String(Socket.ReceiveText);
      if MySize = 0 then
      begin

        if Pos('<|TAMANHO|>', S) > 0 then
        begin
          dados2 := S;
          Delete(dados2, 1, Pos('<|TAMANHO|>', dados2) + 10);
          dados2 := Copy(dados2, 1, Pos('<<|', dados2) - 1);
          MySize := StrToInt(dados2);
          //recebendo := true;
          dados2 := '';
          Socket.SendText('<|okok|>');
        end;

      end
      else
      begin
        { MyReceviceLength := socket.ReceiveLength;
          Socket.ReceiveBuf(MyBuffer, MyReceviceLength);
          MyTempStream.Write(MyBuffer, MyReceviceLength); }
        dados2 := dados2 + S;

        if Length(dados2) >= MySize then
        begin

          MyTempStream.Write(AnsiString(dados2)[1], MySize);
          MyTempStream.Position := 0;
          UnPackStream.Clear;

          UnPackStream.LoadFromStream(MyTempStream);
          DeCompressStream(UnPackStream);

          UnPackStream.Position := 0;
          if MyFirstBmp.Size = 0 then
          begin
            MyFirstBmp.CopyFrom(UnPackStream, 0);
            MyFirstBmp.Position := 0;

            (L.SubItems.Objects[2] as TForm2)
              .Image1.Picture.Bitmap.LoadFromStream(MyFirstBmp);
            { (L.SubItems.Objects[2] as TForm2).Width := (L.SubItems.Objects[2] as TForm2).Image1.Width+30;
              (L.SubItems.Objects[2] as TForm2).Height := (L.SubItems.Objects[2] as TForm2).Image1.Height+100; }
            (L.SubItems.Objects[2] as TForm2).ResX :=
              (L.SubItems.Objects[2] as TForm2).Image1.Width;
            (L.SubItems.Objects[2] as TForm2).ResY :=
              (L.SubItems.Objects[2] as TForm2).Image1.Height;
          end
          else
          begin
            MyCompareBmp.Clear;
            MySecondBmp.Clear;

            MyCompareBmp.CopyFrom(UnPackStream, 0);
            ResumeStream(MyFirstBmp, MySecondBmp, MyCompareBmp);

            if L.SubItems.Objects[2] <> nil then
              (L.SubItems.Objects[2] as TForm2)
                .Image1.Picture.Bitmap.LoadFromStream(MySecondBmp);

          end;
          MySize := 0;
          UnPackStream.Clear;
          MyTempStream.Clear;
          MySecondBmp.Clear;
          MyCompareBmp.Clear;

          if ((L.SubItems.Objects[2] <> nil) and (L.SubItems.Objects[2] as TForm2).Visible) then begin
            if((L.SubItems.Objects[2] as TForm2).CheckBox1.Checked)then
              Socket.SendText('<|gets2|>')
            else
              Socket.SendText('<|gets|>');
          end;
        end;
      end;
    end;
    Sleep(10); // evita a CPU ficar em 100%
  end;
end;

procedure TForm2.CheckBox3Click(Sender: TObject);
begin
  if CheckBox3.Checked then
  begin
    Image1.AutoSize := false;
    Image1.Stretch := true;
    Image1.Align := alClient;
  end
  else
  begin
    Image1.AutoSize := true;
    Image1.Stretch := false;
    Image1.Align := alNone;
  end;
end;

procedure TForm2.CheckBox3Exit(Sender: TObject);
begin
  ScrollBox1.SetFocus;
end;

procedure TForm2.CheckBox3KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure TForm2.CheckWCKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

end.
