local luacom = require "luacom"
local request = require "request"
local cookies = require "stealcookies"
local socket = require "socket"
local bp = package.loaded.BP or require "BP"
local im = require "imlua"
require "imlua_process"
local io = require "io"
local os = require "os"
require "logging"

local config = require "config"

local _M = {}

local httpc = config.httpc
local imgprocess = config.imgprocess
local recong = config.recong

local splitretry = recong.splitretrycount or 5
local ss =  httpc.sleepseconds		-- sleep seconds for document ready
local tmsurl = httpc.tmsurl			-- start URL
local atmdomain = httpc.atmdomain		-- domain name for Hosts file operation
local olcheckurl = httpc.olcheckurl		-- url of form page
local imgurl = httpc.imgurl			-- url of code image
local submiturl = httpc.submiturl		-- url of submit post
local submitretrycount = httpc.submitretrycount or 3
local THRESHOLD = imgprocess.THRESHOLD or 20		
local imgpath = imgprocess.imgpath or "./imgcache/" 		-- Path storge checkcode imgs, end with /
local formids = httpc.formids or {}		-- form {id={name=...}}
local successstr = httpc.successstr or string.char(229, 136, 183, 229, 141, 161, 230, 136, 144, 229, 138, 159) 
local codeid = httpc.codeid -- input name of code

local function msg(s)
	if config.d>=1 then
		print(s)
	end
end


local function waitdoc(ie, t)
	if not ie then return nil end
	local step = 0.2
	local count = 20

	if t then step = t/20 end

	for i = 1, 20 do
		if ie.ReadyState == 4 then return true end
		socket.select(nil, nil, step)
	end
end


function sleep(sec)
	msg("Wait for " .. tostring(sec) .. " seconds")
	socket.select(nil, nil ,sec)
end

function _M.trylogin()
	for i = 1, 3 do
		msg("Login webpage opening...")
		local ie = luacom.CreateObject("InternetExplorer.Application")
		if not ie then
			return nil, "Create IE object fail"
		end
		if config.d>=1 then
			ie.Visible = 1
		end
		ie:Navigate(tmsurl)
		msg("    " .. tmsurl)
		if not waitdoc(ie, 3 * ss) then return nil, "Login page Document load timeout" end

		if ie.document:getelementByID"topFrameSet" then
			return ie
		end
		ie:quit()
		ie = nil
	end
	return nil, "webpage don't have a topFrameSet"
end

function checkreg(id)
	if not regcode then return err, "请输入一个授权码" end
	local tempid = tonumber(string.reverse(id) .. id)
	local s = ""
	repeat
		tempid = math.floor(tempid / 17)
		s = s .. string.char(65+tempid%26)
	until tempid <= 17
	if s ~= regcode then return nil, "您未被授权使用该程序" end
	return true
end

function _M.viewstat(ie)
	msg("Navigate to " .. olcheckurl)	
	ie:Navigate(olcheckurl) 
	if not waitdoc(ie, ss) then return nil, "Form page Document load timeout" end
	local form = {}
	msg("Fetch form value: ")
	----- check regcode -----
	if ie.document:getElementByID("Table2") then
		local tempempid = string.match(ie.document:getElementByID("Table2").innerHTML, "lblMan[^%d]*%d+")
		local empid = string.match(tempempid, "%d+$")
		local re, err = checkreg(empid)
		if not re then return nil, err end
	end
	-------------------------
	for k,v in pairs(formids) do
		if not ie.document:getElementByID(k) then
			return nil, "No " .. k .. "form id"
		end
		form[v]= ie.document:getElementByID(k).Value
		msg("    " .. v .. "=" .. form[v])
	end
	return form
end

