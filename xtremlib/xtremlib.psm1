<#
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This is currently incomplete, I intend to include most API functionality as well as make content more presentable

#TODO
 -Lots
 -Implement token-based security
 -Implement all basic storage creation/setting commands

Written by : Brandon Kvarda
             @bjkvarda
             

#>

######### GLOBAL VARIABLES #########
$global:XtremUsername =$null
$global:XtremPassword =$null
$global:XtremName =$null

######### SYSTEM COMMANDS ##########


#Returns Various XtremIO Statistics
Function Get-XtremClusterStatus ([string]$xioname,[string]$username,[string]$password)
{ 
  <#
     .DESCRIPTION
      Retrieves general XtremIO system statistics

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremClusterStatus

      .EXAMPLE
      Get-XtremclusterStatus -xioname 10.4.45.24 -username admin -password Xtrem10

  #>

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

 $result=
  try{
    $header = Get-XtremAuthHeader -username $username -password $password
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/clusters/?name=$formattedname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content

    

    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }          

}

#Returns list of recent system events
Function Get-XtremEvents([string]$xioname,[string]$username,[string]$password){

}


######### VOLUME AND SNAPSHOT COMMANDS #########

#Returns List of Volumes
Function Get-XtremVolumes([string]$xioname,[string]$username,[string]$password){

  <#
     .DESCRIPTION
      Retrieves list of Volumes

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremVolumes

      .EXAMPLE
      Get-XtremVolumes -xioname 10.4.45.24 -username admin -password Xtrem10

  #>

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
  
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password
    $uri = "https://$xioname/api/json/types/volumes"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).volumes

    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremVolumeInfo([string]$xioname,[string]$username,[string]$password,[string]$volname){
  
   <#
     .DESCRIPTION
      Retrieves information about an XtremIO volume or snapshot

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $volname
      Name of the volume you would like information for

      .EXAMPLE
      Get-XtremVolumeInfo -volname testvol

      .EXAMPLE
      Get-XtremVolumeInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol

  #>
   
   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/volumes/?name=$volname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
   
    return $data
  
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }  
    
}

#Creates a Volume. If no folder specified, defaults to root. 
Function New-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize,[string]$folder){

 <#
     .DESCRIPTION
      Creates a new volume. Returns true if successful.

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $volname
      Name of the volume you would like information for

      .PARAMETER $volsize
      Size of the volume you want to create with trailing 'm', for MB, 'g' GB, 't' for TB

      .PARAMETER $folder 
      Optional parameter. Requires full path format IE /folder1/folder2. Defaults to root

      .EXAMPLE
      New-XtremVolume -volname testvol -volsize 1048m

      .EXAMPLE
      New-XtremVolume -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol -volsize 1048m

  #>

 
 
 if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  if(!$folder){
 $folder = "/"
 }
 
 $result=
  try{
   $header = Get-XtremAuthHeader -username $username -password $password 
   $body = @"
   {
      "vol-name":"$volname",
      "vol-size":"$volsize",
      "parent-folder-id":"$folder"
   }
"@
   $uri = "https://$xioname/api/json/types/volumes/"
   $data = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully create volume ""$volname"" with $volsize of capacity"
   $href = $data.links.href
   return (Invoke-RestMethod -Uri $href -Headers $header -Method Get).content 
   
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
  }

}

#Modify a Volume 
Function Edit-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize){

   <#
     .DESCRIPTION
      Modifies an existing volume. Returns true if successful. 

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $volname
      Name of the volume you would like information for

      .PARAMETER $volsize
      New size of volume with trailing 'm', for MB, 'g' GB, 't' for TB

      .PARAMETER $folder 
      Optional parameter. 

      .EXAMPLE
      Edit-XtremVolume -volname testvol -volsize 2048m

      .EXAMPLE
      Edit-XtremVolume -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol -volsize 1048m

  #>
  
  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
  
  $result=
  try{
   $header = Get-XtremAuthHeader -username $username -password $password 
   $body = @"
   {
      "vol-name":"$volname",
      "vol-size":"$volsize"
   }
"@
   $uri = "https://$xioname/api/json/types/volumes/?name=$volname"
   $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Put -Body $body)
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully modified volume ""$volname"" to have $volsize of capacity" 
   
   return (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
  }


}

