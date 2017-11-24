
REM Excerpted from "Programming Sound with Pure Data",
REM published by The Pragmatic Bookshelf.
REM Copyrights apply to this code. It may not be used to create training material, 
REM courses, books, articles, and the like. Contact us if you are in doubt.
REM We make no guarantees that this code is fit for any purpose. 
REM Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.

SET MINGW=C:\MinGW
SET MSYS=C:\MinGW\msys\1.0
SET MINGW32=C:\MinGW\mingw_32
SET PATH=%MINGW32%\bin;%MINGW%\bin;%MSYS%\bin
make clean
make csharplib
cp libs/libpdcsharp.dll csharp/bin/Debug/