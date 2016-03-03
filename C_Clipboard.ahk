;
; AutoHotkey Version: 1.1.23.01
; Language:       English
; Platform:       Windows 10
; Author:         WizardZedd
;
; 	CLASS: C_Clipboard
;	vars:
;		clip - The pseudo clipboard
;		timeout - The timeout in seconds for clipWait
;	methods:
;		Copy
;		Paste

class C_Clipboard
{
	static tClip ; Temporary Clip
	static isBusy:=false  ; To prevent nasty things from happening (does anyone know how to make it private?)
	__New(clip="", timeout=0) {
		this.clip:=clip				; The pseudo clipboard
		this.timeout:=timeout		; The timeout in seconds for clipWait
	}
	
	; COPY
	Copy() {
		if(isBusy)
			return false		
		isBusy:=true
		tClip:=ClipboardAll
		Clipboard = 
		SendInput, ^c
		ClipWait, % this.timeout , 1	; Waits for anything on clipboard
		if(!wasError:=ErrorLevel) {
			if((this.clip := Clipboard) = "") {	
				MsgBox, 16, Copy Error,  % A_ThisFunc ": An error occurred. Copy Unsuccessful. `nThis happens when the clipboard was found empty because it `nwas changed during processing."
				wasError:=true
			}
		}
		Clipboard:=tClip
		isBusy:=false
		return (wasError ? false : this.clip)
	}
	; PASTE
	Paste() {
		if(isBusy) {
			ToolTip, Busy now`, Please try again in a moment.
			return
		}
		if(this.clip != "") {
			isBusy:=true 
			tClip:=ClipboardAll
			Clipboard:=this.clip
			if (!wasError:=ErrorLevel) {
				SendInput, ^v
				sleep, 100 ; For reliability
			}
			Clipboard:=tClip
			isBusy:=false
		} else 
			sendinput ^v
		return (wasError ? false : this.clip)
	}
	; CUT
	Cut() {
		if(isBusy) 
			return false
		isBusy:=true
		tClip:=ClipboardAll
		Clipboard = 
		sendinput, ^x
		ClipWait, % this.timeout , 1
		if(!wasError:=ErrorLevel) {
			if((this.clip := Clipboard) = "") {	
				MsgBox, 16, Copy Error,  % A_ThisFunc ": An error occurred. Copy Unsuccessful. `nThis happens when the clipboard was found empty because it `nwas changed during processing."
				wasError:=true
			} 
		} 
		Clipboard:=tClip
		isBusy:=false
		return (wasError ? false : this.clip)
	}
}