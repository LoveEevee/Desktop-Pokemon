checkprocess(){
	global thispid,a_args
	winget anotherpid,pid,Desktop Pokemon ahk_class AutoHotkeyGUI
	if(anotherpid&&thispid!=anotherpid){
		loop % a_args.length(){
			if(a_index=1){
				allargs:=a_args[1]
			}else{
				allargs:=allargs "`n" a_args[a_index]
			}
		}
		varsetcapacity(data,a_ptrsize*3,0)
		numput(strlen(allargs)*2+2,data,a_ptrsize)
		numput(&allargs,data,a_ptrsize*2)
		sendmessage 74,0,% &data,,ahk_pid %anotherpid%
		exitapp
	}
}

addpokemon(wparam:=0,lparam:=0,msg:=0,hwnd:=0){
	critical
	if(wparam!=t("add_pokemon")){
		pokemonargs(strsplit(strget(numget(lparam+a_ptrsize*2)),"`n"),1)
		return 1
	}
	newpokemon(,1)
}