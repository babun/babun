WinWaitActive , Cygwin Setup, , 100
WinActivate ,Cygwin Setup
SetKeyDelay, 0, 0, Play
ControlSend ,Button2,{Enter}, Cygwin Setup
ControlSend ,,{Up}, Cygwin Setup
ControlSend ,,{Up}, Cygwin Setup
ControlSend ,,{Up}, Cygwin Setup
ControlSend ,Button7,{Enter}, Cygwin Setup
ControlSend ,Button12,{Enter}, Cygwin Setup
ControlSend ,Button14,{Enter}, Cygwin Setup
Sleep, 1
ControlSend ,Button2,{Alt down}i{Alt up}, Cygwin Setup
ControlSend ,Button2,{Esc down}{Esc up}, Cygwin Setup
WinWaitActive , Exit Cygwin Setup?, , 1
WinActivate ,Exit Cygwin Setup?
ControlSend ,,{Enter}, Exit Cygwin Setup?
