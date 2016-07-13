require "io"
require "os"
require "socket"
config = require "config"
ck =require "checkcard"
require "logging"

err = nil
weeklyresult = {}
dateresult = {}
weeks = -1
logfile = nil
sleepflag = 0


sleeptimeforcheck = config.checktime.sleeptimeforcheck or 120 	-- 2 mins
holddelay = config.checktime.holddelay or {0,20}		-- hold	
retrycheck = config.checktime.retrycheck or 3


function ZZZ()
	if sleepflag == 1 then
		rawinfo(".")
	else
		info("zZZ: sleep " .. sleeptimeforcheck .. " seconds")
		sleepflag = 1

	end
	socket.select(nil,nil,sleeptimeforcheck)
end

function msg(s)
	if config.d >= 1 then
		print(os.date() .. ": " .. s)
	end
end

function prasetime()
	local f = io.open("checktime.ini", "r")
	if not f then return nil, "can't open config file" end
	local s = f:read("*a")
	f:close()
	local timechunk = loadstring(s)
	timechunk()
	if default then
		info("加载default时间点") 
	end
	info("加载checktime时间点")
	if not checktime then 
		info("没有checktime配置,退出...")
		return nil, "No checktime" 
	end
	return true
end

function tryclearresult(t)
	-- local t = os.date("*t")
	if t.wday == 2 then			-- Monday
		if weeks ~= math.floor(t.yday/7) then 
			weeklyresult = {}
			info("新的一周到了,清除上周结果")
			weeks = math.floor(t.yday/7)
		end
	end
end

function comparetime(t1, t2, dl, dr)
	local t1mins = t1[1] * 60 + t1[2]
	local t2mins = t2[1] * 60 + t2[2]
	msg("t2: " .. t2mins .. "  t1: " .. t1mins)
	if t1mins - t2mins <= dr and t2mins - t1mins <= dl then
		return true
	end
	return nil
end

function defaultcheck(t)
	if not default then 
		return nil, "no default config"
	end
	-- local t = os.date("*t")
	for _, hm in pairs(default) do
		if comparetime({t.hour,t.min}, hm, holddelay[1], holddelay[2]) then
			return _
		end
	end
	return nil
end

function check(hms, t)
	-- local t = os.date("*t")
	for _, hm in pairs(hms) do
		if comparetime({t.hour,t.min}, hm, holddelay[1], holddelay[2]) then
			return _
		end
	end
	return nil
end

function todayin(mds, t)
	-- local t = os.date("*t")
	for _, md in pairs(mds) do
		if t.month == md[1] and t.day == md[2] then
			return true
		end
	end
	return nil
end


function shouldcheck(t)
	msg("shouldcheck entry")
	local t = t
	if not t then t = os.date("*t") end
	tryclearresult(t)
	if mustcheck then
		if todayin(mustcheck, t) then
			local N = defaultcheck()
			local key = t.month.. " " .. t.day
			if dateresult[key] and dateresult[key][N] then
				return nil, "havecheck"
			end
			return N, {"date", key}
		end
	end
	if notcheck then
		if todayin(notcheck, t) then 
			return nil 
		end
	end

	if checktime[t.wday - 1] then
		local N = check(checktime[t.wday - 1], t)
		msg("the " .. (N or "-miss-") .. "th check in this day")
		if weeklyresult[t.wday] and weeklyresult[t.wday][N] then
			return nil, "havecheck"
		end
		return N, {"weekly", t.wday}, "checktime"
	end
	if t.wday - 1 >= 1 and t.wday - 1 < 6 then
		local N = defaultcheck(t)
		msg("the " .. (N or "-miss-") .. "th check in this day(default)")
		if weeklyresult[t.wday] and weeklyresult[t.wday][N] then
			return nil, "havecheck"
		end
		return N, {"weekly", t.wday}, "default"
	end
	return nil, "did not need checkcard?"
end


function run()
	re,err = prasetime()
	if not re then info(err) return nil end

	repeat
		local N, timeinfo = shouldcheck() 
		if N then
			sleepflag = 0
			for x = 1, retrycheck do
				info("第" .. x .. "次尝试")
				re, err = ck.olcheck()
				if re then
					if timeinfo[1] == "month" then
						if not dateresult[timeinfo[2]] then dateresult[timeinfo[2]] = {} end
						dateresult[timeinfo[2]][N] = 1
					else
						if not weeklyresult[timeinfo[2]] then weeklyresult[timeinfo[2]] = {} end
						weeklyresult[timeinfo[2]][N] = 1	
					end
					
					info("刷卡成功，准确时间: " .. re)
					break
				else
					info("刷卡失败，错误信息: " .. err)
				end
			end
		end
		ZZZ()

	until nil
end

regcode = nil
if arg and arg[1] then regcode = arg[1] end
run()
	


