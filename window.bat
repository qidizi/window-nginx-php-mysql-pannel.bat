@echo off
::apche+mysql+php相对目录控制面板,需要放到与它们相同的分区下

::-----使用本工具需要设置的参数--------
:: 查看html代码的浏览器, 请修改成自己的路径
set viewHtml=D:\Program Files (x86)\Mozilla Firefox\firefox.exe
::-----设置---结束--部分--------

set bat=%~f0
set batDir=%~dp0
CD "%batDir%"
set log=%batDir%log\

if not exist "%log%" md "%log%"
::if not exist "%viewHtml%" echo 查看html的浏览器不存在:%viewHtml%,需要打开本bat设置 & pause & GOTO :EOF
::if not exist "%batDir%apache" echo apache服务器的目录不是:%batDir%apache,请移动到此路径下 & pause & GOTO :EOF
::if not exist "%batDir%mysql" echo mysql服务器的目录不是:%batDir%mysql,请移动到此路径下 & pause & GOTO :EOF
::if not exist "%batDir%php\php.exe" echo php的目录不是:%batDir%php,请移动到此路径下 & pause & GOTO :EOF

:ch
set ch=other
echo 网站服务控制面板
echo.
echo 序号 对应任务
echo.
echo a 启动apache服务
echo aa 结束apache服务

echo b 启动mysql服务
echo bb 结束mysql服务

echo c 启动nginx服务
echo cc 停止nginx服务
echo ccc 测试nginx服务

echo d 递归移除指定文件夹svn版本

echo e 打开php.ini


echo f 打开httpd.conf

echo g 打开一个php-cgi
echo gg 结束所有的php-cgi

echo 6 检查http.conf配置
echo 7 拖入php文件以命令行模式运行

echo 12 修改root@localhost密码

echo 其它 退出
echo.
echo 请输入上面序号字符后,回车即可完成操作的选择
echo.
set /p ch=
set called=0
:eof_ch
::set /a ch*=1
call :callLabel%ch%
IF %called% EQU 1 goto ch
echo.
echo 本程序即将退出...稍息自动关闭窗口
ping 127.0.0.1 -n 2 >nul
GOTO :EOF
exit

::启动apapche

:callLabela
::新窗口中启动的apache
	set called=1
	echo on
	if exist "%log%httpd.e.txt" del /q "%log%httpd.e.txt"
	start "apache服务窗口" /D "%batDir%apache" "bin\httpd.exe" -X -w
	echo off
:eof_callLabela
	GOTO :EOF
::eof_启动apapche


:callLabelaa
	set called=1
	echo on
	start "停止apache服务" /MIN  /D "%batDir%php" taskkill /F /IM httpd.exe > nul
	start "停止php-cgi服务" /MIN  /D "%batDir%php" taskkill /F /IM php-cgi.exe > nul
	echo off
:eof_callLabelaa
	GOTO :EOF


:callLabelb
	set called=1
	rem 使用--console参数,可以保持mysql进程,关闭窗口立刻停止服务
	start "mysql服务[关闭服务中止]"  /D  "%batDir%mysql"  cmd  /c "echo. && echo 如果本窗口变成可输入状态,如%batDir%mysql^>_[闪动],说明启动失败,或是无法连接服务,请检查出错日志文件 && echo. && echo 关闭窗口即中止mysql服务 && echo. && bin\mysqld.exe --console  --standalone" && exit
:eof_callLabelb
	GOTO :EOF




:callLabelbb
	set called=1
	echo on
	start "停止msyql服务" /MIN  /D "%batDir%php" taskkill /F /IM mysqld.exe > nul
	echo off
:eof_callLabelbb
	GOTO :EOF

	

:callLabelc
	set called=1
::window不支持 nginx的多线程,只能手工生成多个php-cgi
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9000 -e -C -c "%batDir%php/php.ini"
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9001  -e -C -c "%batDir%php/php.ini"
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9002  -e -C -c "%batDir%php/php.ini"
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9003  -e -C -c "%batDir%php/php.ini"
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9004  -e -C -c "%batDir%php/php.ini"
	start "fcgi服务" /MIN  /D "%batDir%php"  php-cgi.exe -b 127.0.0.1:9005  -e -C -c "%batDir%php/php.ini"
	
	start "nginx服务" /MIN  /D "%batDir%nginx" nginx.exe
:eof_callLabelc
	goto :EOF

:callLabelcc
	set called=1
	start "nginx服务" /MIN  /D "%batDir%nginx" nginx.exe -s stop
	ping 127.0.0.1 -n 2 >nul
	start "停止php-cgi服务" /MIN  /D "%batDir%php" taskkill /F /IM php-cgi.exe > nul
	start "停止php-cgi服务" /MIN  /D "%batDir%php" taskkill /F /IM nginx.exe > nul
:eof_callLabelcc
	goto :EOF

::测试nginx服务
:callLabelccc
	set called=1
	cd "%batDir%nginx"
	nginx.exe -t
