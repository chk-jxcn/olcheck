function info(s)
	if not logfile then
		logfile = io.open("check.log", "a+")
		if not logfile then 
			print("log文件打开失败")
			os.exit()
		end
	end
	s = ": " .. s
	s = os.date() .. s 
	s = "\n" .. s  
	io.stdout:write(s)
	logfile:write(s)
	logfile:flush()
end

function rawinfo(s)
	if not logfile then
		logfile = io.open("check.log", "a+")
		if not logfile then 
			print("log文件打开失败")
			os.exit()
		end
	end
	io.stdout:write(s)
	logfile:write(s)
	logfile:flush()
end
