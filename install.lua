require "os"
require "io"

io.stdout:write("��������Ȩ��:")
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
echo ����������������м���Ƿ����IE�������ʼ�ϵͳ���Ƿ������ҳ
echo !!!!!!!!!�뽫��ȫ���ر�!!!!!!!!!!!
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
print("����run.cmd...")
