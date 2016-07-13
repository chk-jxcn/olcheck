local io = require "io"
local config = require "config"
local split =  require "split"
local statis = require "statis"



local _M = {}

local function msg(s)
	if config.d>=1 then
		print(s)
	end
end

function printImg(data)
	local s = ""
	for i = data:Height() - 1, 0, -1 do 
		for j =0, data:Width() - 1 do
			if data[0][i][j] == 0 then s = s .. "*" else s = s .. " " end
		end
		s = s .. "\n"
	end
	return s
end

function printTable(data, col, row)
	local s = ""
	for i = 0, row - 1 do 
		for j =0, col - 1 do
			if data[i][j] == 0 then s = s .. "*" else s = s .. " " end
		end
		s = s .. "\n"
	end
	return s
end

-- TOP_BOTTOM -> TOP_TOP

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


function compt(e1,e2) 
	return e1.c:byte(1) < e2.c:byte(1) 
end

function _M.recognition(data)
	local t = _M.img2table(data)
	msg(printTable(t,data:Width(), data:Height()))
	_M.code = ""
	local chts, aa = split.split(t, data:Width(), data:Height())
	if table.maxn(chts) == 5 then
		local chpoint = 1
		for _, cht in ipairs(chts) do
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
			_M.code = _M.code .. chdv.c
			table.sort(t, compt)
		end
	else
		return nil, "split fail"
	end

	--[[
	if config.d then
	ShowImage(data)
	iup.MainLoop()  
	end
	--]]

	msg("recognition code: " .. _M.code)
	if not _M.code then return nil, "Cant't recognition code" end
	return _M.code
end

--[=[[
function _M._test()
	require "imlua"
	img = im.FileImageLoad("sample.gif")
	_M.recognition(img)
end

----------------below is test func---------------------
require"imlua"
require"cdlua"
require"cdluaim"
require"iuplua"
require"iupluacd"

function PrintError(func, err)
  local msg = {}
  msg[im.ERR_OPEN] = "Error Opening File."
  msg[im.ERR_MEM] = "Insuficient memory."
  msg[im.ERR_ACCESS] = "Error Accessing File."
  msg[im.ERR_DATA] = "Image type not Suported."
  msg[im.ERR_FORMAT] = "Invalid Format."
  msg[im.ERR_COMPRESS] = "Invalid or unsupported compression."
  
  if msg[err] then
    print(func..": "..msg[err])
  else
    print("Unknown Error.")
  end
end


function ShowImage(image)
  if not image then
    return false
  end

  if dlg then
    dlg.canvas = nil
    dlg.image = nil
    iup.Destroy(dlg)
  end

  cnv = iup.canvas{}
  w = image:Width()
  h = image:Height()
  if (w > 800) then w = 800 end
  if (h > 600) then h = 600 end
  cnv.rastersize = string.format("%dx%d", w, h)
  cnv.border = "no"
  cnv.scrollbar = "no"  
  cnv.xmax = image:Width()-1
  cnv.ymax = image:Height()-1

  function cnv:action()
    local canvas = dlg.canvas
    local image = dlg.image
    
    if (not canvas) then return end
    
    -- posy is top-down, CD is bottom-top.
    -- invert scroll reference (YMAX-DY - POSY).
    y = self.ymax-self.dy - self.posy
    if (y < 0) then y = 0 end

    canvas:Activate()
    canvas:Clear()
    x = -self.posx
    y = -y
    image:cdCanvasPutImageRect(canvas, 0, 0, image:Width(), image:Height(), 0, 0, 0, 0)
    canvas:Flush()
    
    return iup.DEFAULT
  end

  -- Set the Canvas inicial size (IUP will retain this value).
  function cnv:resize_cb(w, h)
    self.dx = w
    self.dy = h
    self.posx = self.posx -- needed only in IUP 2.x
    self.posy = self.posy
  end

  text = iup.text{  SIZE = 40 }
  btn_OK = iup.button{ title = "OK" }
  dlg = iup.dialog{iup.vbox { cnv, text, btn_OK }}
  dlg.title = "code?"
  dlg.cnv = cnv
  dlg.image = image
  
  function dlg:close_cb()
    local canvas = self.canvas
    local image = self.image

    if canvas then canvas:Kill() end

    return iup.CLOSE
  end

  function dlg:map_cb()
    canvas = cd.CreateCanvas(cd.IUP, self.cnv)
    self.canvas = canvas
    self.posx = 0 -- needed only in IUP 2.x
    self.posy = 0
  end

  function btn_OK:action()
    _M.code = text.value
    return iup.CLOSE
  end
  
  dlg:show()
  cnv.rastersize = nil -- to remove the minimum limit
  return true
end
--]=]

bp=_M
return _M
