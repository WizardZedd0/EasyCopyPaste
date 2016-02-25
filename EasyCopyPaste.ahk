;
; AutoHotkey Version: 1.1.23.01
; Language:       English
; Platform:       Windows 10
; Author:         WizardZedd
; Version:        0.9
;
; Script Function:  AUTO COPY and EASY PASTE
;   Auto Copy:
;       Automatically copies text that:
;           -is highlighted by dragging the mouse
;           -Double Click
;           -Triple Click
;           -Ctrl+A - WARNING, was not designed with large clipboards in mind. Feel Free to comment out
;                       this hotkey if you like.
;           -SHIFT
;       NOTE: Copies by using CTRL+C
;   Pastes:
;       LBUTTON + RBUTTON pastes the text where the cursor is at.
;       NOTE: Pastes by using CTRL+V
;   Miscellaneous:
;      MBUTTON:: DELETE
;      XBUTTON1:: UNDO (CTRL+Z)
;      XBUTTON2:: REDO (CTRL+R)
;      Due to the nature of the setup, replacement is also easy 
;       (IE. Select text to copy, while holding left button select text to replace and push right button.)
;   Very nice for mouse, especially those with XButtons. Not so nice for laptops.
;   Uses the clipboard as a transfer point, but only temporarily. Ctrl+C and Ctrl+V may be used normally.
;	
;   Inspired by: pwy @ https://autohotkey.com/board/topic/5139-auto-copy-selected-text-to-clipboard/
; =======================================================================================================

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force		; Don't worry about annoying messages.
#InstallMouseHook
; #NoTrayIcon
#include C_Clipboard.ahk
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
myClip := new C_Clipboard()

XButton1::^z    ; UNDO
XButton2::^r    ; REDO
MButton::Delete ; DELETE
~LButton & RButton::return  ; Prevent LButton + RButton physical press

; Paste
Paste:
if(GetKeyState("LButton", "P"))
   KeyWait, LButton
if(GetKeyState("RButton", "P"))
   KeyWait, RButton
sleep, 10
myClip.Paste()
return

;Auto copy clipboard
; LSHIFT
*~Lshift::
TimeButtonDown = %A_TickCount%
x0:=A_CaretX, y0:=A_CaretY
KeyWait, Shift
   if (A_TickCount-TimeButtonDown > 200)  ; Button was held down long enough
   {
      if (A_CaretX-x0 > 5 || A_CaretX-x0 < -5 || A_CaretY-y0 > 5 || A_CaretY-y0 < -5)
         myClip.Copy()
   }
return  
; END LSHIFT

; LBUTTON
~LButton::
MouseGetPos, x, y
TimeButtonDown = %A_TickCount%
; Wait for it to be released
Loop
{
   Sleep 10
   GetKeyState, LButtonState, LButton, P
   GetKeyState, RButtonState, RButton, P
   if LButtonState = U  ; Button has been released.
      break
   else if (RButtonState = "D")
      goto, Paste
   if (A_TickCount - TimeButtonDown > 150)  ; Button was held down too long, so assume it's not a double-click.
   {
      while(GetKeyState("LButton", "P")) {  ; Wait for LButton to be released / check for Double buttons
         Sleep 10
         if(GetKeyState("RButton", "P"))
            goto, Paste
      }
      MouseGetPos, x0, y0
      if (x-x0 > 5 || x-x0 < -5 || y-y0 > 5 || y-y0 < -5) { ; Has it moved?
         sleep, 10
         myClip.Copy()
      }
      return
   }
}
; Otherwise, button was released quickly enough.  Wait to see if it's a double-click:
KeyWait, LButton, D T0.35
if(ErrorLevel) ; Not pressed down
   return
;Button pressed down again, it's at least a double-click
KeyWait, LButton, T0.5
if(GetKeyState("RButton", "P")) ; Last chance at pasting
   goto, Paste
if(ErrorLevel)     ; Too long
   return
;Button released a 2nd time
myClip.Copy()
KeyWait, LButton, D T0.35
if(ErrorLevel)    ; Was not pressed down for triple-click
   return 
;Tripple-click:
 KeyWait, LButton, T0.5
 if(!ErrorLevel)
   myClip.Copy()
return
; END LBUTTON

; CTRL A - WARNING, was not designed with large clipboards in mind
~^a:: myClip.Copy()
