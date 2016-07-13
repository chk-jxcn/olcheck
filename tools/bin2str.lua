local string = require "string"
local io = require "io"

local _M = {}



--[[
-- Usage: lua [s|t] bin2str.lua filein fileout
-- Change BINARY file to string or table
--]]
function _M.bin2str(arg)
	local fi = io.input()
	local fo = io.output()
	local stdin = true
	if arg then
		if arg[2] then fi = io.open(arg[2], "rb") stdin = false end
		if arg[3] then fo = io.open(arg[3], "w+") end
	end

	local i = 1
	local sflag = 0
	repeat
		local outstr = {}
		if stdin == true then
			input = fi:read()
		else
			input = fi:read(16)
		end

		if not input then
			break
		end

		for a = 1, input:len() do
			table.insert(outstr, ("%3d"):format(input:byte(a)))
		end

		if outstr[1] then
			if sflag == 1 then fo:write(eol .. cat) else fo:write(head) end
			fo:write(table.concat(outstr, sprchars))
			sflag = 1
		end
		i = i+1
	until nil
	fo:write(eof)
	return i
end

if arg then 
	if arg[1] == "t" then
		head = "local t = {\n    "
		cat  = "     "
		eol  = ",\n"
		eof  = " }\n return t"
		sprchars = ","
	elseif arg[1] == "s" then
		head = "s = string.char("
		cat  = "..  string.char("
		eol  = ")\n"
		eof  = ")"
		sprchars = ","
	end
	_M.bin2str(arg) end


return _M






