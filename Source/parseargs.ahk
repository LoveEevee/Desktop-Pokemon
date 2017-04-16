parseargs(byref a,args){
	global speedmenu,modenames,zoomnames
	a.filename:=[]
	if(!args){
		args:=[]
	}
	skipnext:=0
	skipnum:=0
	skipsize:=0
	loop % args.length(){
		if(skipnext){
			skipnext:=0
			continue
		}
		arg:=strlower(args[a_index])
		nextarg:=strlower(args[a_index+1])
		firstsymbol:=substr(arg,1,1)
		if(firstsymbol="/"||firstsymbol="-"){
			argname:=substr(arg,2)
			if(argname="sit"){
				a.sitstate:=1
			}else if(argname="speed"){
				loop % speedmenu.length(){
					thismenu:=t(speedmenu[a_index][1])
					if(strlower(strreplace(thismenu,"&"))=nextarg){
						a.speed:=a_index
						break
					}
				}
				skipnext:=1
			}else if(argname="mode"){
				loop % modenames.length(){
					if(modenames[a_index]=nextarg){
						a.mode:=nextarg
						break
					}
				}
				skipnext:=1
			}else if(argname="fork"){
				skipnext:=1
			}
		}else{
			if(arg="random"||a.pokemon[arg]){
				if(!skipnum){
					a.loadnum:=arg
					skipnum:=1
				}
			}else if(zoomnames[arg]){
				if(!skipsize){
					a.zoomcurrent:=zoomnames[arg]
					skipsize:=1
				}
			}else{
				a.filename.push(args[a_index])
			}
		}
	}
}

pokemonargs(args,force:=0){
	global zoomnames,maxwindows
	forkcount:=0
	randomize:=1
	skipnext:=0
	loop % args.length(){
		if(skipnext){
			skipnext:=0
			continue
		}
		arg:=strlower(args[a_index])
		firstsymbol:=substr(arg,1,1)
		if(firstsymbol="/"||firstsymbol="-"){
			argname:=substr(arg,2)
			if(argname="fork"){
				nextarg:=floor(args[a_index+1])
				if(nextarg>=1&&nextarg<=maxwindows){
					forkcount:=nextarg
				}
				skipnext:=1
			}else if(argname="speed"||argname="mode"){
				skipnext:=1
			}else if(argname!="sit"){
				randomize:=0
			}
		}else if(randomize&&zoomnames[arg]){
			randomize:=2
		}else{
			randomize:=0
		}
	}
	if(forkcount){
		loop % forkcount{
			if(randomize){
				nargs:=args.clone()
				nargs.insertat(1,"random")
				newpokemon(nargs,force)
			}else{
				newpokemon(args,force)
			}
		}
	}else{
		newpokemon(args,force)
	}
}