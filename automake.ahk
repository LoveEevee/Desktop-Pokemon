#notrayicon
#include Libs\json.ahk
#singleinstance
setworkingdir %a_scriptdir%
menu,tray,icon,Images/eevee.ico
q:=chr(34)

; Find Ahk2Exe.exe
if(a_ahkdir){
	ahkinstall:=a_ahkdir
}else{
	regread ahkinstall,HKLM\Software\Autohotkey,InstallDir
}
if(ahkinstall&&fileexist(ahkinstall)){
	startpath:=ahkinstall
	if(fileexist(ahkinstall "\Compiler\Ahk2Exe.exe")){
		ahk2exe:=ahkinstall "\Compiler\Ahk2Exe.exe"
		startpath:=ahk2exe
	}
}
if(!ahk2exe){
	regread ahk2execommand,HKCR\AutoHotkeyScript\Shell\Compile\Command
	ahk2execommand:=regexreplace(ahk2execommand,"^" q "|" q ".*$")
	if(fileexist(ahk2execommand)){
		ahk2exe:=ahk2execommand
		startpath:=ahk2exe
	}
}
if(!ahk2exe){
	ahk2exe:=a_programfiles "\AutoHotkey\Compiler\Ahk2Exe.exe"
}
if(!startpath){
	startpath:=a_programfiles
}
regread lastbinfile,HKCU\Software\AutoHotkey\Ahk2Exe,LastBinFile
splitpath % ahk2exe,,ahk2exepath

; GUI
gui -minimizebox
gui margin,20,20
gui add,text,xm ym,Path to Ahk2Exe.exe
gui add,edit,xm+120 yp w315 vfilefield +disabled,%ahk2exe%
gui add,button,x+5 yp hp vbtnfile gselectfile,Browse
gui add,text,xm,Base File (.bin)
gui add,ddl,xm+120 yp w315 h23 r10 altsubmit vbinfile +disabled choose1,(None)
gui add,button,xm w485 hp+10 vbtncompile gcompileahk,Compile
gui show,,Desktop Pokemon
guicontrol focus,btncompile
buildbinfilelist()
compileahk()
return

