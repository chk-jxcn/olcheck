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
	recong = {		-- �и�ͼ��ʧ�ܺ��ں����ڲ����Դ���
		splitretry = 5
	},
	checktime = {
		sleeptimeforcheck = 120		-- �����Ӽ��һ��
		,holddelay = {0, 20}		-- ʱ���ǰ0���ӣ�ʱ����20�����ڽ�������
		,retrycheck = 3			-- ÿ��ʱ������ԵĴ���
	}
}

