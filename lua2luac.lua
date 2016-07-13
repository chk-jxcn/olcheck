require "lfs"
require "os"
require "string"


for x in lfs.dir(".") do
	if string.match(x, "lua$") and x ~= "config.lua" then
		os.execute("move " .. x .. " " .. x .. ".bak")
		print("exec" .. "move " .. x .. " " .. x .. ".bak")
		os.execute("luart\\luac -o " .. x .. " " .. x .. ".bak")
		print("exec " .. "luart\\luac -o " .. x .. " " .. x .. ".bak")			
		os.execute("del " .. x .. ".bak")
		print("exec " .. "del " .. x .. ".bak")
	end
end
