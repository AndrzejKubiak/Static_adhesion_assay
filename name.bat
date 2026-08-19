@echo off
setlocal EnableDelayedExpansion

for %%F in (*.ome.tiff) do (
    set "name=%%F"

    set "new=!name:_s1.ome.tiff=_s1_aCD31.ome.tiff!"
    set "new=!new:_s5.ome.tiff=_s5_aCD31.ome.tiff!"

    set "new=!new:_s2.ome.tiff=_s2_aGFP.ome.tiff!"
    set "new=!new:_s6.ome.tiff=_s6_aGFP.ome.tiff!"

    set "new=!new:_s3.ome.tiff=_s3_tCD31.ome.tiff!"
    set "new=!new:_s7.ome.tiff=_s7_tCD31.ome.tiff!"

    set "new=!new:_s4.ome.tiff=_s4_tGFP.ome.tiff!"
    set "new=!new:_s8.ome.tiff=_s8_tGFP.ome.tiff!"

    if not "!name!"=="!new!" (
        echo "!name!" --^> "!new!"
        ren "!name!" "!new!"
    )
)

echo.
echo Gotowe.
pause