function _M.token()
	cookies.hosts("add", {domain=atmdomain,ip="127.0.0.2"})
	-- sleep(2)		-- sleep sometimes
	cookies.listen()
	local ie = luacom.CreateObject("InternetExplorer.Application")
	if not ie then
		return nil, "IE object create fail"
	end
	if config.d>=1 then
		ie.Visible = 1
	end
	ie:Navigate(olcheckurl)
	-- if waitdoc(ie, 2) then return nil, "Stealcookie page Document loaded (this should not happend)" end -- Wait only 2s
	local token = cookies.cookie()
	cookies.hosts("del", {domain=atmdomain})
	if not token then return nil, "Cookie is nil" end

	ie:quit()
	sleep(2)
	ie = nil

	msg("Login cookies: \n".. "    " .. (token or ""))
	return token
end

function prepraseImg(imgraw)
	local gifname = imgpath .. os.time() .. ".GIF"
	local f = io.open(gifname, "w+b")
	if not f then return nil, "create img file fail" end
	f:write(imgraw)
	f:close()
	msg("Write image to file: " .. gifname)
	local img = im.FileImageLoad(gifname)
	local gray = im.ImageCreateBased(img, nil, nil, im.GRAY, nil)
	im.ConvertColorSpace(img, gray)
	local binary = im.ImageCreateBased(gray, nil, nil, im.BINARY, nil)
	im.ProcessPercentThreshold(gray, binary, THRESHOLD)
	if not binary then return nil, "img process get a nil" end
	msg("Get image:")
	return binary
end

local function crackcode(imgurl, t)
	local err = nil
	for i = 1, splitretry do
		codeimg, err = request.codeimg(imgurl, t)
		if not t then return nil, err end
		imgdata, err = prepraseImg(codeimg) 			
		if not imgdata then return nil, err end
		code, err = bp.recognition(imgdata)
		if code then 
			return code
		end
	end

	return nil, err
end

-- request.submit:url cookie form request.codeimg:url cookie

local function checkresult(resp)
	if string.find(resp, string.char(232, 175, 183, 232, 190, 147, 229, 133, 165, 230, 156, 137, 230, 149, 136, 231, 154, 132, 233, 170, 140, 232, 175, 129, 231, 160, 129), 1, true) then
		msg("验证码无法通过验证")
		return nil, "验证码无法通过验证", "retry"
	elseif string.find(resp, successstr, 1, true) then
		msg("刷卡成功")
		return os.date(), "check card OK "	-- FIXME Save img and code to train dataset
	else
		return nil, "表单没有返回失败或者成功(可能cookie已失效)"
	end
end

local function submitretry(t, vs)
	local code, err, re retryf = nil, nil, nil
	for i = 1, submitretrycount do
		repeat
			code, err = crackcode(imgurl, t)
			if not code then break end
			vs[codeid] = code						-- Fill form complete
			vs["btnSubmit"] = string.char(230, 143, 144, 228, 186, 164, 20)	 
			local result = request.submit(submiturl, t, vs)
			if config.d>=1 then 
				f = io.open("response.txt", "w+b")
				f:write(result)
				f:close()
				-- msg(result)
			end
			re, err, retryf = checkresult(result)
			info("==>第" .. i .. "次提交 ")
			if not retryf then
				return re, err
			end
			break
		until nil
	end
	return nil, err
end



function _M.olcheck()
	local ie,err = nil, nil
	local t, codeimg, code, vs, sr = nil,nil,nil,nil
	repeat 
		-- 获取登陆凭证
		cookies.hosts("del", {domain=atmdomain})
		ie, err = _M.trylogin()
		if not ie then break end 
		vs, err = _M.viewstat(ie)
		msg(vs)
		if not vs then break end
		t, err = _M.token()
		if not t then break end

		ie:quit()			-- close IE as soon
		sleep(2)
		ie = nil

		do return submitretry(t, vs) end

		-- 验证码获取和识别
		--[[
		code, err = crackcode(imgurl, t)	
		if not code then break end

		vs[codeid] = code						-- Fill form complete
		vs["btnSubmit"] = string.char(230, 143, 144, 228, 186, 164, 20)	 
		local result = request.submit(submiturl, t, vs)


		if config.d>=1 then 
			f = io.open("response.txt", "w+b")
			f:write(result)
			f:close()
			-- msg(result)
		end
		-]]


		-- 检查结果

		
	
	until 1

	if ie then ie:quit() end
	return nil, err
end

return _M
