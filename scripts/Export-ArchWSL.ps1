Param(
    $DistroName = "ArchLinux"
)

wsl --terminate $DistroName
wsl --export $DistroName .\install.tar
& "$env:ProgramFiles\7-Zip\7z.exe" a .\install.tar.gz .\install.tar
