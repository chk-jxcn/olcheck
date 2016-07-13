return {
	d = 0,		--on: 1~4,	0 :off
	stealcookiesconfig = {
		 host = "127.0.0.2"
		 ,port = 80
		 ,timeout = 10
		 --  hosts_filename
	},

	httpc = {
		sleepseconds = 5	  	-- sleep time to wait html document ready
		,tmsurl = "tms.zte.com.cn" 	-- First URL to input
		,atmdomain = "atm.zte.com.cn"  	-- domain to fetch cookie
		,olcheckurl = "http://atm.zte.com.cn/atm/Application/AboutMy/netchkinout.aspx?menuId=ssb.atm.menu.item.onlinecheck"			
		,imgurl = "http://atm.zte.com.cn/atm/Application/AboutMy/CheckCode.aspx"		-- url of checkcode image
		,submiturl = "http://atm.zte.com.cn/atm/Application/AboutMy/netchkinout.aspx?menuId=ssb.atm.menu.item.onlinecheck"
		,formids = {
			["__VIEWSTATE"] = "__VIEWSTATE" ,
			["__EVENTVALIDATION"] = "__EVENTVALIDATION",
			["hidEmpInfo"] = "hidEmpInfo",
			["hidLanguage"] = "hidLanguage",
		},		-- form {id={name=...}}	for form hiden input
		successstr = string.char(229, 136, 183, 229, 141, 161, 230, 136, 144, 229, 138, 159)
		,codeid = "txtpas"
		,submitretrycount = 3
	},

	imgprocess = {
		THRESHOLD = 20 -- threshold of process IM_MAP to IM_BIN
		,imgpath = "./imgcache/" -- Path storge checkcode imgs, end with /
	},
	trainconfig = {
		path = "./train_data/"
	},
	recong = {		-- 切割图像失败后在函数内部重试次数
		splitretry = 5
	},
	checktime = {
		sleeptimeforcheck = 120		-- 两分钟检查一次
		,holddelay = {0, 20}		-- 时间点前0分钟，时间点后20分钟内进行重试
		,retrycheck = 3			-- 每次时间点重试的次数
	}
}

