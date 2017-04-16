updatesize(byref a,winx,winy){
	if(winx){
		a.winx:=winx
	}else{
		a.winx:=0
	}
	if(winy){
		a.winy:=winy
	}else{
		a.winy:=0
	}
}

close(wparam){
	if(wparam=61536){
		return 1
	}
}

drag(){
	if(getcurrent(a)){
		a.dragging:=1
		postmessage 161,2
		keywait lbutton
		wingetpos winx,winy,,,% "ahk_id " a.hwnd
		updatesize(a,winx,winy)
		a.dragging:=0
		a.headrunn:=1
	}
}