:eof_callLabelccc
	goto :EOF


:callLabeld
	set called=1
	echo.
	echo 请输入要清除的目录路径
	echo 或者把目录图标拖入这里放开来自动获取目录路径
	echo.
	echo 然后请回车
	echo.
	set /p path=
	if "%path%" == "" (
		echo 路径有误,稍候自动返回主菜单
		ping 127.0.0.1 -n 2 >nul
		goto eof_callLabel10
	)
	if not exist "%path%" (
		echo 路径不存在,稍候自动返回主菜单
		ping 127.0.0.1 -n 2 >nul
		goto eof_callLabel10
	)
	cd "%path%"
	@for /r . %%a in (.) do @if exist "%%a\.svn" rd /s /q "%%a\.svn" 
	pause
:eof_callLabeld
	goto :EOF


::打开php配置文件
:callLabele
	set called=1
	start "php配置文件" /MIN  /D "%batDir%Apache\php" php.ini
:eof_callLabele
	GOTO :EOF
::eof_打开php配置文件



:callLabelg
	set called=1
	start "fcgi服务" /MIN  /D "%batDir%php"   php-cgi.exe -b 127.0.0.1:9000 -c "%batDir%php/php.ini"
:eof_callLabelg
	GOTO :EOF
	
:callLabelgg
	set called=1
	start "停止php-cgi服务" /MIN  /D "%batDir%php" taskkill /F /IM php-cgi.exe > nul
:eof_callLabelgg
	GOTO :EOF

	
::打开httpconf
:callLabel5
	set called=1
	start "apache配置文件" /MIN  /D "%batDir%Apache\conf" httpd.conf
:eof_callLabel5
	goto :EOF
::eof_打开httpconf

::检测httpconf配置
:callLabel6
	set called=1
	echo 检测中...
	cd "%batDir%apache"
	echo 下面是检测结果^<br^/^> > "%TEMP%\php.cli.out.html"
	echo 如果出现如^\xdd^\xed类似错误提示,请使用php的urldecode^(%%dd%%ed^)来转成汉字^<br^/^>^<br^/^> >> "%TEMP%\php.cli.out.html"
	echo ^<textarea style^="width:100%%;height:500px;" wrap^="off"^> >> "%TEMP%\php.cli.out.html"

	bin\httpd.exe -S >> "%TEMP%\php.cli.out.html" 2>&1

	echo ^<^/textarea^> >> "%TEMP%\php.cli.out.html"
	"%viewHtml%" "%TEMP%\php.cli.out.html"
:eof_callLabel6
	goto :EOF
::eof_检测httpconf配置

::在命令行模式下运行php
:callLabel7
	set called=1
:: php的可运行文件路径,需要设置成自己的路径
	set phpBin=.\..\php\php.exe
	echo 请拖入以命令行模式运行的php后回车运行
	echo 直接回车返回主菜单
	echo.
	set s=
	set /p s=
	if "%s%" == "" goto ch
	set s=%s:"=%
	if "%s%" == "" goto ch
	if not exist "%s%" (
		echo 文件 %s% 不存在,稍候自动返回主菜单
		ping 127.0.0.1 -n 5 >nul
		goto ch
	)
	echo 如果此php需要参数请在这里输入[需要按照浏览器规范编码]
	echo 如果不明参数存放方式,请在php中使用phpinfo^(^)方法来查看
	echo.
	echo 如例:
	echo.
	echo 需要传入一个参数,输入如下
	echo "参数值被双引号引起"
	echo.
	echo 需要仿照xx.php^?id^=1^&b^=ddd,输入如下
	echo "id=id值&val=val值&cn=urlencode(中文需要编码)"
	echo.
	echo 需要多组参数,输入如下
	echo "参数组1" "参数组2" "参数组3" "参数组N"
	echo.
	echo 如果不需要参数,请直接回车
	set /p get=
	set getC=%get% ""
	set getC=%getC: =%
	set getC=%getC:"=%
	if not "%getC%" == "" (
		set get=^-^- %get%
	) else (
		set get=
	)
	echo php开始解析中...
	echo 运行时所在目录:"%batDir%apache"
	echo.
	echo 运行时指令串如下
	echo.
	echo %phpBin% -d display_errors=On -d display_startup_errors=On  -d log_errors=Off -d track_errors=On -f "%s%"  %get%
	echo.
	echo.
	cd "%batDir%apache"
	title php命令行模式运行
	%phpBin% -d display_errors=On -d display_startup_errors=On  -d log_errors=Off -d track_errors=On -f "%s%"  %get% 
:eof_callLabel7
	goto :EOF
::eof_在命令行模式下运行php

::设置mysql的root@localhost密码
:callLabel12
	set called=1
	set pwd=root
	echo.
	echo 请输入新密码
	echo.
	set /p=
	%batDir%mysql/bin/mysqladmin -uroot -hlocalhost password %pwd%
	goto :EOF
:eof_callLabel12
