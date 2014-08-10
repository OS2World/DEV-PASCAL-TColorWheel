UNIT ColorWheel;

(*                                                                      *)
(* AUTHOR: Michael G. Slack (slack@ibm.net)    DATE WRITTEN: 1998/02/09 *)
(* ENVIRONMENT: Speedsoft Sibyl.                                        *)
(*                                                                      *)
(* Component defines the undocumented color wheel OS/2 control.  Based  *)
(* on code originally coded by Paul Ratcliffe (paulr@orac.clara.co.uk). *)
(* Component/dialog can be used in two ways, interactive by intercepting*)
(* the wm_ColorWheelChanged message by the main window or by using the  *)
(* color property after dialog execution.                               *)
(* Note: I couldn't figure out how to get the undocumented control for  *)
(*       the dialog in a Sibyl resource, so the dialog was compiled     *)
(*       using RC.EXE and then loaded into a byte array to pass into the*)
(*       WinCreateDlg procedure.                                        *)
(*                                                                      *)
(* -------------------------------------------------------------------- *)
(*                                                                      *)
(* REVISED: 1998/02/12 - Initial version complete.                      *)
(*          1998/02/14 - Added in fix for dialog color.                 *)
(*             (thanks to hint from Cindy Ross-rossc@us.ibm.com)        *)
(*          1998/07/27 - Changed the original author of the code per    *)
(*                       original author (whoops).  Removed erroneous   *)
(*                       warp 3 messages from the component.  (1.01)    *)
(*                                                                      *)

INTERFACE

 USES Classes, Forms;

 CONST cwMaxTitleSize = 128; {max dialog title size}
       {undocumented color wheel messages         }
       { - both: mp1 = RGB color, mp2 = 0         }
       { - SetVal sent to colorwheel, Changed sent}
       {   to parent as color is changed.         }
       wm_ColorWheelChanged = $0601;
       cwm_ColorWheelSetVal = $0602;

 TYPE {Color return type - from color property}
      PCLR = ^TCLR;
      TCLR = RECORD
              CASE BYTE OF
               0 : (lColor : LONGWORD);
               1 : (Blu, Grn, Red, X : BYTE);
             END;
      {Declare new class}
      TColorWheel=Class(TComponent)
                  Private
                    FColor    : TCLR;
                    FDlgTitle : STRING[cwMaxTitleSize+1];
                  Protected
                    Procedure SetupComponent; Override;
                    FUNCTION  GetDlgTitle : STRING;
                    PROCEDURE SetDlgTitle(NewTitle : STRING);
                    FUNCTION  GetVersion : STRING;
                  Public
                    Destructor Destroy; Override;
                    FUNCTION Execute : BOOLEAN;
                    PROPERTY Color : TCLR Read FColor Write FColor;
                  Published
                    PROPERTY DlgTitle : STRING Read GetDlgTitle
                                               Write SetDlgTitle;
                    PROPERTY Version : STRING Read GetVersion
                                              stored FALSE;
                  End;

(************************************************************************)

 EXPORTS TColorWheel,'Custom','ColorWheel.BMP';

(************************************************************************)

IMPLEMENTATION

 USES SysUtils, OS2Def, BseDos, PMWin, PMStdDlg, Messages;

 CONST IVersion : STRING[20] = 'Version 1.01';
       {color edit dialog definition - RC follows:}
       (*
       DLGTEMPLATE DLG_CWHEEL LOADONCALL MOVEABLE DISCARDABLE
       BEGIN
         DIALOG  "", DLG_CWHEEL, 0, 0, 228, 170, NOT WS_VISIBLE | NOT WS_SAVEBITS,
                   FCF_SYSMENU | FCF_TITLEBAR | FCF_CLOSEBUTTON  | FCF_NOBYTEALIGN
           BEGIN
               CONTROL         "", CWHEEL, -10, 43, 248, 135, WC_COLORWHEEL,
                               WS_GROUP | WS_TABSTOP | WS_VISIBLE
               LTEXT           SZ_RED, TXT_RED, 4, 32, 36, 8, DT_BOTTOM |
                               DT_MNEMONIC
               SPINBUTTON      SPN_RED, 39, 31, 38, 12, SPBS_NUMERICONLY |
                               SPBS_MASTER | SPBS_JUSTRIGHT | SPBS_FASTSPIN |
                               WS_GROUP
                               CTLDATA 24,0,  0,0,  0,0,  255,0,  0,0,  0,0
               LTEXT           SZ_GREEN, TXT_GREEN, 4, 18, 36, 8, DT_VCENTER |
                               DT_MNEMONIC
               SPINBUTTON      SPN_GREEN, 39, 17, 38, 12, SPBS_NUMERICONLY |
                               SPBS_MASTER | SPBS_JUSTRIGHT | SPBS_FASTSPIN |
                               WS_GROUP
                               CTLDATA 24,0,  0,0,  0,0,  255,0,  0,0,  0,0
               LTEXT           SZ_BLUE, TXT_BLUE, 4, 4, 36, 8, DT_VCENTER |
                               DT_MNEMONIC
               SPINBUTTON      SPN_BLUE, 39, 3, 38, 12, SPBS_NUMERICONLY |
                               SPBS_MASTER | SPBS_JUSTRIGHT | SPBS_FASTSPIN |
                               WS_GROUP
                               CTLDATA 24,0,  0,0,  0,0,  255,0,  0,0,  0,0
               DEFPUSHBUTTON   SZ_OK, BTN_OK, 88, 2, 45, 14, WS_GROUP
               PUSHBUTTON      SZ_UNDO, BTN_UNDO, 134, 2, 45, 14, NOT WS_TABSTOP
               PUSHBUTTON      SZ_CANCEL, BTN_CANCEL, 180, 2, 45, 14, NOT WS_TABSTOP
           END
       END
       *)
       ClrDlg : ARRAY[1..481] OF BYTE =
         ($E1,$01,$00,$00,$52,$03,$0E,$00,$01,$00,$FF,$FF,$00,$00,$00,$00,
          $0A,$00,$00,$00,$01,$00,$00,$00,$58,$01,$80,$00,$00,$10,$00,$00,
          $00,$00,$E4,$00,$AA,$00,$64,$00,$FF,$FF,$59,$01,$00,$00,$00,$00,
          $10,$00,$5D,$01,$00,$00,$6E,$01,$00,$00,$03,$80,$F6,$FF,$2B,$00,
          $F8,$00,$87,$00,$65,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,
          $05,$00,$05,$00,$6F,$01,$01,$28,$01,$80,$04,$00,$20,$00,$24,$00,
          $08,$00,$66,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$20,$00,
          $00,$00,$75,$01,$15,$01,$03,$80,$27,$00,$1F,$00,$26,$00,$0C,$00,
          $67,$00,$FF,$FF,$76,$01,$00,$00,$00,$00,$00,$00,$05,$00,$07,$00,
          $8E,$01,$01,$24,$01,$80,$04,$00,$12,$00,$24,$00,$08,$00,$68,$00,
          $FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,$20,$00,$00,$00,$96,$01,
          $15,$01,$03,$80,$27,$00,$11,$00,$26,$00,$0C,$00,$69,$00,$FF,$FF,
          $97,$01,$00,$00,$00,$00,$00,$00,$05,$00,$06,$00,$AF,$01,$01,$24,
          $01,$80,$04,$00,$04,$00,$24,$00,$08,$00,$6A,$00,$FF,$FF,$FF,$FF,
          $00,$00,$00,$00,$00,$00,$20,$00,$00,$00,$B6,$01,$15,$01,$03,$80,
          $27,$00,$03,$00,$26,$00,$0C,$00,$6B,$00,$FF,$FF,$B7,$01,$00,$00,
          $00,$00,$00,$00,$03,$00,$03,$00,$CF,$01,$00,$04,$03,$80,$58,$00,
          $02,$00,$2D,$00,$0E,$00,$6C,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00,
          $00,$00,$03,$00,$05,$00,$D3,$01,$00,$00,$00,$80,$86,$00,$02,$00,
          $2D,$00,$0E,$00,$6D,$00,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,$00,
          $03,$00,$07,$00,$D9,$01,$00,$00,$00,$80,$B4,$00,$02,$00,$2D,$00,
          $0E,$00,$6E,$00,$FF,$FF,$FF,$FF,$00,$03,$10,$00,$04,$43,$6F,$6C,
          $6F,$72,$53,$65,$6C,$65,$63,$74,$43,$6C,$61,$73,$73,$00,$00,$7E,
          $52,$65,$64,$3A,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7E,$47,
          $72,$65,$65,$6E,$3A,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7E,
          $42,$6C,$75,$65,$3A,$00,$00,$18,$00,$00,$00,$00,$00,$00,$00,$00,
          $00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$7E,
          $4F,$4B,$00,$7E,$55,$6E,$64,$6F,$00,$7E,$43,$61,$6E,$63,$65,$6C,
          $00);

(************************************************************************)
(***** Internal functions/constants/types used by component         *****)

 CONST ClassLib : CSTRING = 'WPCONFIG.DLL'; {color wheel defined here}
       {dialog constants}
       dlg_CWheel = 100;
       cWheel     = 101;
       txt_Red    = 102;
       spn_Red    = 103;
       txt_Green  = 104;
       spn_Green  = 105;
       txt_Blue   = 106;
       spn_Blue   = 107;
       btn_OK     = 108;
       btn_Undo   = 109;
       btn_Cancel = 110;

 TYPE PAPPDATA = ^TAPPDATA;
      TAPPDATA = RECORD {modified from original code}
                  bSize    : WORD;
                  ParentWnd,
                  OwnerWnd : HWND;
                  ChgMsg   : LONGWORD;
                  SetMsg   : LONGWORD;
                  DlgTitle : STRING[cwMaxTitleSize+1];
                  UpdFlg   : BOOLEAN;
                  UndoClr  : TCLR;
                  CurClr   : TCLR;
                  ParRect  : RECTL;
                  DlgRect  : RECTL;
                 END;

(************************************************************************)

 PROCEDURE SetSpins(Wnd : HWND; Clr : TCLR);
     (* procedure to set spin buttons to defined values *)

  BEGIN (*setspins*)
   WinSendDlgItemMsg(Wnd,spn_Red,spbm_SetCurrentValue,Clr.Red,0);
   WinSendDlgItemMsg(Wnd,spn_Green,spbm_SetCurrentValue,Clr.Grn,0);
   WinSendDlgItemMsg(Wnd,spn_Blue,spbm_SetCurrentValue,Clr.Blu,0);
  END; (*setspins*)

(************************************************************************)

 FUNCTION EditColorDlgProc(Wnd : HWND; Msg : ULONG;
                           mp1, mp2 : MPARAM) : MRESULT; APIENTRY;
     (* function to handle the edit color dialog *)

    VAR pp     : PAPPDATA;
        I1, I2 : INTEGER;
        FF     : BOOLEAN;
        ulVal  : LONGWORD;

  BEGIN (*editcolordlgproc*)
   Result := MRESULT(FALSE);
   CASE Msg OF
    wm_InitDlg : BEGIN {initdlg}
                  pp := PAPPDATA(mp2);
                  WinSetWindowPtr(Wnd,0,POINTER(mp2));
                  WinSetWindowText(Wnd,pp^.DlgTitle);
                  SetSpins(Wnd,pp^.UndoClr);
                  WinSendDlgItemMsg(Wnd,cWheel,pp^.SetMsg,
                                    pp^.UndoClr.lColor,0);
                  pp^.UpdFlg := TRUE; {set update flag}
                  {set dialog in middle of parent}
                  WinQueryWindowRect(pp^.ParentWnd,pp^.ParRect);
                  WinQueryWindowRect(Wnd,pp^.DlgRect);
                  I1 := (pp^.ParRect.xRight-pp^.DlgRect.xRight) DIV 2;
                  I2 := (pp^.ParRect.yTop-pp^.DlgRect.yTop) DIV 2;
                  WinSetWindowPos(Wnd,0,I1,I2,0,0,swp_Move OR swp_Show);
                  {make sure dialog is dialog color}
                  ulVal := sysClr_DialogBackground;
                  WinSetPresParam(Wnd,pp_BackgroundColorIndex,
                                  SizeOf(ulVal),ulVal);
                 END; {initdlg}
    wm_ColorWheelChanged : BEGIN {wheel changed msg}
                            pp := WinQueryWindowPtr(Wnd,0);
                            pp^.CurClr.lColor := LONGWORD(mp1);
                            pp^.UpdFlg := FALSE; {reset flag}
                            SetSpins(Wnd,pp^.CurClr);
                            pp^.UpdFlg := TRUE; {set flag}
                            {was ParentWnd}
                            WinSendMsg(pp^.OwnerWnd,Msg,mp1,mp2);
                           END; {chg msg}
    wm_Control : BEGIN {control message recvd}
                  pp := WinQueryWindowPtr(Wnd,0);
                  FF := (Short1FromMP(mp1) = spn_Red) OR
                        (Short1FromMP(mp1) = spn_Green) OR
                        (Short1FromMP(mp1) = spn_Blue);
                  FF := FF AND ((Short2FromMP(mp1) = spbn_Change) OR
                                (Short2FromMP(mp1) = spbn_EndSpin));
                  IF FF AND pp^.UpdFlg
                   THEN BEGIN {handle it}
                         WinSendMsg(HWNDFromMP(mp2),spbm_QueryValue,
                                    MPARAM(@ulVal),
                                    MPFrom2Short(0,spbq_AlwaysUpdate));
                         CASE Short1FromMP(mp1) OF
                          spn_Red   : pp^.CurClr.Red := BYTE(ulVal);
                          spn_Green : pp^.CurClr.Grn := BYTE(ulVal);
                          ELSE pp^.CurClr.Blu := BYTE(ulVal);
                         END; {case}
                         WinSendDlgItemMsg(Wnd,cWheel,pp^.SetMsg,
                                           pp^.CurClr.lColor,0);
                         {was ParentWnd}
                         WinSendMsg(pp^.OwnerWnd,pp^.ChgMsg,
                                    pp^.CurClr.lColor,0);
                        END; {then}
                 END; {ctrl msg}
    wm_Command : BEGIN {command msg recvd}
                  pp := WinQueryWindowPtr(Wnd,0);
                  CASE WORD(mp1) OF
                   btn_OK   : WinDismissDlg(Wnd,pp^.CurClr.lColor);
                   btn_Undo : BEGIN {undo pressed = reset to start clr}
                               SetSpins(Wnd,pp^.UndoClr);
                               WinSendDlgItemMsg(Wnd,cWheel,pp^.SetMsg,
                                                 pp^.CurClr.lColor,0);
                              END; {undo}
                   ELSE WinDismissDlg(Wnd,pp^.UndoClr.lColor); {cancel}
                  END; {case}
                 END; {cmd msg}
    wm_Close : BEGIN {close button pressed}
                pp := WinQueryWindowPtr(Wnd,0);
                WinDismissDlg(Wnd,pp^.UndoClr.lColor);
               END; {close}
    ELSE Result := WinDefDlgProc(Wnd,Msg,mp1,mp2);
   END; {case}
  END; (*editcolordlgproc*)

(************************************************************************)
(***** TColorWheel component                                        *****)

 Procedure TColorWheel.SetupComponent;
  Begin
   Inherited SetupComponent;
   FColor.Blu := 204; {gray window color}
   FColor.Grn := 204;
   FColor.Red := 204;
   FColor.X := 0;
   FDlgTitle := 'Edit Color';
  End;

(************************************************************************)

 FUNCTION TColorWheel.GetDlgTitle : STRING;
     (* function to return dlg title to property *)

  BEGIN (*tcolorwheel.getdlgtitle*)
   Result := FDlgTitle;
  END; (*tcolorwheel.getdlgtitle*)

(************************************************************************)

 PROCEDURE TColorWheel.SetDlgTitle(NewTitle : STRING);
     (* procedure to set the dialog title *)

  BEGIN (*tcolorwheel.setdlgtitle*)
   FDlgTitle := Copy(NewTitle,1,cwMaxTitleSize);
  END; (*tcolorwheel.setdlgtitle*)

(************************************************************************)

 FUNCTION TColorWheel.GetVersion : STRING;
     (* function to return version string *)

  BEGIN (*tcolorwheel.getversion*)
   Result := IVersion;
  END; (*tcolorwheel.getversion*)

(************************************************************************)

 Destructor TColorWheel.Destroy;
  Begin
   Inherited Destroy;
  End;

(************************************************************************)

 FUNCTION TColorWheel.Execute : BOOLEAN;
    TYPE PDLGTEMPLATE = ^DLGTEMPLATE;
    VAR pAppD  : PAPPDATA;
        pp     : PDLGTEMPLATE;
        Dw     : HWND;
        R      : LONGWORD;
        LibHnd : HLIB;
  BEGIN
   Result := FALSE;
   IF DosAllocMem(pAppD,SizeOf(TAPPDATA),
                  pag_Read OR pag_Write OR pag_Commit) <> 0
    THEN Exit;
   pAppD^.bSize := SizeOf(TAPPDATA);
   pAppD^.ParentWnd := hwnd_Desktop;
   pAppD^.OwnerWnd := Application.MainForm.Handle;
   pAppD^.ChgMsg := wm_ColorWheelChanged;
   pAppD^.SetMsg := cwm_ColorWheelSetVal;
   LibHnd := WinLoadLibrary(AppHandle,ClassLib); {wpconfig}
   IF LibHnd = 0
    THEN BEGIN {couldn't load library to register color class}
          DosFreeMem(pAppD); Exit;
         END; {then}
   pAppD^.UndoClr := FColor;
   pAppD^.CurClr  := FColor;
   pAppD^.DlgTitle := FDlgTitle;
   pp := PDLGTEMPLATE(@ClrDlg);
   Dw := WinCreateDlg(pAppD^.ParentWnd,pAppD^.OwnerWnd,
                      @EditColorDlgProc,pp^,pAppD);
   IF Dw <> 0
    THEN BEGIN {run it}
          R := WinProcessDlg(Dw);
          WinDestroyWindow(Dw);
         END; {then}
   WinDeleteLibrary(AppHandle,LibHnd); {release wpconfig}
   DosFreeMem(pAppD);
   Result := (Dw <> 0) AND (R <> FColor.lColor);
   IF Result THEN FColor.lColor := R;
  END;

(************************************************************************)

INITIALIZATION
  {Register class}
  RegisterClasses([TColorWheel]);
END.
