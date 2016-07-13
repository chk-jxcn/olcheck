ck=require "checkcard"
require "lfs"
split = require "split"
bp=require "BP"


fo = io.open("out.txt", "w+")
for x in lfs.dir(arg[1]) do 
	if string.find(x, "gif", 1, true)then
		print(x)
		f = io.open(arg[1] .. "\\" .. x,"rb")
		b = f:read("*a")
		i = prepraseImg(b)
		fo:write(x.. "    ")
		_, aa = split.splitImg(i)
		fo:write(table.maxn(_) .. "\n")
		if table.maxn(_) ~= 5 then
			for _, chaa in ipairs(aa) do
				fo:write(chaa)
			end
		fo:write(bp.printImg(i))
		end
		

		f:close()
	end
end