#Deletes a Volume
Function Remove-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname){

  <#
     .DESCRIPTION
      Deletes an existing volume. Returns true if successful. 

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $volname
      Name of the volume you would like to remove 

      .EXAMPLE
      Remove-XtremVolume -volname testvol

      .EXAMPLE
      Remove-XtremVolume -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol

  #>
 
 if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
 
 $result = try{
  $header = Get-XtremAuthHeader -username $username -password $password
  $uri = "https://$xioname/api/json/types/volumes/?name="+$volname
  $data = Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
  Write-Host ""
  Write-Host -ForegroundColor Green  "Volume ""$volname"" was successfully deleted"
  
  return $true
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
     
  }
 
}

#Returns List of Snapshots
Function Get-XtremSnapshots([string]$xioname,[string]$username,[string]$password){

  <#
     .DESCRIPTION
      Retrieves list of snapshots 

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremSnapshots

      .EXAMPLE
      Get-XtremSnapshots -xioname 10.4.45.24 -username admin -password Xtrem10

  #>
 
 if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }


 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/snapshots/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).snapshots
    
    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Creates a Snapshot of a Volume
Function New-XtremSnapshot([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$snapname,[string]$folder){

 <#
     .DESCRIPTION
      Creates a snapshot of an existing volume

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $volname
      Name of the volume you would like to snap

      .PARAMETER $snapname
      Name of the new snapshot you are creating

      .PARAMETER $folder
      Optional parameter. Full path of the folder you want the snapshot created in - I.E /folder1/folder2.Defaults to root.

      .EXAMPLE
      New-XtremSnapshot -volname testvol -snapname testsnap

      .EXAMPLE
      New-XtremSnapshot -volname testvol -snapname testsnap -folder /testfolder/snaps

      .EXAMPLE
      Get-XtremSnapshots -xioname 10.4.45.24 -username admin -password Xtrem10

  #>

if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

if(!$folder){
 $folder = "/"
}

$result =
 try{
 $header = Get-XtremAuthHeader -username $username -password $password
 $body = @"
  {
    "ancestor-vol-id":"$volname",
    "snap-vol-name":"$snapname",
    "folder-id":"$folder"
  }
"@
  $uri = "https://$xioname/api/json/types/snapshots/"
  $data = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  Write-Host ""
  Write-Host -ForegroundColor Green "Snapshot of volume ""$volname"" with name ""$snapname"" successfully created"
  
  return (Invoke-RestMethod -Uri ($data.links.href) -Method Get -Headers $header).content 
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
  }
}

#Create Snapshots from a Folder <NOT COMPLETE>
Function New-XtremSnapFolder([string]$xioname,[string]$username,[string]$password,[string]$foldertosnap,[string]$snapfoldername,[string]$snapsuffix){

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

if(!$snapfoldername){
 $snapfoldername = "/"
}

$result =
 try{
 $header = Get-XtremAuthHeader -username $username -password $password
 $body = @"
  {
    "source-folder--id":"$foldertosnap",
    "suffix":"$snapsuffix",
    "source-folder-id":"$folder"
  }
"@
  $uri = "https://$xioname/api/json/types/snapshots/"
  $request = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  Write-Host ""
  Write-Host -ForegroundColor Green "Snapshots of volumes within folder ""$foldertosnap"" have been created"
  return $true
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
  }


}

#Create Snapshots of a set of Volumes (This will need to be modified for 3.0+ release)
Function New-XtremSnapSet([string]$xioname,[string]$username,[string]$password,[string]$vollist,[string]$snaplist){

    

}


#Deletes an XtremIO Snapshot (can probably get rid of this, Remove-XtremVolume also works on snaps)
Function Remove-XtremSnapShot([string]$xioname,[string]$username,[string]$password,[string]$snapname){

 <#
     .DESCRIPTION
      Deletes a snapshot

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $snapname
      Name of the snapshot you would like to remove

      .EXAMPLE
      Remove-XtremSnapshot -snapname testsnap

      .EXAMPLE
      Remove-XtremSnapshot -snapname testnap -xioname 10.4.45.24 -username admin -password Xtrem10

  #>
 
 if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
 
 $result = try{
      $header = Get-XtremAuthHeader -username $username -password $password
      $uri = "https://$xioname/api/json/types/snapshots/?name=$snapname"
      $request = Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
      Write-Host ""
      Write-Host -ForegroundColor Green "Successfully deleted snapshot ""$snapname"""
      Write-Host ""
      return $true
     }
     catch{
        $error = (Get-XtremErrorMsg -errordata  $result) 
        Write-Error $error
         return $error
     }
}

######### VOLUME FOLDER COMMANDS #########

#Returns list of XtremIO Initiator Group Folders
Function Get-XtremVolumeFolders([string]$xioname,[string]$username,[string]$password){

 <#
     .DESCRIPTION
      Retrieves list of volume folders 

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremVolumeFolders

      .EXAMPLE
      Get-XtremVolumeFolders -xioname 10.4.45.24 -username admin -password Xtrem10

  #>

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }


 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/volume-folders/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).folders
    
    return $data
    
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Returns details of an XtremIO Volume Folder. Defaults to root if foldername not entered 
Function Get-XtremVolumeFolderInfo([string]$xioname,[string]$username,[string]$password,[string]$foldername){

 <#
     .DESCRIPTION
      Retrieves details about a specific volume folder

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $foldername
      Full path of the folder you want info about - I.E. /folder1/snaps

      .EXAMPLE
      Get-XtremVolumeFolderInfo

      .EXAMPLE
      Get-XtremVolumeFolderInfo -foldername /folder1/volumes

      .EXAMPLE
      Get-XtremVolumeFolderInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -foldername /folder1/volumes

  #>
    
    if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  if(!$foldername){
 $foldername = "/"
}


 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/volume-folders/?name=$foldername"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content 
    
    return $data
    
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Create a new Volume Folder. If no parent folder is specified, defaults to root.
Function New-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$parentfolderpath){

   <#
     .DESCRIPTION
      Creates a new volume folder

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $foldername
      Name of the folder you want to create

      .PARAMETER $parentfolderpath
      Optional (and defaults to '/'). If not creating in root, need full path - I.E '/folder1/nested'

      .EXAMPLE
      New-XtremVolumeFolder -foldername NewFolder

      .EXAMPLE
      New-XtremVolumeFolder -foldername NewFolder -parentfolderpath /folder1/nested

      .EXAMPLE
      Get-XtremVolumeFolderInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -foldername /folder1/volumes

  #>

   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  
  if(!$parentfolderpath)
  {
   $parentfolderpath = "/"
  }


$result =
 try{
 $header = Get-XtremAuthHeader -username $username -password $password
 $body = @"
  {
    "parent-folder-id":"$parentfolderpath",
    "caption":"$foldername"
  }
"@
  $uri = "https://$xioname/api/json/types/volume-folders/"
  $request = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  Write-Host ""
  Write-Host -ForegroundColor Green "Volume folder ""$foldername"" successfully created"
  
  $data = Invoke-RestMethod -Uri $request.links.href -Headers $header -Method Get

  return $data.content
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
 }
}

