local io = require "io"
local config = require "config"


local _M ={}

-- °ËÁ¬Í¨ÓòÇÐ¸î
--
local function msg(s)
	if config.d>=1 then
		print(s)
	end
end

function _M.img2table(img)
	local t = {}
	local Height = img:Height()
	for row = img:Height() - 1, 0, -1 do 
		for col = 0, img:Width() -1 do
			if not t[Height-row-1] then t[Height-row-1] = {} end
			t[Height-row-1][col] = img[0][row][col]
		end
	end
	return t
end

function _M.splitImg(data)
	return _M.split(_M.img2table(data), data:Width(), data:Height())
end


local function normalily(input)
	local t = {}
	local minx, miny = 64, 23
	for y, r in pairs(input) do
		if y < miny then miny = y end
		for x, v in pairs(r) do
			if x < minx then minx = x end
		end
	end
	
	for y, r in pairs(input) do
		if not t[y - miny] then t[y - miny] = {} end
		for x, v in pairs(r) do
			t[y - miny][x - minx] = v
		end
	end

	return t
end

function _M.split(data, col, row)
	-- copt data to t
	_M.t = data	
	_M.maxcol = col - 1
	_M.maxrow = row - 1
	local chs = {}
	local chsaa = {}
	local mid = math.floor(row/2)
	local j = 1
	for col = 2, col - 3 do   -- aviod edge
		if _M.t[mid][col] == 0 then
			_M.o = {}
			_M.region(col, mid)
			chstr, _ =  _M.printreg(normalily(_M.o))
			table.insert(chsaa, chstr)	-- 0~row - 1, 0~col - 1
			table.insert(chs, normalily(_M.o))
		end
	end
	return chs, chsaa
end

function _M.maxxy(t)
	local row, col = 0, 0
	row = table.maxn(t) + 1
	local out = {}
	for _,x in pairs(t) do
		if table.maxn(x) + 1 > col then col = table.maxn(x) + 1 end
	end
	return row, col
end

function _M.printreg(t)
	local row, col = _M.maxxy(t)
	
	msg(row.."  "..col)
	local out = {}

	for i = 0, row - 1 do
		for j = 0, col - 1 do
			if not t[i] then
				if not out[i] then out[i] = {} end
				out[i][j] = 1
			elseif not t[i][j] then
				if not out[i] then out[i] = {} end
				out[i][j] = 1
			else
				if not out[i] then out[i] = {} end
				out[i][j] = t[i][j]
			end
		end
	end
	local pt = printTable(out, col, row)
	msg(pt)
	return pt, out
end

function _M.region(col, row)
	if col > _M.maxcol or row > _M.maxrow or col < 0 or row < 0 then return end	
	if _M.t[row][col] == 1 then 
		return 
	else
		if not _M.o[row] then _M.o[row] = {} end
		_M.t[row][col] = 1
		_M.o[row][col] = 0
	end

	for x = -1, 1 do
		for y = -1, 1 do
			_M.region(col+x, row+y)
		end
	end
end



return _M
