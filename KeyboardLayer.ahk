#Requires AutoHotkey v2.0
; Global variable to track the current layer
global currentLayer := 1
; Disable normal CapsLock behavior
SetCapsLockState "AlwaysOff"
; CapsLock as layer switch
CapsLock:: {
    global currentLayer
    currentLayer := currentLayer == 1 ? 2 : 1
    ToolTip("Layer " . currentLayer . (currentLayer = 1 ? " (Default)" : " (Programming)"))
    SetTimer () => ToolTip(), -1000
}

; Function to show tooltip with longer duration and better visibility
ShowTooltip(text, duration := 10000) {
    static currentTooltip := 0
    
    ; Increment tooltip number to allow multiple tooltips
    currentTooltip := Mod(currentTooltip + 1, 20)
    
    ; Show tooltip with distinct number
    ToolTip(text, 0, 0, currentTooltip)
    
    ; Set timer to remove this specific tooltip
    SetTimer () => ToolTip(,,,currentTooltip), -duration
}

; Function to get the current directory
GetCurrentDirectory() {
    ; Try to get Explorer window path first
    explorerHwnd := WinExist("A")
    if (WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass")) {
        try {
            for window in ComObject("Shell.Application").Windows {
                try {
                    if (window.HWND = explorerHwnd) {
                        return window.Document.Folder.Self.Path
                    }
                }
            }
        } catch as err {
            return { error: "Failed to get Explorer path: " . err.Message }
        }
    }
    
    ; If not Explorer, try to get from Command Prompt or PowerShell
    if (WinActive("ahk_class ConsoleWindowClass") || WinActive("ahk_exe powershell.exe") || WinActive("ahk_exe WindowsTerminal.exe")) {
        try {
            ; Send CD command and retrieve output
            prevClipboard := A_Clipboard
            A_Clipboard := ""  ; Clear clipboard
            Send "cd{Enter}"  ; Send CD command
            Sleep 100  ; Wait a bit longer
            Send "^c"  ; Copy current directory
            if !ClipWait(2) {  ; Wait up to 2 seconds for clipboard
                throw Error("Clipboard timeout")
            }
            currentDir := Trim(A_Clipboard, "`r`n")  ; Remove newlines
            A_Clipboard := prevClipboard  ; Restore clipboard
            return currentDir
        } catch as err {
            return { error: "Failed to get Terminal path: " . err.Message }
        }
    }
    
    ; If nothing else works, return current working directory
    return A_WorkingDir
}

; Layer 1 (Default) mappings - all alphabet characters stay the same
#HotIf currentLayer = 1
q::Send "q"
+q::Send "Q"
w::Send "w"
+w::Send "W"
e::Send "e"
+e::Send "E"
r::Send "r"
+r::Send "R"
t::Send "t"
+t::Send "T"
z::Send "z"
+z::Send "Z"
u::Send "u"
+u::Send "U"
i::Send "i"
+i::Send "I"
o::Send "o"
+o::Send "O"
p::Send "p"
+p::Send "P"
ü::Send "ü"
+ü::Send "Ü"
a::Send "a"
+a::Send "A"
s::Send "s"
+s::Send "S"
d::Send "d"
+d::Send "D"
f::Send "f"
+f::Send "F"
g::Send "g"
+g::Send "G"
h::Send "h"
+h::Send "H"
j::Send "j"
+j::Send "J"
k::Send "k"
+k::Send "K"
l::Send "l"
+l::Send "L"
ö::Send "ö"
+ö::Send "Ö"
ä::Send "ä"
+ä::Send "Ä"
<::Send "<"
+<::Send ">"
y::Send "y"
+y::Send "Y"
x::Send "x"
+x::Send "X"
c::Send "c"
+c::Send "C"
v::Send "v"
+v::Send "V"
b::Send "b"
+b::Send "B"
n::Send "n"
+n::Send "N"
m::Send "m"
+m::Send "M"
,::Send ","
+,::Send ";"
.::Send "."
+.::Send ":"
-::Send "-"
+-::Send "_"

; Layer 2 (Programming Symbols) mappings
#HotIf currentLayer = 2
; Added command list tooltip for 1
1:: {
    ShowTooltip("Available Commands:`n2: CreateGithubRepo")
}

; Added CreateGithubRepo.ps1 execution for 2 with current directory
; Added CreateGithubRepo.ps1 execution for 2 with current directory
; Added CreateGithubRepo.ps1 execution for 2 with current directory
2:: {
    try {
        currentDir := GetCurrentDirectory()
        
        ; Check if we got an error object
        if (Type(currentDir) = "Object" && HasProp(currentDir, "error")) {
            throw Error(currentDir.error)
        }
        
        if !currentDir {
            throw Error("Could not determine current directory")
        }
        
        ; Check if the script exists
        scriptPath := A_ScriptDir "\CreateGithubRepo.ps1"
        if !FileExist(scriptPath) {
            throw Error("CreateGithubRepo.ps1 not found at: " scriptPath)
        }
        
        ; Get the directory name to use as repo name
        repoName := SubStr(currentDir, InStr(currentDir, "\", , -1) + 1)
        
        ; Show initial message
        ShowTooltip("Creating Github repo in: " currentDir "`nRepo name: " repoName "`nPlease wait...")
        
        ; Run the script without hiding the window and pass the repo name
        command := Format('powershell.exe -NoExit -ExecutionPolicy Bypass -File "{1}" -Path "{2}" -RepoName "{3}"', scriptPath, currentDir, repoName)
        RunWait(command)
        
        ; Show completion message
        ShowTooltip("Github repo creation completed for:`n" repoName "`nin directory:`n" currentDir)
        
    } catch as err {
        ; Show error in tooltip for 10 seconds
        ShowTooltip("Error creating Github repo:`n" err.Message "`n`nDirectory: " currentDir)
    }
}
q::Send "1"
+q::Send "!"
w::Send "2"
+w::Send "`""
e::Send "3"
+e::Send "§"
r::Send "4"
+r::Send "$"
t::Send "5"
+t::Send "%"
z::Send "6"
+z::Send "&"
u::Send "7"
+u::Send "/"
i::Send "8"
+i::Send "("
o::Send "9"
+o::Send ")"
p::Send "0"
+p::Send "="
ü::Send "ß"
+ü::Send "?"
a::Send "@"
+a::Send "~"
s::Send "{#}"
+s::Send "'"
d::Send "$"
+d::Send "``"
f::Send "%"
+f::Send "^"
g::Send "&"
+g::Send "{F1}"
h::Send "{Left}"
+h::Send "{F2}"
; Modifier combinations for navigation keys
!h::Send "{Alt down}{Left}{Alt up}"
!j::Send "{Alt down}{Down}{Alt up}"
!k::Send "{Alt down}{Up}{Alt up}"
!l::Send "{Alt down}{Right}{Alt up}"
j::Send "{Down}"
+j::Send "{F3}"
k::Send "{Up}"
+k::Send "{F4}"
l::Send "{Right}"
+l::Send "{F5}"
ö::Send ";"
+ö::Send "{F6}"
ä::Send ":"
+ä::Send "{F7}"
<::Send "<"
+<::Send ">"
y::Send "/"
+y::Send "{{}}"
x::Send "?"
+x::Send "{}}"
c::Send "{[}"
+c::Send "{]}"
v::Send "{]}"
+v::Send "{]}"
b::SendText "{"
+b::SendText "{"
n::SendText "}"
+n::SendText "}"
m::Send "|"
+m::Send "\"
,::Send "("  
+,::Send "<"
.::Send ")"
+.::Send ">"
-::Send "-"
+-::Send "_"
#HotIf