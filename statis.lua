local string = require "string"
local lfs =require "lfs"
local io = require "io"
local config = require "config"
local split = require "split"
require "logging"

local trainconfig = config.trainconfig


local _M = {}
_M.feat = {}

function _M.comput(t, ch)
	if _M.feat[ch] then return end

	_M.feat[ch] = {}
	_M.feat[ch] = _M.computwv(t)

end

function _M.computwv(t)
	local store ={}
	for y, r in pairs(t) do
		store[y] = {}
		-- weight
		local avg, weight, variance, i = 0, 0, 0, 0
		for x, v in pairs(r) do
			weight = weight + x + 1 -- col 0: 1			
			i = i + 1
		end
		store[y].weight = weight
		avg = weight / i
		-- variance
		for x, v in pairs(r) do
			variance = variance + (x+1 -avg)^2
		end
		store[y].variance = variance
	end
	return store
end

function _M.compare(t)
	if not _M.feat["0"] then _M.trainning() end
	local wv = _M.computwv(t)
	local result = {}
	for ch, r in pairs(_M.feat) do
		result[ch] = {dw=0, dv=0}
		for y, wvdata in pairs(r) do
			if not wv[y] then					
				result[ch].dw = result[ch].dw + wvdata.weight
				result[ch].dv = result[ch].dv + wvdata.variance
			else
				result[ch].dw = result[ch].dw + math.sqrt(math.abs((wvdata.weight)^2 - (wv[y].weight)^2))
				result[ch].dv = result[ch].dv + math.abs(wvdata.variance - wv[y].variance)
			end
		end
	end
	return result
end
			
function _M.trainning()
	local i = 0
	for filename in lfs.dir(trainconfig.path) do 
		if string.find(filename, "gif", 1, true)then
			i = i + 1
			local f = io.open(trainconfig.path .. filename,"rb")
			local b = f:read("*a")
			local i = prepraseImg(b)
			chs, aa = split.splitImg(i)
			if table.maxn(chs) == 5 then
				for i = 1, 5 do
					_M.comput(chs[i], string.sub(filename, i, i))
				end
			end
			f:close()
		end
	end
	info ("训练了" .. i .. "组数据" )
end

return _M




