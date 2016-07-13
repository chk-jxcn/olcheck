luacom = require "luacom"
socket = require "socket"

local ie = nil
local t = {}
for x =1, 1000 do 
	ie = luacom.CreateObject("InternetExplorer.Application")
	-- ie.visible=1
	ie:navigate("it.zte.com.cn")
	local i = nil
	for i = 1,20 do
		if ie.ReadyState == 4 then break end
		socket.select(nil,nil,0.1)
	end
	if not t[i] then 
		t[ii] = 1
	else
		t[i] = t[i] + 1
	end
	ie:quit()
	if x % 20 == 0 then 
		io.write(".")
	end
end

print()

for _,x in ipairs(t) do
	print(_ .. ": " .. string.rep("*", math.log(x) + 1))
end
	
