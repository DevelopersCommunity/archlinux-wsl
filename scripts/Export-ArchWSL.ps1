Param(
    [Parameter(Mandatory=$true)]
    $Image,
    $DistroName = "ArchLinux"
)

wsl --import ArchLinux C:\wslDistroStorage\ArchLinux $Image
wsl -d $DistroName -e bash -- ./1-arch.sh
wsl --terminate $DistroName
wsl --export $DistroName .\install.tar
& "$env:ProgramFiles\7-Zip\7z.exe" a .\install.tar.gz .\install.tar
Remove-Item .\install.tar
wsl --unregister $DistroName
