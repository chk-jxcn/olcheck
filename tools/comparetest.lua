io = require "io"
statis =require "statis"
ck=require "checkcard"
split = require "split"
bp=require "BP"
require "lfs"

statis.trainning()

fo = io.open("compareout.txt", "w+")
percent = {dw = 0, dv = 0}
amount = 0
splitfail = 0
for x in lfs.dir(arg[1]) do 
	if string.find(x, "gif", 1, true)then
		print(x)
		f = io.open(arg[1] .. "\\" .. x,"rb")
		b = f:read("*a")
		i = prepraseImg(b)
		fo:write(x.. "    ")
		_, aa = split.splitImg(i)
		fo:write(table.maxn(_))
		fo:write(printImg(i))
		if table.maxn(_) == 5 then
			local chpoint = 1
			for __, cht in ipairs(_) do
				local re = statis.compare(cht)
				local t = {}
				local chdw = {c=-1,v=10000}
				local chdv = {c=-1, v=10000}
				for ch, wv in pairs(re) do
					table.insert(t, {c=ch, wv={dw=wv.dw, dv=wv.dv}})	-- t[1] = {c = "0", wv = {dw, dv}}
					if wv.dw < chdw.v then 
						chdw.v = wv.dw
						chdw.c = ch
					end
					if wv.dv < chdv.v then 
						chdv.v = wv.dv
						chdv.c = ch
					end
				end
				fo:write("\ndw:" .. chdw.c .. " dv:" .. chdv.c .."  ")
				function c(e1,e2) return e1.c:byte(1) < e2.c:byte(1) end
				table.sort(t, c)
				fo:write("实际值: " ..  string.upper(string.char(x:byte(chpoint))) .. "\n")

				local s = "    "
				for ch,_ in  ipairs(t) do
					s = s .. _.c .. " "
				end
				
				s = s .. "\ndw: "
				for ch,_ in  ipairs(t) do
					if chdw.c == _.c then 
						s = s .. "^ "
					else
						s = s .. "  "
					end
				end
				amount = amount + 1 
				if chdw.c == string.sub(x, chpoint, chpoint) then
					s = s .. "\t字符权重匹配成功"
					percent.dw = percent.dw + 1
				else
					s = s .. "\t\t\t<--------字符权重匹配失败"
				end



				s = s .. "\ndv: "
				for ch,_ in  ipairs(t) do
					if chdv.c == _.c then 
						s = s .. "^ "
					else
						s = s .. "  "
					end
				end

				if chdv.c == string.sub(x, chpoint, chpoint) then
					s = s .. "\t字符方差匹配成功"
					percent.dv = percent.dv + 1
				else
					s = s .. "\t\t\t<--------字符方差匹配失败"
				end

				fo:write(s .. "\n")

				-------------------------------------------------------------------

				local s = ""
				for ch,_ in  ipairs(t) do
					s = s .. _.c .. "\t"
				end
				
				s = s .."\n"

				for ch,_ in  ipairs(t) do
					s = s .. string.format("%-7.1f\t", _.wv.dw)
				end
				
				s = s .. "\n"

				for ch,_ in  ipairs(t) do
					s = s .. string.format("%-7.1f\t", _.wv.dv)
				end

				fo:write(s .. "\n")
				-------------------------------------------------------------------	
				chpoint = chpoint + 1

			end
			-- fo:write(bp.printImg(i))
		else
			fo:write("\t\t\t\t\t\t\t<--------图像分割失败\n\n")
			splitfail = splitfail + 1
		end
		


		f:close()
	end
end


fo:write("权重识别失败次数: " .. amount - percent.dw .. "  成功率: " .. percent.dw / amount * 100 .. "%\n" .. "方差识别失败次数: " .. amount - percent.dv .. "  成功率: " .. percent.dv / amount * 100 .. "%\n")
fo:write("分割失败次数: " .. splitfail)
fo:close()
