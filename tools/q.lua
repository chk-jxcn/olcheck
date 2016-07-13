ck=require "checkcard"

f=io.open("sample.gif","rb")
y=f:read("*a")


i=prepraseImg(y)

bp=require("BP")