#Rename a Volume Folder
Function Edit-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$newfoldername){

}

#Delete a Volume Folder
Function Remove-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername){

}




######### INITIATOR GROUP FOLDER COMMANDS#########

#Returns list of XtremIO Initiator Group Folders
Function Get-XtremIGFolders([string]$xioname,[string]$username,[string]$password){

 <#
     .DESCRIPTION
      Retrieves list of initiator group folders

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremIGFolders

      .EXAMPLE
      Get-XtremIGFolders -xioname 10.4.45.24 -username admin -password Xtrem10

  #>

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }




 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/ig-folders/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).folders
    
    return $data 
    
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Returns details of an XtremIO Initiator Group Folder. Defaults to root if foldername not entered 
Function Get-XtremIGFolderInfo([string]$xioname,[string]$username,[string]$password,[string]$foldername){

 <#
     .DESCRIPTION
      Retrieves details about a specific initiator group folder

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $foldername
      Full path of the folder you want info about - I.E. /folder1/snaps

      .EXAMPLE
      Get-XtremIGFolderInfo

      .EXAMPLE
      Get-XtremIGFolderInfo -foldername /folder1/volumes

      .EXAMPLE
      Get-XtremIGFolderInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -foldername /folder1/volumes

  #>
    
    if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  if(!$foldername)
  {
   $foldername = "/"
  }


 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/ig-folders/?name=$foldername"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
    
    return $data
    
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Create a new IG Folder. If no parent folder is specified, defaults to root.
Function New-XtremIGFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$parentfolderpath){

  <#
     .DESCRIPTION
      Creates a new initiator group folder

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $foldername
      Name of the folder you want to create

      .PARAMETER $parentfolderpath
      Optional (and defaults to '/'). If not creating in root, need full path - I.E '/folder1/nested'

      .EXAMPLE
      New-XtremIGFolder -foldername NewFolder

      .EXAMPLE
      New-XtremIGFolder -foldername NewFolder -parentfolderpath /folder1/nested

      .EXAMPLE
      New-XtremIGFolder -xioname 10.4.45.24 -username admin -password Xtrem10 -foldername NewFolder

  #>

   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  
  if(!$parentfolderpath)
  {
   $parentfolderpath = "/"
  }


$result =
 try{
 $header = Get-XtremAuthHeader -username $username -password $password
 $body = @"
  {
    "parent-folder-id":"$parentfolderpath",
    "caption":"$foldername"
  }
"@
  $uri = "https://$xioname/api/json/types/ig-folders/"
  $request = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  Write-Host ""
  Write-Host -ForegroundColor Green "Initiator Group folder ""$foldername"" successfully created"
  
  $data = Invoke-RestMethod -Uri $request.links.href -Headers $header -Method Get

  return $data.content
  }
  catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
 }
}

