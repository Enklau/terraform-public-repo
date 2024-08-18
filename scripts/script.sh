$sourceFile = "C:\terraform-public-repo\file.txt"
$destinationFolder = "C:\inetpub\wwwroot"

Copy-Item -Path $sourceFile -Destination $destinationFolder -Force