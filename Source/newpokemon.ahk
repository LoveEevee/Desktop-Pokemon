newpokemon(args:=0,force:=0){
	global id,allpokemon,defaultpokemon,pokemonmenu,defaultmenu,modenames,speedmenu,maxwindows,zoomdefault,speeddefault
	if(allpokemon.length()>=maxwindows){
		return
	}
	a:={}
	allpokemon.push(a)
	a.id:="pokemon" id
	id++
	a.pokemon:=defaultpokemon.clone()
	a.pokemonmenu:=pokemonmenu.clone()
	a.zoomcurrent:=zoomdefault
	a.speed:=speeddefault
	a.mode:=modenames[1]
	parseargs(a,args)
	allpngs:={}
	loop files,%a_scriptdir%\*.png
	{
		loop % modenames.length(){
			modename:=modenames[a_index]
			if(substr(a_loopfilename,1,strlen(modename))=modename){
				if(!allpngs[modename]){
					allpngs[modename]:=[]
				}
				allpngs[modename].push(a_loopfilename)
				break
			}
		}
	}
	loop % modenames.length(){
		i:=modenames.length()-a_index+1
		modename:=modenames[i]
		if(allpngs[modename]){
			thismode:=allpngs[modename]
			loop % thismode.length(){
				j:=thismode.length()-a_index+1
				a.pokemon[thismode[j]]
					:={name:thismode[j]
					,mode:modenames[i]
					,id:thismode[j]
					,custom:1}
				a.pokemonmenu.insertat(1,thismode[j])
			}
		}
	}
	loop % a.filename.length(){
		thisfile:=a.filename[a_index]
		if(fileexist(thisfile)){
			shortname:=regexreplace(thisfile,".*[\\/]","")
			a.pokemon[shortname]
				:={name:shortname
				,mode:a.mode
				,id:thisfile
				,custom:1}
			a.pokemonmenu.insertat(1,shortname)
		}
	}
	contextmenu(a)
	if(a.loadnum){
		if(a.loadnum="random"){
			num:=a.pokemonmenu[random(1,a.pokemonmenu.length())]
		}else{
			num:=a.pokemon[a.loadnum].id
		}
		appearance(,,,a,a.pokemon[num],1)
	}else{
		appearance(,,,a,a.pokemon[defaultmenu[random(1,defaultmenu.length())]],1)
	}
	config(a,1)
	a.timer:=a_tickcount
	if(!force){
		checkprocess()
	}
	aid:=a.id
	gui %aid%:show,% "na x" a.winx " y" a.winy " w" a.winwidth " h" a.winheight,Desktop Pokemon
	setspeed(,,,a)
}