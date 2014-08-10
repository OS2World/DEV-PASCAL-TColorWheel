Unit CW_Win;

Interface

Uses
  Classes, Forms, Graphics, ColorWheel, Buttons, Dialogs, ExtCtrls;

Type
  TForm1 = Class (TForm)
    ColorWheel1 : TColorWheel;
    Button1     : TButton;
    BitBtn1     : TBitBtn;
    Procedure Button1OnClick (Sender: TObject);
  Private
    {Insert private declarations here}
  Public
    procedure WMColorWheelChanged(VAR Msg : TMESSAGE);
     message wm_ColorWheelChanged; {warp 4 only}
  End;

Var
  Form1: TForm1;

Implementation

Procedure TForm1.Button1OnClick (Sender: TObject);
Begin
  IF ColorWheel1.Execute
   THEN MessageBox('Color set.',mtInformation,[mbOK])
  ELSE MessageBox('Color not changed.',mtInformation,[mbOK]);
End;

Procedure TForm1.WMColorWheelChanged(VAR Msg : TMESSAGE);
Begin
  Color := TCLR(Msg.Param1).lColor;
End;

Initialization
  RegisterClasses ([TForm1, TColorWheel, TButton, TBitBtn]);
End.
