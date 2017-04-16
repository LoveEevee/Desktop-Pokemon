gdip_startup(){
dllcall("LoadLibrary",str,"gdiplus")
varsetcapacity(s,a_ptrsize=8?24:16,0)
s:=chr(1)
r:=a_ptrsize=8?"uptr":"uint"
dllcall("gdiplus\GdiplusStartup",a_ptrsize=8?"uptrp":"uintp",t,r,&s,r,0)
return t
}
createdibsection(w,h){
varsetcapacity(i,40,0)
numput(w,i,4,"uint")
numput(h,i,8,"uint")
numput(40,i,0,"uint")
numput(1,i,12,"ushort")
numput(0,i,16,"uint")
numput(32,i,14,"ushort")
c:=getdc()
r:=a_ptrsize=8?"uptr":"uint"
m:=dllcall("CreateDIBSection",r,c,r,&i,uint,0,a_ptrsize=8?"uptrp":"uintp",0,r,0,uint,0,r)
releasedc(c)
return m
}
createcompatibledc(){
return dllcall("CreateCompatibleDC",a_ptrsize=8?"uptr":"uint",0)
}
selectobject(c,m){
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("SelectObject",r,c,r,m)
}
gdip_graphicsfromhdc(c){
dllcall("gdiplus\GdipCreateFromHDC",a_ptrsize=8?"uptr":"uint",c,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
gdip_setinterpolationmode(g,m){
dllcall("gdiplus\GdipSetInterpolationMode",a_ptrsize=8?"uptr":"uint",g,int,m)
}
gdip_createbitmapfromfile(f){
if(a_isunicode){
dllcall("gdiplus\GdipCreateBitmapFromFile",uint,&f,uintp,p)
}else{
varsetcapacity(w,1023)
dllcall("kernel32\MultiByteToWideChar",uint,0,uint,0,uint,&f,int,-1,uint,&w,int,512)
dllcall("gdiplus\GdipCreateBitmapFromFile",uint,&w,uintp,p)
}
return p
}
gdip_graphicsclear(g){
dllcall("gdiplus\GdipGraphicsClear",a_ptrsize=8?"uptr":"uint",g,int,16777215)
}
gdip_resetworldtransform(g){
dllcall("gdiplus\GdipResetWorldTransform",a_ptrsize=8?"uptr":"uint",g)
}
gdip_scaleworldtransform(g,x,y){
dllcall("gdiplus\GdipScaleWorldTransform",a_ptrsize=8?"uptr":"uint",g,float,x,float,y,int,0)
}
gdip_translateworldtransform(g,x,y){
dllcall("gdiplus\GdipTranslateWorldTransform",a_ptrsize=8?"uptr":"uint",g,float,x,float,y,int,0)
}
updatelayeredwindow(d,c,x,y,w,h){
varsetcapacity(t,8)
numput(x,t,0,"uint")
numput(y,t,4,"uint")
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("UpdateLayeredWindow",r,d,r,0,r,&t,int64p,w|h<<32,r,c,int64p,0,uint,0,uintp,33488896,uint,2)
}
gdip_drawimage(x,y,a,b,c,d,e,f,g,h){
r:=a_ptrsize=8?"uptr":"uint"
return dllcall("gdiplus\GdipDrawImageRectRect",r,x,r,y,float,a,float,b,float,c,float,d,float,e,float,f,float,g,float,h,int,2,r,0,r,0,r,0)
}
gdip_disposeimage(p){
dllcall("gdiplus\GdipDisposeImage",a_ptrsize=8?"uptr":"uint",p)
}
deleteobject(o){
dllcall("DeleteObject",a_ptrsize=8?"uptr":"uint",o)
}
deletedc(h){
dllcall("DeleteDC",a_ptrsize=8?"uptr":"uint",h)
}
gdip_deletegraphics(p){
dllcall("gdiplus\GdipDeleteGraphics",a_ptrsize=8?"uptr":"uint",p)
}
gdip_graphicsfromimage(b){
dllcall("gdiplus\GdipGetImageGraphicsContext",a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
gdip_createhiconfrombitmap(b){
dllcall("gdiplus\GdipCreateHICONFromBitmap",a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",g)
return g
}
destroyicon(i){
dllcall("DestroyIcon",a_ptrsize=8?"uptr":"uint",i)
}
gdip_createbitmap(w,h){
dllcall("gdiplus\GdipCreateBitmapFromScan0",int,w,int,h,int,0,int,2498570,a_ptrsize=8?"uptr":"uint",0,a_ptrsize=8?"uptrp":"uintp",b)
return b
}
getdc(){
return dllcall("GetDC",a_ptrsize=8?"uptr":"uint",0)
}
releasedc(c){
r:=a_ptrsize=8?"uptr":"uint"
dllcall("ReleaseDC",r,0,r,c)
}
gdip_getimagewidth(b){
dllcall("gdiplus\GdipGetImageWidth",a_ptrsize=8?"uptr":"uint",b,uintp,w)
return w
}
gdip_getimageheight(b){
dllcall("gdiplus\GdipGetImageHeight",a_ptrsize=8?"uptr":"uint",b,uintp,h)
return h
}
gdip_getimagedimensions(b,byref w, byref h){
p:=a_ptrsize=8?"uptr":"uint"
dllcall("gdiplus\GdipGetImageWidth",p,b,uintp,w)
dllcall("gdiplus\GdipGetImageHeight",p,b,uintp,h)
}
gdip_clonebitmaparea(b,x,y,w,h){
dllcall("gdiplus\GdipCloneBitmapArea",float,x,float,y,float,w,float,h,int,2498570,a_ptrsize=8?"uptr":"uint",b,a_ptrsize=8?"uptrp":"uintp",d)
return d
}