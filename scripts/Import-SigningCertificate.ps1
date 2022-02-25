Param(
    $CertFile = ".\DistroLauncher-Appx_TemporaryKey.cer",
    $CertStoreLocation = "cert:\LocalMachine\TrustedPeople"
)

Import-Certificate `
    -FilePath $CertFile `
    -CertStoreLocation $CertStoreLocation
