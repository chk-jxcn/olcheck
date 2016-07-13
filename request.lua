local http = require "socket.http"
local ltn12 = require "ltn12"
local table = require "table"
local string = require "string"
local url = require "socket.url"
local config = require "config"

local _M = {}

function _M.codeimg(imgurl, cookie)
	if not imgurl then 		-- only check imgurl, convience for train data
		return nil, "codeimg: args check fail"
	end

	local h = {
		Cookie = cookie,
		["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; InfoPath.2)",
		["Accept-Language"] = "zh-cn",
	}
	
	local resp = {}
	local request = {
		url = imgurl,
		method = "GET",
		headers = h,
		sink = ltn12.sink.table(resp)
	}

	if config.d>3 then 
		request.url = "http://127.0.0.1:8888"
	end
	
	local r, c, h = http.request(request)
	if not config.d and c ~= 200 then return nil, "http not response a 200 code" end

	if config.d>3 then
		f = io.open("sample.gif", "rb")
		img = f:read("*a")
		f:close()
		return img
	end

	return table.concat(resp), tonumber(h["content-length"])
end

function _M.submit(submiturl, cookie, form)
	if not (submiturl and cookie and form) then 
		return nil, "submit: args check fail"
	end
	
	local formstrs = {}
	for k,v in pairs(form) do 
		table.insert(formstrs,  k .. "=" .. url.escape(v))
	end
	local formstr = table.concat(formstrs, "&")
	formstr = string.gsub(formstr, "%%20", "+")

	local h = {
		Cookie = cookie,
		["User-Agent"] = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; InfoPath.2)",
		["Accept-Language"] = "zh-cn",
		["Content-Length"] = string.len(formstr),
		["Content-Type"] = "application/x-www-form-urlencoded",
		["Accept"] = "image/gif, image/jpeg, image/pjpeg, image/pjpeg, application/x-shockwave-flash, application/x-ms-application, application/x-ms-xbap, application/vnd.ms-xpsdocument, application/xaml+xml, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*",
		["Referer"] = "http://atm.zte.com.cn/atm/Application/AboutMy/netchkinout.aspx?menuId=ssb.atm.menu.item.onlinecheck"
	}

	local resp = {}

	local request = {
		url = submiturl,
		method = "POST",
		headers = h,
		sink = ltn12.sink.table(resp),
		source = ltn12.source.string(formstr) 
	}

	if config.d>3 then 
		request.url = "http://127.0.0.1:8889"
	end

	local r, c, h = http.request(request)
	
	if c ~= 200 then return nil, "http not response a 200 code" end
	return table.concat(resp), tonumber(h["content-length"])
end

return _M	
