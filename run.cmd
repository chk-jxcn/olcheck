echo off
echo .
echo .
echo ����������������м���Ƿ����IE�������ʼ�ϵͳ���Ƿ������ҳ
echo !!!!!!!!!�뽫��ȫ���ر�!!!!!!!!!!!
echo .
echo .

pause
set PATH=E:\OLCheck1.2\OLCheck\luart\clibs;%PATH%
set LUA_PATH=.\?.lua;E:\OLCheck1.2\OLCheck\luart\Lua\?.lua
cd /D "E:\OLCheck1.2\OLCheck"
"E:\OLCheck1.2\OLCheck\luart\lua" main.lua GRKABDKWWSCK
pause
