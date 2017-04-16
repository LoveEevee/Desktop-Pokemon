#notrayicon
#singleinstance off
#maxhotkeysperinterval 99000000
#hotkeyinterval 99000000
#keyhistory 0
listlines off
setbatchlines -1
setwindelay -1

initial()
defaultpokemon:={}
pokemonmenu:=[]
defaultmenu:=[]
loop % initialconfig.length(){
	thismenu:=initialconfig[a_index]
	defaultpokemon[thismenu.id]:=thismenu
	pokemonmenu.push(thismenu.id)
	if(!thismenu.more){
		defaultmenu.push(thismenu.id)
	}
}
for name,dest in aliases{
	defaultpokemon[name]:=defaultpokemon[dest]
}
gdip_startup()
id:=0
if(!a_args){
	a_args:=[]
	loop %0%{
		a_args.push(%a_index%)
	}
}
allpokemon:=[]
loadedimg:={}
thispid:=dllcall("GetCurrentProcessId")
checkprocess()
pokemonargs(a_args)
onmessage(513,"drag")
onmessage(274,"close")
onmessage(123,"menu")
onmessage(74,"addpokemon")
settimer update,50

return

#include ..\Build\initial.ahk
#include newpokemon.ahk
#include animation.ahk
#include config.ahk

#include parseargs.ahk
#include windowevent.ahk
#include contextmenu.ahk
#include singleprocess.ahk

#include loadimage.ahk
#include compatibility.ahk
#include ..\Libs\gdip.ahk