#Rename an IG Folder
Function Edit-XtremIGFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$newfoldername){

}

#Delete an IG Folder
Function Remove-XtremIGFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername){

}

######### INITIATOR COMMANDS #########

#Returns List of Initiators
Function Get-XtremInitiators([string]$xioname,[string]$username,[string]$password){

  <#
     .DESCRIPTION
      Returns list of initiators

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremInitiators

      .EXAMPLE
      Get-XtremInitiators -xioname 10.4.45.24 -username admin -password Xtrem10

  #>
   
   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }


   $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiators/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).initiators
    


    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Returns info for a specific XtremIO Initiator
Function Get-XtremInitiatorInfo([string]$xioname,[string]$username,[string]$password,[string]$initiatorname){

  <#
     .DESCRIPTION
      Returns info for a specific initiator

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $initiatorname
      Name of a specific initiator

      .EXAMPLE
      Get-XtremInitiatorInfo -initiatorname testinit1

      .EXAMPLE
      Get-XtremInitiatorInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -initiatorname testinit1

  #>
 
 if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
 
 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiators/?name=$initiatorname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content


    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }
}

#Creates initiator and adds to initiator group
Function New-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname,[string]$address,[string]$igname){
 
  <#
     .DESCRIPTION
      Creates a new initiator and adds to an initiator group

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $initiatorname
      Name of a specific initiator

      .PARAMETER $address
      WWN of initiator - I.E. 00:00:00:00:00:00:00:10

      .PARAMETER $igname
      Name of initiator group

      .EXAMPLE
      New-XtremInitiator -initiatorname testinit1 -address 00:00:00:00:00:00:00:10 -igname testig

      .EXAMPLE
      New-XtremInitiator -initiatorname testinit1 -address 00:00:00:00:00:00:00:10 -igname testig -xioname 10.4.45.24 -username admin -password Xtrem10

  #>
  
  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiators/"
    $body = @"
   {
      "initiator-name":"$initiatorname",
      "port-address":"$address",
      "ig-id":"$igname"
   }
"@

   $request = (Invoke-RestMethod -Uri $uri -Headers $header -Method POST -Body $body)
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully created initiator ""$initiatorname"" with address ""$address"" in initiator group ""$igname"""
   Write-Host ""
   
   $data = Invoke-RestMethod -Uri $request.links.href -Headers $header -Method Get

   return $data.content
   }
   catch{
       $error = (Get-XtremErrorMsg -errordata  $result) 
        Write-Error $error
        return $error
   }
}

#Modifies initiator <NEED TO TEST> <THIS IS NOT COMPLETE>
Function Edit-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname,[string]$newinitiatorname,[string]$newportaddress){

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiators/?name=$initiatorname"
    $body = @"
   {
      "ig-id":"$newinitiatorname"
   }
"@

   $request = (Invoke-RestMethod -Uri $uri -Headers $header -Method POST -Body $body)
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully created initiator ""$initiatorname"" with address ""$address"" in initiator group ""$igname"""
   Write-Host ""
   return $true
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   } 

}

