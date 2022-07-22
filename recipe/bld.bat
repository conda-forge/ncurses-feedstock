bash -c "pwd; ls -l . .."
bash -ex recipe/bld.sh
if errorlevel 1 exit 1
