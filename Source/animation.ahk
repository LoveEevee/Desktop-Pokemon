update(){
	global allpokemon
	loop % allpokemon.length(){
		a:=allpokemon[a_index]
		if(a&&a_tickcount-a.speedms>=a.timer){
			animation(a)
		}
	}
}

animation(byref a){
	a.timer:=a_tickcount
	if(a.updateconfig){
		config(a)
	}
	if(winactive("ahk_id " a.hwnd)){
		; Currently animated window is active, check pressed keys
		up:=getkeystate("up")
		right:=getkeystate("right")
		down:=getkeystate("down")
		left:=getkeystate("left")
		space:=getkeystate("space")||getkeystate("enter")
		ctrl:=getkeystate("lctrl")||getkeystate("rctrl")
		justflipped:=0
		if(!getkeystate("lbutton")&&a.dragging){
			; Primary mouse button has been just released
			wingetpos winx,winy,,,% "ahk_id" a.hwnd
			updatesize(a,winx,winy)
			a.dragging:=0
			a.headrunn:=1
			a.running:=0
		}
		if(up&&!a.up){
			; Keyboard Up arrow button pressed
			if(ctrl){
				larger(,,,a)
			}else{
				a.rundir:=-1
			}
		}
		if(right&&!a.right&&!a.flipped){
			; Keyboard Right arrow button pressed
			gdip_scaleworldtransform(a.g,-1,1)
			gdip_translateworldtransform(a.g,-a.winwidth,0)
			a.lastflip:=a.tick
			a.flipped:=1
			justflipped:=1
		}
		if(down&&!a.down){
			; Keyboard Down arrow button pressed
			if(ctrl){
				smaller(,,,a)
			}else{
				a.rundir:=1
			}
		}
		if(left&&!a.left&&a.flipped){
			; Keyboard Left arrow button pressed
			gdip_resetworldtransform(a.g)
			a.lastflip:=a.tick
			a.flipped:=0
			justflipped:=1
		}
		if((a.up||a.down)&&!up&&!down){
			; Up and Down button released
			a.rundir:=0
		}
		if(left||right){
			; Left or Right button pressed
			if(!justflipped){
				; Wait for 1 frame if button was pressed recently
				a.running:=1
				a.manualrun:=1
			}
		}else if(a.left||a.right){
			; Left or Right button released
			a.running:=0
			a.manualrun:=0
			a.lastmanualrun:=a.tick
		}
		if(space&&!a.space){
			; Spacebar button pressed
			a.headrunn:=1
		}
		; Save current button state
		a.up:=up
		a.right:=right
		a.down:=down
		a.left:=left
		a.space:=space
	}else{
		; The window is not active, clear all button states
		a.left:=0
		a.right:=0
		if(a.manualrun){
			a.running:=0
			a.manualrun:=0
			a.lastmanualrun:=a.tick
		}
	}
	; Clear bitmap
	gdip_graphicsclear(a.g)
	gdip_graphicsclear(a.gbitmap)
	; Blinking
	a.eyesopen:=random(0,20)
	if(a.tick>0&&a.dragging){
		; Update internal window position when dragging
		wingetpos winx,winy,,,% "ahk_id " a.hwnd
		updatesize(a,winx,winy)
	}
	; Window is too close to the screen edge to run in that direction
	a.atleftside:=!a.flipped&&a.winx-a.zoom*40<0
	a.atrightside:=a.flipped&&a.winx+a.zoom*40+a.winwidth>a_screenwidth
	if(a.dragging){
		; Reset some animation states when dragging
		a.legscontinue:=0
		a.headrunn:=1
		a.running:=0
		if(a.mode="pikachu"){
			if(a.bodyn>3||a.bodyn=1){
				a.bodyn:=2
			}else{
				a.bodyn:=3
			}
		}else{
			a.bodyn:=1
		}
		a.legsrunn:=0
		a.legsjumpn:=0
		a.tailposn:=0
		a.tailrunn:=0
		a.leftearrunn:=0
		a.rightearrunn:=0
		a.bothearrun:=0
		if(a.mode="eevee"){
			a.legsn:=11
		}else{
			a.legsn:=1
		}
		a.lastflip:=a.tick
		a.lastrun:=a.tick
		a.lasthead:=a.tick
		if(a.mode="pikachu"){
			if(a.eyesopen){
				a.headn:=6
			}else{
				a.headn:=7
			}
		}else{
			if(a.eyesopen){
				a.headn:=3
			}else{
				a.headn:=4
			}
		}
		if(a.leftearn>1){
			a.leftearn--
		}
		if(a.rightearn>1){
			a.rightearn--
		}
		if(a.mode="eevee"){
			a.tailn:=4
		}else if(a.tailn>1){
			a.tailn--
		}
	}else{
		; The window is not being dragged, animate normally
		a.tick++
		if(a.sitstate){
			; "Stop running around" is set, prevent running
			a.running:=0
			a.legsrunn:=0
			a.legsjumpn:=0
			if(a.mode="vulpix"){
				a.bodyn:=2
			}else{
				a.bodyn:=1
			}
		}else if(a.running){
			a.legscontinue:=1
			a.legsjumpn:=1
			if(!a.legsrunn){
				a.legsrunn:=1
			}
			if(!a.manualrun&&(a.atrightside||a.atleftside||!random(0,10))){
				; Determines when to stop running
				a.legscontinue:=0
				a.running:=0
				a.lastrun:=a.tick
			}
		}else{
			firsttickleft:=0
			if(a.tick=1&&a.winx<a_screenwidth//2){
				firsttickleft:=1
			}
			notearly:=0
			if(!a.legsjumpn&&a.lastmanualrun+50<a.tick&&a.lastflip+10<a.tick&&a.lastrun+10<a.tick){
				notearly:=1
			}
			if(firsttickleft||notearly&&((a.atrightside||a.atleftside)&&!random(0,10)||!random(0,100))){
				; Trigger flip animation:
				; At the very beginning if the window is at the left side of the screen
				; The window has not been running or flipping for at least 10 frames
				; The user has not been controlling the window with keyboard keys for at least 50 frames
				; For the above two, the chances increase if the window cannot run in the direction it is currently facing
				if(a.flipped){
					gdip_resetworldtransform(a.g)
				}else{
					gdip_scaleworldtransform(a.g,-1,1)
					gdip_translateworldtransform(a.g,-a.winwidth,0)
				}
				a.flipped:=!a.flipped
				a.lastflip:=a.tick
			}else if(a.lastmanualrun+50<a.tick&&!a.atrightside&&!a.atleftside&&a.lastrun+10<a.tick&&!random(0,50)){
				; Begin running animation starting from next frame:
				; If it has enough space to run in that direction
				; It hasn't ran for at least 10 frames
				; The user has not been controlling the window with keyboard keys for at least 50 frames
				a.running:=1
				if(a.winy-a.zoom*40<0){
					a.rundir:=random(0,1)
				}else if(a.winy+a.zoom*40+a.winheight>a_screenheight){
					a.rundir:=random(-1,0)
				}else{
					a.rundir:=random(-1,1)
				}
			}
		}
		if(a.headrunn){
			; Face animation, activated by clicking on the window or randomly
			; "headrun" array defines animation frames from "head" array
			; "headrunn" is the current iteration, "headn" stores current face for drawing
			a.headn:=a.headrun[a.headrunn]
			; Next frame will use next iteration
			a.headrunn:=mod(a.headrunn+1,a.headrun.length()+1)
		}else{
			; Blink only if face isn't being animated
			if(a.eyesopen){
				a.headn:=1
			}else{
				a.headn:=2
			}
			if(a.lasthead+100<a.tick&&!random(0,200)){
				; Start face animation on next frame:
				; It face hasn't animated for at least 100 frames
				a.headrunn:=1
				a.lasthead:=a.tick
			}
		}
		if(a.legsrunn){
			; Legs animation, anctivated with keyboard Left and Right keys or randomly
			; Logically move window 4 pixels in the current direction
			if(a.flipped){
				a.winx:=a.winx+a.zoom*4
			}else{
				a.winx:=a.winx-a.zoom*4
			}
			; "legscamrun" defines vertical offset for window in the current animation frame
			a.winy:=a.winy+(a.legscamrun[a.legsrunn]+a.rundir)*a.zoom
			; "legsrun" array defines animation frames from "legs" array
			; "legsrunn" is the current iteration, "legsn" stores current legs for drawing
			a.legsn:=a.legsrun[a.legsrunn]
			; Some sprites also modify body when running
			a.bodyn:=a.bodyrun[a.legsrunn]
			a.tailposn:=a.tailposrun[a.legsrunn]
			; Next frame will use next iteration
			a.legsrunn:=mod(a.legsrunn+1,a.legsrun.length()+1)
		}else if(a.legsjumpn){
			; Final stage of legs animation
			if(a.flipped){
				a.winx:=a.winx+a.zoom*4
			}else{
				a.winx:=a.winx-a.zoom*4
			}
			a.winy:=a.winy+(a.jumpcamrun[a.legsjumpn]+a.rundir)*a.zoom
			a.legsn:=a.legsjump[a.legsjumpn]
			a.bodyn:=a.bodyjump[a.legsjumpn]
			a.tailposn:=a.tailposjump[a.legsjumpn]
			a.legsjumpn:=mod(a.legsjumpn+1,a.legsjump.length()+1)
		}else{
			; Window is staying still
			a.legsn:=1
			a.tailposn:=0
			if(a.mode!="pikachu"){
				a.bodyn:=1
			}
		}
		if(a.mode="pikachu"){
			; Pikachu's head tilting animation
			if(a.lasttilt+20<a.tick&&!random(0,50)){
				; Start head tilt animation:
				; It head hasn't tilted for at least 20 frames
				if(a.headtilt>0){
					; If it was already tilted, untilt it
					a.headtilt:=0
				}else{
					; Use random tilt, including the current untilted state
					a.headtilt:=random(0,2)
				}
				a.lasttilt:=a.tick
			}
			if(!a.running&&!a.legsjumpn){
				; Tilt only if window is not running
				if(a.headtilt>0){
					if(a.headn=5){
						a.headn:=1
					}
					if(a.headn=6||a.headn=7){
						a.headn-=3
					}
					a.headn+=a.headtilt*4+3
				}
				; "legs" array for Pikachu is its body with legs
				a.legsn:=a.headtilt+1
				if(a.tailrunn){
					; "body" array for Pikachu is its tail
					a.bodyn:=a.tailrun[a.tailrunn]
					a.tailrunn++
					; Hardcoded value (last tail frame)
					if(a.tailrunn=7){
						a.tailrunn:=0
					}
				}else if(a.bodyn>1){
					a.bodyn--
				}
			}
		}
		if(a.tailrunn){
			; Tail animation
			; "tailrun" array defines animation frames from "tail" array
			; "tailrunn" is the current iteration, "tailn" stores current tail for drawing
			a.tailn:=a.tailrun[a.tailrunn]
			a.tailrunn:=mod(a.tailrunn+1,a.tailrun.length()+1)
			if(a.tailrunn=7&&random(0,10)){
				a.tailrunn:=0
			}
		}else if(a.tailn<3){
			; Hardcoded value (middle tail frame)
			a.tailn++
		}else if(!random(0,10)){
			; Begin tail animation in random direction
			a.tailrunn:=random(0,1)?1:7
		}
		if(!a.leftearrunn&&!a.rightearrunn&&!random(0,100)){
			; Animate left and right ears synchronously
			a.leftearrunn:=7
			a.lefteardir:=1
			a.rightearrunn:=7
			a.righteardir:=1
			a.bothearrun:=1
		}
		if(a.leftearrunn){
			; Animate left ear
			a.leftearn:=a.leftearrun[a.leftearrunn]
			if(!random(0,100)){
				; Stop animation on next frame
				a.leftearrunn:=0
				if(a.bothearrun){
					a.rightearrunn:=0
				}
			}else{
				if(!random(0,5)){
					; Randomly change direction
					a.lefteardir:=random(0,1)?1:-1
					if(a.bothearrun){
						a.righteardir:=a.lefteardir
					}
				}
				a.leftearrunn:=mod(a.leftearrunn+a.lefteardir,a.leftearrun.length()+1)
			}
		}else{
			a.bothearrun:=0
			if(!random(0,100)){
				; Start left ear animation on next frame
				a.leftearrunn:=7
				a.lefteardir:=1
			}else if(a.leftearn<4){
				; Hardcoded value (middle ear frame)
				a.leftearn++
			}else if(a.rightearn>4){
				a.leftearn--
			}
		}
		if(a.rightearrunn){
			; Animate right ear
			a.rightearn:=a.rightearrun[a.rightearrunn]
			if(!a.bothearrun&&!random(0,100)){
				; Stop animation on next frame
				a.rightearrunn:=0
			}else{
				if(!a.bothearrun&&!random(0,5)){
					; Randomly change direction
					a.righteardir:=random(0,1)?1:-1
				}
				a.rightearrunn:=mod(a.rightearrunn+a.righteardir,a.rightearrun.length()+1)
			}
		}else{
			a.bothearrun:=0
			if(!random(0,100)){
				a.rightearrunn:=7
				a.righteardir:=1
			}else if(a.rightearn<4){
				; Hardcoded value (middle ear frame)
				a.rightearn++
			}else if(a.rightearn>4){
				a.rightearn--
			}
		}
	}
	; Draw all body parts onto the bitmap
	; Tail
	drawpart(a,a.tail[a.tailn],0,a.tailposn)
	if(a.mode="pikachu"&&(a.legsrunn||a.legsjumpn)){
		; Draw Pikachu's head on top when standing still
		drawpart(a,a.head[a.headn])
	}
	; Body
	drawpart(a,a.body[a.bodyn])
	; Legs
	drawpart(a,a.legs[a.legsn])
	; Left ear
	drawpart(a,a.leftear[a.leftearn])
	; Head
	if(a.mode!="pikachu"||a.mode="pikachu"&&!a.legsrunn&&!a.legsjumpn){
		drawpart(a,a.head[a.headn])
	}
	; Right ear
	drawpart(a,a.rightear[a.rightearn])
	if(!a.dragging){
		; Offset window horizontal and vertical positions
		; "changewinx" and "changewiny" are set when changing window size (Ctrl+Up or Ctrl+Down)
		if(a.changewinx){
			a.winx:=a.winx+a.changewinx
			a.changewinx:=0
		}
		if(a.changewiny){
			a.winy:=a.winy+a.changewiny
			a.changewiny:=0
		}
		; Snap logical window position at screen edges
		if(a.winx>a_screenwidth-a.winwidth){
			a.winx:=a_screenwidth-a.winwidth
		}
		if(a.winx<0){
			a.winx:=0
		}
		if(a.winy>a_screenheight-a.winheight){
			a.winy:=a_screenheight-a.winheight
		}
		if(a.winy<0){
			a.winy:=0
		}
	}
	; Apply bitmap image onto window's larger bitmap with zoom applied (bicubic)
	gdip_drawimage(a.g,a.pbitmap,0,0,a.winwidth,a.winheight,0,0,a.defwidth*a.zoomdrawn[a.zoomcurrent],a.defheight*a.zoomdrawn[a.zoomcurrent])
	addwiny:=0
	if(a.mode="pikachu"&&(a.legsrunn||a.legsjumpn)){
		; Offset Pikachu window vertically when stating still
		addwiny:=a.zoomdrawn[a.zoomcurrent]*3
	}
	; Move window and update window contents
	updatelayeredwindow(a.hwnd,a.hdc,a.winx,a.winy+addwiny,a.winwidth,a.winheight)
}

drawpart(byref a,coord,x:=0,y:=0){
	zoom:=a.zoomdrawn[a.zoomcurrent]
	pos:=strsplit(coord," ")
	postl:=strsplit(pos[1],"x")
	poswh:=strsplit(pos[2],"x")
	posxy:=strsplit(pos[3],"x")
	; Apply sprite image onto bitmap with zoom applied (nearest neighbor)
	gdip_drawimage(a.gbitmap,a.image,(posxy[1]+x)*zoom,(posxy[2]+y)*zoom,poswh[1]*zoom+zoom,poswh[2]*zoom+zoom,postl[1]-1,postl[2]-1,poswh[1]+1,poswh[2]+1)
}