buildbinfilelist(){
	global
	gui submit,nohide
	binfiles:=[""]
	binfilenames:=[""]
	binnames:=["Please Select"]
	thisbinfile:=""
	if(lastbinfile=""||!fileexist(ahk2exepath "\" lastbinfile)){
		thisbinfile:="autohotkeysc.bin"
	}else{
		thisbinfile:=strlower(lastbinfile)
	}
	choose:=1
	loop files,%ahk2exepath%\*.bin,f
	{
		splitpath % a_loopfilefullpath,nameext,,,name
		filegetversion version,% a_loopfilefullpath
		if(strlower(name)="autohotkeysc"){
			binfiles[1]:=a_loopfilefullpath
			binfilenames[1]:=nameext
			binnames[1]:="v" version " (Default)"
			num:=1
		}else{
			binfiles.push(a_loopfilefullpath)
			binfilenames.push(nameext)
			binnames.push("v" version " " name)
			num:=0
		}
		if(strlower(nameext)=thisbinfile){
			if(num){
				choose:=1
			}else{
				choose:=binfiles.length()
			}
		}
	}
	if(binfiles.length()=1&&!binfiles[1]){
		binnames[1]:="(None)"
		guicontrol disable,binfile
	}else{
		guicontrol enable,binfile
	}
	strbinnames:=""
	loop % binnames.length(){
		strbinnames.="|" binnames[a_index]
	}
	guicontrol,,binfile,% strbinnames
	guicontrol,choose,binfile,% choose
}

selectfile(){
	global
	gui +owndialogs
	fileselectfile filefield,1,%startpath%,Select Ahk2Exe.exe,Application (*.exe)
	if(errorlevel){
		return
	}
	startpath:=filefield
	guicontrol,,filefield,%filefield%
	splitpath %filefield%,,ahk2exepath
	buildbinfilelist()
}

fileselectfile(a,b,c,d,e){
	f:="f"
	%f%ileselect(a,b,c,d,e)
}

filecreatedir(input){
	d:="d"
	%d%ircreate(input)
}

strlower(input){
	return format("{:l}",input)
}

compileahk(){
	global
	gui submit,nohide
	gui +owndialogs
	if(!fileexist(filefield)){
		msgbox Ahk2Exe.exe wasn't found!
		return
	}
	gui hide
	
	filecreatedir Build
	images:=[]
	
	; initial.ahk
	fileread pokemonjson,Config\pokemon.json
	pokemon:=json.load(pokemonjson)
	text:="initial(){`n`global`n"
	initialconfig:=[]
	loop % pokemon.initialconfig.length(){
		cfg:=pokemon.initialconfig[a_index]
		newcfg:={name:cfg.name,id:cfg.id,mode:cfg.mode}
		if(cfg.more){
			newcfg.more:=1
		}
		initialconfig.push(newcfg)
		images.push({id:cfg.id,file:cfg.file})
	}
	text.="initialconfig:=" json.dump(initialconfig) "`n"
	pokemonignore:={"initialconfig":1,"modesettings":1}
	for name,value in pokemon{
		if(!pokemonignore[name]){
			text.=name ":=" json.dump(value) "`n"
		}
	}
	fileread strings,Config\strings.json
	text.="tstrings:=" json.dump(json.load(strings)) "`n}"
	writefile("Build\initial.ahk",text)
	
	; allmodes.ahk
	loop % pokemon.modenames.length(){
		mode:=sanitize(pokemon.modenames[a_index])
		if(a_index=1){
			text:=""
		}else{
			text.="}else "
		}
		text.="if(a.mode=" q mode q "){`n"
		text.="#include ..\Build\cfg-" mode ".ahk`n"
	}
	text.="}"
	writefile("Build\allmodes.ahk",text)
	
	; sprites.ahk
	; spr-*.ahk
	loop % images.length(){
		id:=sanitize(images[a_index].id)
		if(a_index=1){
			text:="getpng(byref i,id){`n"
		}else{
			text.="}else "
		}
		text.="if(id=" q id q "){`n"
		text.="#include ..\Build\spr-" id ".ahk`n"
		imgencode(images[a_index].file,"Build\spr-" id ".ahk")
	}
	text.="}`n}"
	writefile("Build\sprites.ahk",text)
	
	; cfg-*.ahk
	for modename,file in pokemon.modesettings{
		fileread jsontext,% file
		jsonobj:=json.load(jsontext)
		text:=""
		for name,value in jsonobj{
			if(name="defwidth"&&value=-1){
				text.="a.defwidth:=gdip_getimagewidth(a.eevee)`n"
			}else if(name="defheight"&&value=-1){
				text.="a.defheight:=gdip_getimageheight(a.eevee)`n"
			}else if(name="head"&&value=-1){
				text.="a.allheads:=" q "0x0 " q " a.defwidth " q "x" q " a.defheight " q " 0x0" q "`n"
				text.="a.head:=[a.allheads,a.allheads,a.allheads,a.allheads,a.allheads]`n"
			}else if(name="zoommodes"){
				loop % value.length(){
					if(a_index=1){
						text.="a.zoommodes:=["
					}else{
						text.=","
					}
					text.=format("{1:.3g}",value[a_index])
				}
				text.="]`n"
			}else{
				text.="a." sanitize(name) ":=" json.dump(value) "`n"
			}
		}
		writefile("Build\cfg-" modename ".ahk",text)
	}
	
	; Compile
	if(binfiles[binfile]){
		regwrite reg_sz,HKCU\Software\AutoHotkey\Ahk2Exe,LastBinFile,% binfilenames[binfile]
		bin:="/bin " q binfiles[binfile] q
	}else{
		bin:=""
	}
	run "%filefield%" /in Source\main.ahk /out eevee.exe /icon Images\eevee.ico %bin%
	
	exitapp
}

guiclose(){
	exitapp
}

writefile(filename,byref text){
	file:=fileopen(filename,"w","utf-8")
	file.write(text)
	file.close()
}

sanitize(input){
	return regexreplace(input,"[^\w]")
}

imgencode(imgfile,outfile){
	global q
	file:=fileopen(imgfile,"r")
	binlen:=file.length
	file.rawread(bin,binlen)
	file.close()
	; Encode the image file
	dllcall("Crypt32\CryptBinaryToString",ptr,&bin,uint,binlen,uint,1,ptr,0,uintp,b64len)
	varsetcapacity(b64,b64len<<a_isunicode,0)
	dllcall("Crypt32\CryptBinaryToString",ptr,&bin,uint,binlen,uint,1,ptr,&b64,uintp,b64len)
	bin:=""
	varsetcapacity(bin,0)
	varsetcapacity(b64,-1)
	b64:=strreplace(b64,"`r`n")
	b64len:=strlen(b64)
	; Write the ahk script
	partlength:=16000
	charsread:=1
	file:=fileopen(outfile,"w","utf-8")
	part:="i:=" q
	while(charsread<b64len){
		file.write(part substr(b64,charsread,partlength) q)
		charsread+=partlength
		if(charsread<b64len){
			part:="`ni.=" q
		}
	}
	file.close()
}
