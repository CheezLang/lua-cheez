$libname = "lua"

New-Item -ItemType Directory -Path "int" -Force

&"../../CheezLang/CheezCBindingGenerator.exe" lua.lua "./int"
Write-Host ""
if (-not (Test-Path "./$libname")) {
    New-Item -ItemType Directory "./$libname"
}
Copy-Item "./int/$libname.che" "./$libname/$libname.che" -Force
Write-Host ""
