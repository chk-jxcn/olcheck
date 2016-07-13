echo off
echo .
echo .
echo 请先在任务管理器中检查是否打开了IE，包括邮件系统中是否打开了网页
echo !!!!!!!!!请将其全部关闭!!!!!!!!!!!
echo .
echo .

pause
set PATH=E:\OLCheck1.2\OLCheck\luart\clibs;%PATH%
set LUA_PATH=.\?.lua;E:\OLCheck1.2\OLCheck\luart\Lua\?.lua
cd /D "E:\OLCheck1.2\OLCheck"
"E:\OLCheck1.2\OLCheck\luart\lua" main.lua GRKABDKWWSCK
pause
