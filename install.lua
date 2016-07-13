require "os"
require "io"

io.stdout:write("请输入授权码:")
passwd = io.stdin:read()

os.execute("cd>pwd")
pwdf = io.open("pwd","r")
pwd = pwdf:read("*l")
pwdf:close()
os.execute("del pwd")
fo = io.open("run.cmd", "w+")

template=[[
echo off
echo .
echo .
echo 请先在任务管理器中检查是否打开了IE，包括邮件系统中是否打开了网页
echo !!!!!!!!!请将其全部关闭!!!!!!!!!!!
echo .
echo .

pause
set PATH=%s\luart\clibs;%%PATH%%
set LUA_PATH=.\?.lua;%s\luart\Lua\?.lua
cd /D "%s"
"%s\luart\lua" main.lua %s
pause
]]

output=string.format(template, pwd, pwd, pwd, pwd, passwd)
fo:write(output)
fo:close()
print("生成run.cmd...")
