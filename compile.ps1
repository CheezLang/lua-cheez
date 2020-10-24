$libname = "lua"

Write-Host "Compiling C++ part"
&clang -c "./int/lua.cpp" -o "./int/binding.o" -DFORCE_CPP
&llvm-lib "/out:./int/binding.lib" "./int/binding.o"

if (-not (Test-Path "./$libname")) {
    New-Item -ItemType Directory "./$libname"
}
if (-not (Test-Path "./$libname/lib")) {
    New-Item -ItemType Directory "./$libname/lib"
}
Write-Host ""
Copy-Item "./int/binding.lib" "./$libname/lib/binding.lib" -Force