#Deletes initiator <NEED TO TEST>
Function Remove-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname){

  <#
     .DESCRIPTION
      Deletes an initiator

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $initiatorname
      Name of a initiator you want to delete

      .EXAMPLE
      Remove-XtremInitiator -initiatorname testinit1

      .EXAMPLE
      Remove-XtremInitiator -xioname 10.4.45.24 -username admin -password Xtrem10 -initiatorname testinit1

  #>

    if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
 
 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiators/?name=$initiatorname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Delete)
    return $true
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

######### INITIATOR GROUP COMMANDS #########

#Returns list of XtremIO Initiator Groups
Function Get-XtremInitiatorGroups([string]$xioname,[string]$username,[string]$password){

  <#
     .DESCRIPTION
      Returns list of initiator groups

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .EXAMPLE
      Get-XtremInitiatorGroups

      .EXAMPLE
      Get-XtremInitiatorGroups -xioname 10.4.45.24 -username admin -password Xtrem10

  #>
   
   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiator-groups"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get)

    return $data.'initiator-groups'
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Returns info for a specific XtremIO initiator group
Function Get-XtremInitiatorGroupInfo([string]$xioname,[string]$username,[string]$password,[string]$igname){

   <#
     .DESCRIPTION
      Returns info for a specific initiator group

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $igname
      Name of a specific initiator group

      .EXAMPLE
      Get-XtremInitiatorGroupInfo -igname testig

      .EXAMPLE
      Get-XtremInitiatorGroupInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -igname testig

  #>

     if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiator-groups/?name=$igname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content

    return $data
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Creates initiator group <THIS IS NOT COMPLETE>
Function New-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname,[string]$folderpath){

    if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

  if(!$folderpath){
    
    $folderpath = "/"

  }

  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiator-groups/"
    $body = @"
   {
      "parent-folder-id":"$folderpath",
      "ig-name":"$igname"
   }
"@

   $request = (Invoke-RestMethod -Uri $uri -Headers $header -Method POST -Body $body)
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully created initiator group ""$igname"""
   Write-Host ""
   
   $data = Invoke-RestMethod -Uri $request.links.href -Headers $header -Method Get

   return $data.content

   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Modifies initiator group
Function Edit-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

}

#Deletes initiator group <NEED TO TEST THIS>
Function Remove-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

     if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/initiator-groups/?name=$igname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Delete)
    
    Write-Host ""
    Write-Host -ForegroundColor Green "Successfully deleted initiator group ""$igname"""
    return $true
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

######### TARGET INFO COMMANDS #########




######### VOLUME MAPPING COMMANDS #########

#Returns list of volume mapping names
Function Get-XtremVolumeMappingList([string]$xioname,[string]$username,[string]$password){

   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/lun-maps"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get)

    return $data.'lun-maps' | Select-Object @{Name="Lun Map Name";Expression={$_.name}} 
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Returns Volumes mapped by Initiator group/hostname
Function Get-XtremVolumeMappingInfo([string]$xioname,[string]$username,[string]$password,[string]$igname){

  <#
     .DESCRIPTION
      Returns volumes mapped to a initiator group

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $igname
      Name of initiator group

      .EXAMPLE
      Get-XtremVolumeMappingInfo -igname testig

      .EXAMPLE
      Get-XtremVolumeMappingInfo -xioname 10.4.45.24 -username admin -password Xtrem10 -igname testig

  #>
  
   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

   $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $mapuri = "https://$xioname/api/json/types/lun-maps"
    $data = (Invoke-RestMethod -Uri $mapuri -Headers $header -Method Get)
    $maplist = $data.'lun-maps'.name
    $maparray =@()
    Write-Host ""
    Write-Host "Retrieving volume list for host ""$igname"". This request may take a while on arrays with a lot of volumes..."
    Write-Host ""
    $maplist | ForEach-Object -Process {
    $tempdata = (Invoke-RestMethod -Uri "https://$xioname/api/json/types/lun-maps/?name=$_" -Headers $header -Method Get).content

      if($tempdata.'ig-name' -eq $igname){
        $mapobject = New-Object System.Object
        $mapobject | Add-Member -type NoteProperty -name 'Map ID' -Value $tempdata.'mapping-index'
        $mapobject | Add-Member -type NoteProperty -name 'Volume Name' -Value $tempdata.'vol-name'
        $mapobject | Add-Member -type NoteProperty -name 'Host (IG)' -Value $tempdata.'ig-name'
        $maparray += $mapobject

       }
    }
   return $maparray

    }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Returns Map ID for a given volume and host/ig name combination. Helpful for removing a mapping.
Function Get-XtremVolumeMapID([string]$xioname,[string]$username,[string]$password,[string]$igname,[string]$volname){

   if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

   $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $mapuri = "https://$xioname/api/json/types/lun-maps"
    $data = (Invoke-RestMethod -Uri $mapuri -Headers $header -Method Get)
    $maplist = $data.'lun-maps'.name
    $mapid = $null
    Write-Host ""
    Write-Host "Retrieving volume mapping for volume ""$volname"" and host ""$igname"". This request may take a while on arrays with a lot of volumes..."
    Write-Host ""
    $maplist | ForEach-Object -Process {
    $tempdata = (Invoke-RestMethod -Uri "https://$xioname/api/json/types/lun-maps/?name=$_" -Headers $header -Method Get).content

      if($tempdata.'ig-name' -eq $igname -and $tempdata.'vol-name' -eq $volname){
        
        $mapid = $tempdata.'mapping-index'
      
       }
    }
   return $mapid

    }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}

#Maps volume to initiator group
Function New-XtremVolumeMapping([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$igname){

  <#
     .DESCRIPTION
      Maps a volume to an initiator group

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $igname
      Name of initiator group you want to map volume to

      .PARAMETER $volname
      Name of volume you would like to map

      .EXAMPLE
      New-XtremVolumeMapping -volname testvol -igname testig

      .EXAMPLE
      New-XtremVolumeMapping -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol -igname testig

  #>
  
  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }


  $result=try{
    $header = Get-XtremAuthHeader -username $username -password $password
    $body = @"
    {
    "vol-id":"$volname",
    "ig-id":"$igname"
    }
"@
    $uri = "https://$xioname/api/json/types/lun-maps/"
    $request = Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
    Write-Host ""
    Write-Host -ForegroundColor Green "Volume ""$volname"" successfully mapped to initiator group ""$igname"""
    return $true
   }
   catch{
       $error = (Get-XtremErrorMsg -errordata  $result) 
        Write-Error $error
        return $error
   }  

}

#Removes volume mapping
Function Remove-XtremVolumeMapping([string]$xioname,[string]$username,[string]$password,[string]$igname,[string]$volname){
 
  <#
     .DESCRIPTION
      Unmaps a volume from an initiator group (does not delete the IG or the volume, just unmaps)

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $username
      Username for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $password
      Password for XtremIO XMS. Optional if XtremIO Session was initiated

      .PARAMETER $igname
      Name of initiator group you want to unmap the volume from

      .PARAMETER $volname
      Name of volume you would like to unmap

      .EXAMPLE
      Remove-XtremVolumeMapping -volname testvol -igname testig

      .EXAMPLE
      Remove-XtremVolumeMapping -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol -igname testig

  #>

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
   
    
  $result=
  try{
    $mapname = (Get-XtremVolumeMapID -xioname $xioname -username $username -password $password -igname $igname -volname $volname) 
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/lun-maps/$mapname"
    $request = (Invoke-RestMethod -Uri $uri -Headers $header -Method DELETE)

    Write-Host ""
    Write-Host -ForegroundColor Green "Successfully deleted mapping of volume ""$volname"" from host/ig ""$igname"""
    return $true
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   return $error
   }

}


######### REQUEST HELPERS #########


#Generates Header to be used in requests to XtremIO
Function Get-XtremAuthHeader([string]$username,[string]$password){
 
  $basicAuth = ("{0}:{1}" -f $username,$password)
  $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
  $basicAuth = [System.Convert]::ToBase64String($basicAuth)
  $headers = @{Authorization=("Basic {0}" -f $basicAuth)}

  return $headers
 
}

#Returns XtremIO Cluster Name
Function Get-XtremClusterName ([string]$xioname,[object]$header){

  if($global:XtremUsername){
  $username = $global:XtremUsername
  $xioname = $global:XtremName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }
  
  $clustername = (Invoke-RestMethod -Uri https://$xioname/api/json/types/clusters -Headers $header -Method Get).clusters.name
  return $clustername 
 
}




######### ETC #########

Function Get-XtremErrorMsg([AllowNull()][object]$errordata){   
    $ed = $errordata
    
  try{ 
    $ed = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($ed)
    $responseBody = $reader.ReadToEnd(); 
    $errorcontent = $responseBody | ConvertFrom-Json
    $errormsg = $errorcontent.message

    Write-Host -ForegroundColor Red $errormsg
    return $errorcontent
    
    }
   catch{
    Write-Host ""
    Write-Host -ForegroundColor Red "Error: XtremIO name or IP not resolveable. It may have been mistyped. This may also indicate that you have not properly imported the XtremIO certificate."
    
   } 
  
}

#Defines global username, password, and hostname/ip for PS session 
function New-XtremSession([string]$xioname,[string]$username,[string]$password,[string]$credlocation) {

   <#
     .DESCRIPTION
      Defines global variables (IP/hostname, username, and password) so they do not have to be explicitly defined for subsequent calls.
      If you do not define any switches, New-XtremSession will prompt you for credentials. This is best for an interactive session.
      When automating, it is best to run with switches at the beginning of scripts - I.E New-XtremSession -xioname name -username name -password pw.
      This will not prompt, and you can run other functions further down your script without explicitly sending credential arguments.

      .PARAMETER $xioname
      IP Address or hostname for XtremIO XMS. Optional if interactive prompts

      .PARAMETER $username
      Username for XtremIO XMS. Optional if interactive prompts

      .PARAMETER $password
      Password for XtremIO XMS. Optional if interactive prompts
      
      .PARAMETER $credlocation
      Specifies the location of stored credentials made using the New-XtremSecureCreds function. 

      .EXAMPLE
      New-XtremSession

      .EXAMPLE
      New-XtremSession -xioname 10.4.45.24 -username admin -password Xtrem10

      .EXAMPLE
      New-XtremSession -xioname 10.4.45.24 -credlocation C:\temp

  #>

    if($xioname){
      #secure creds have already been defined
      if($credlocation)
      { 
        $pwdlocation = $credlocation + "\xiopwd.txt"
        $userlocation = $credlocation + "\xiouser.txt"
        $global:XtremName = $xioname
        $global:XtremUsername = Get-Content $userlocation
        $global:XtremPassword = Get-Content $pwdlocation | ConvertTo-SecureString 

        Write-Host -ForegroundColor Green "Session variables set"
        return $true
      }
    
      #plain text creds have been defined as part of the command
      else{
        $global:XtremName = $xioname
        $global:XtremUsername = $username
        $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
        $global:XtremPassword =$securepassword
        
        Write-Host -ForegroundColor Green "Session variables set"
        return $true

      }
    
    }
   
    #else it's an interactive session
    else{
    $global:XtremName = Read-Host -Prompt "Enter XtremIO XMS Hostname or IP Address"
    $global:XtremUsername = Read-Host -Prompt "Enter XtremIO username"
    $global:XtremPassword = Read-Host -Prompt "Enter password" -AsSecureString
    }    
}

#Creates encrypted password files
function New-XtremSecureCreds([string] $path)
{

   <#
     .DESCRIPTION
      Creates secure credential files so that passwords are not stored in plain text in scripting environments
      
      .PARAMETER $path
      Specifies the location of stored credentials made using the New-XtremSecureCreds function. Do not put trailing '\'

      .EXAMPLE
      New-XtremSecureCreds -path C:\temp

  #>

  $pwdpath = $path + "\xiopwd.txt"
  $unamepath = $path + "\xiouser.txt"
  $creds = Get-Credential
  $creds.Username | Set-Content $unamepath
  $creds.Password | ConvertFrom-SecureString | Set-Content $pwdpath 

  Write-Host -ForegroundColor Green "Secure credentials set"

}


#Edits the Global XtremeName (IP/Hostname) variable
function Edit-XtremName([string] $xioname)
{

  <#
     .DESCRIPTION
      Edits the globally set hostname/IP

      .PARAMETER $xioname
      IP/hostname for XtremIO XMS. Optional if interactive prompts

      .EXAMPLE
      New-XtremName -xioname xtremlab

      .EXAMPLE
      New-XtremName -xioname 192.168.1.50

  #>

  if($xioname)
  {
   $global:XtremName = $xioname
   return

  }
  else{
   
   $global:XtremName = Read-Host -Prompt "Enter New XtremIO XMS Hostname or IP Address"

  }

}

#Edits the Global XtremeUserName variable
function Edit-XtremUsername([string] $username)
{

  <#
     .DESCRIPTION
      Edits the globally set username

      .PARAMETER $username
      Username for XtremIO XMS. Optional if interactive prompts

      .EXAMPLE
      New-XtremName -xioname xtremlab

      .EXAMPLE
      New-XtremName -xioname 192.168.1.50

  #>

  if($username)
  {
   $global:XtremUsername = $username
   return

  }
  else{
   
   $global:XtremUsername = Read-Host -Prompt "Enter New XtremIO Username"

  }

}

#Edits the Global password variable
function Edit-XtremPassword()
{

  <#
     .DESCRIPTION
      Edits the globally set password and stores as secure string. Only interactive.

      .EXAMPLE
      New-XtremPassword

  #>
 
   $global:XtremPassword = Read-Host -Prompt "Enter New XtremIO Password" -AsSecureString

  

}
#Clears all globally set parameters
function Remove-XtremSession(){

  <#
     .DESCRIPTION
      Clears the globally set credentials. Use at the end of a session or automation script. Takes no args. 

      .EXAMPLE
      Remove-XtremSession
  #>

  $global:XtremUsername =$null
  $global:XtremPassword =$null
  $global:XtremName =$null


}
#Returns Get-Help for all 
function Get-XtremHelp(){

  <#
     .DESCRIPTION
      Returns Get-Helps for all supported commands, as well as other help information 

      .EXAMPLE
      Get-XtremHelp

  #>
  Write-Host -ForegroundColor Green "Thanks for using xtremlib. Begin by setting global credentials using New-XtremSession, then run other commands without defining credentials or XMS IP/name"
  Write-Host ""
  Write-Host -ForegroundColor Green "GENERAL AND SESSION COMMANDS"
  Write-Host ""
  Get-Help New-XtremSession
  Get-Help Edit-XtremName
  Get-Help Edit-XtremUsername
  Get-Help Edit-XtremPassword
  Get-Help Remove-XtremSession
  Get-Help Get-XtremClusterStatus 
  Write-Host ""
  Write-Host -ForegroundColor Green "VOLUME, SNAPSHOT, AND MAPPING COMMANDS"
  Write-Host ""
  Get-Help Get-XtremVolumes
  Get-Help Get-XtremVolumeInfo
  Get-Help New-XtremVolume
  Get-Help Edit-XtremVolume
  Get-Help Remove-XtremVolume
  Get-Help Get-XtremSnapshots
  Get-Help New-XtremSnapshot
  Get-Help Remove-XtremSnapshot
  Get-Help Get-XtremVolumeMappingInfo
  Get-Help New-XtremVolumeMapping
  Get-Help Remove-XtremVolumeMapping
  Get-Help Get-XtremVolumeFolders
  Get-Help Get-XtremVolumeFolderInfo
  Get-Help New-XtremVolumeFolder
  Get-Help Get-XtremIGFolders
  Get-Help Get-XtremIGFolderInfo
  Get-Help New-XtremIGFolder
  Get-Help Get-XtremInitiators
  Get-Help Get-XtremInitiatorInfo
  Get-Help New-XtremInitiator
  Get-Help Get-XtremInitiatorGroups
  Get-Help Get-XtremInitiatorGroupInfo
  Get-Help New-XtremInitiatorGroup
  #Get-Help Edit-XtremInitiatorGroup
  Get-Help Remove-XtremInitiatorGroup


}




