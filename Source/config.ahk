config(byref a,initial:=0){
	global initialpos
	if(a.changezoom=1){
		if(a.zoomcurrent<a.zoommodes.length()){
			a.changewinx:=(a.winwidth-a.defwidth*a.zoommodes[a.zoomcurrent+1])/2
			a.changewiny:=(a.winheight-a.defheight*a.zoommodes[a.zoomcurrent+1])/2
			a.zoomcurrent++
		}
		
	}else if(a.changezoom=-1){
		if(a.zoomcurrent>1){
			a.changewinx:=(a.winwidth-a.defwidth*a.zoommodes[a.zoomcurrent-1])/2
			a.changewiny:=(a.winheight-a.defheight*a.zoommodes[a.zoomcurrent-1])/2
			a.zoomcurrent--
		}
	}
	a.changezoom:=0
	a.updateconfig:=0
	a.zoommodes:=[1,1.5,2,2.5,3,4,5,6]
	a.zoom:=a.zoommodes[a.zoomcurrent]
	#include ..\Build\allmodes.ahk
	a.wzoom:=a.zoommodes[a.zoomcurrent]
	a.winwidth:=a.defwidth*a.wzoom
	a.winheight:=a.defheight*a.wzoom
	aid:=a.id
	if(initial){
		a.winx:=random(initialpos[4],a_screenwidth-a.winwidth-initialpos[2])
		a.winy:=random(initialpos[1],a_screenheight-a.winheight-initialpos[3])
		a.tick:=0
		a.headn:=1
		a.headrunn:=0
		a.headtilt:=0
		a.bodyn:=1
		a.leftearn:=4
		a.leftearrunn:=0
		a.lefteardir:=1
		a.rightearn:=4
		a.rightearrunn:=0
		a.lefteardir:=1
		a.legsn:=1
		a.legsrunn:=0
		a.legscamrun:=[-1,-1,-1,1,1,1]
		a.legscontinue:=0
		a.jumpcamrun:=[-1,-1,1,1]
		a.legsjumpn:=0
		a.tailn:=4
		a.tailrunn:=0
		a.rundir:=0
	}else{
		gdip_deletegraphics(a.gbitmap)
		gdip_disposeimage(a.pbitmap)
		selectobject(a.hdc,a.obm)
		deleteobject(a.hbm)
		deletedc(a.hdc)
		gdip_deletegraphics(a.g)
		gui %aid%:destroy
	}
	gui %aid%:-caption +e524288 +e128 +owndialogs +owner +alwaysontop +hwndhwnd1 -dpiscale
	a.hwnd:=hwnd1
	if(initial!=1){
		try{
			gui %aid%:show,% "x" a.winx " y" a.winy " w" a.winwidth " h" a.winheight,Desktop Pokemon
		}catch{
			config(a,2)
			return
		}
	}
	a.hbm:=createdibsection(a.winwidth,a.winheight)
	a.hdc:=createcompatibledc()
	a.obm:=selectobject(a.hdc,a.hbm)
	a.g:=gdip_graphicsfromhdc(a.hdc)
	gdip_setinterpolationmode(a.g,7)
	a.pbitmap:=gdip_createbitmap(a.defwidth*a.zoomdrawn[a.zoomcurrent],a.defheight*a.zoomdrawn[a.zoomcurrent])
	a.gbitmap:=gdip_graphicsfromimage(a.pbitmap)
	gdip_setinterpolationmode(a.gbitmap,5)
	if(a.flipped){
		gdip_scaleworldtransform(a.g,-1,1)
		gdip_translateworldtransform(a.g,-a.winwidth,0)
	}
	if(a.zoomcurrent=a.zoommodes.length()){
		menu tray%aid%,disable,% t("size_larger")
	}else{
		menu tray%aid%,enable,% t("size_larger")
	}
	if(a.zoomcurrent=1){
		menu tray%aid%,disable,% t("size_smaller")
	}else{
		menu tray%aid%,enable,% t("size_smaller")
	}
}