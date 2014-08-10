PROGRAM FilterMe;

(*                                                                      *)
(* Program to filter a single dialog compiled into a resource (.RES)    *)
(* and convert it into a SP/2 or Sibyl 'byte' array that could be passed*)
(* to the WinCreateDlg function.                                        *)
(* Compile in text mode.                                                *)
(*                                                                      *)

 USES SysUtils;

 VAR F    : FILE OF BYTE;
     FF   : TEXT;
     S    : STRING[100];
     B    : BYTE;
     I, J : LONGINT;

BEGIN
 IF ParamStr(1) = '' THEN Halt;
 S := ParamStr(1);
 Assign(F,S);
 {$I-} Reset(F); {$I+}
 IF IOResult <> 0 THEN Halt;
 S := Copy(S,1,Length(S)-4) + '.TXT'; {output is samename.txt}
 Assign(FF,S);
 {$I-} Rewrite(FF); {$I+}
 IF IOResult <> 0 THEN Halt;
 I := 0; J := 0;
 Writeln(FF,'('); {const byte array = '($xx,$xx,...,$xx)'}
 WHILE NOT(EOF(F)) DO
  BEGIN {read file until end}
   Read(F,B); Inc(I);
   IF I > 12
    THEN BEGIN {bypass identifiers and dialog size info}
          IF J <> 0 THEN Write(FF,',');
          Write(FF,'$',IntToHex(B,2)); Inc(J);
          IF J = 16
           THEN BEGIN {16 bytes per line}
                 J := 0;
                 IF NOT(EOF(FF)) THEN Writeln(FF,',');
                END; {then}
         END; {then}
  END; {while}
 Write(FF,')');
 Close(F);
 Close(FF);
END.

