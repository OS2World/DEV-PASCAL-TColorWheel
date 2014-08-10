Program CW_Test;

Uses
  Forms, Graphics, CW_Win;

{$r CW_Test.SCU}

Begin
  Application.Create;
  Application.CreateForm (TForm1, Form1);
  Application.Run;
  Application.Destroy;
End.
