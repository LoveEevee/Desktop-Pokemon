winget(byref outvar,cmd,wintitle){
	outvar:=winget%cmd%(wintitle)
}
ifmsgbox(a){
}
setbatchlines(a){
}
strlower(input){
	return format("{:l}",input)
}
random(min,max){
	random out,%min%,%max%
	return out
}