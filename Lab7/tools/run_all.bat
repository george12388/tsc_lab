@REM call run_test_0.bat 
@REM cd ..
@REM cd tools
@REM call run_test_1.bat 
@REM cd.. 
@REM cd tools 
@REM call run_test_2.bat
@REM cd ..
@REM cd tools
@REM call run_test_3.bat


call run_test.bat 5 0 555 c %0
cd ..
cd tools
call run_test.bat 20 1 555555 c %0
cd ..
cd tools
call run_test.bat 7 2 77 c %0
cd ..
cd tools
call run_test.bat 11 3 777231 c %0