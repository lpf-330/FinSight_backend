@echo off
echo FinSight API Production Test v2.0
echo ========================================
echo.

REM Test Login
echo Testing Login...
curl -X POST "http://localhost:8080/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"testuser\",\"password\":\"123456\"}"

echo.
echo.
echo Test completed.