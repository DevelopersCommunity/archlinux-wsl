Param(
    $CertFile = ".\DistroLauncher-Appx_TemporaryKey.crt",
    $CertStoreLocation = "cert:\LocalMachine\TrustedPeople"
)

Import-Certificate `
    -FilePath $CertFile `
    -CertStoreLocation $CertStoreLocation
