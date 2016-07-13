require "lfs"
ck = require "checkcard"
bp = require "BP"

fo = io.open("out.txt", "w+")
for x in lfs.dir(arg[1]) do 
	if string.find(x, "gif", 1, true)then
		print(x)
		f = io.open(arg[1] .. "\\" .. x,"rb")
		b = f:read("*a")
		i = prepraseImg(b)
		fo:write(x .. "\n")
		fo:write(bp.printImg(i))
		f:close()
	end
end
