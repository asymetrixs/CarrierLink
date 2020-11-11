@echo off

for /D %%G in (*) DO (
	echo Deleting %%G\bin
	rmdir /S /Q %%G\bin 2>NUL
	echo Deleting %%G\obj
	rmdir /S /Q %%G\obj 2>NUL
)