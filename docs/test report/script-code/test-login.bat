@echo off
echo Testing login API...
curl -X POST http://localhost:8080/api/auth/login -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"123456\"}" -v
echo.
echo.
echo Press any key to exit...
pause > nul