$password = "-" | ConvertTo-SecureString -AsPlainText -Force
Import-PfxCertificate -FilePath "c:\cert.pfx" -CertStoreLocation Cert:\LocalMachine\my -Password $Password