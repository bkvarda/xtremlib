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



######### SYSTEM COMMANDS ##########


#Returns Various XtremIO Statistics
Function Get-XtremClusterStatus ([string]$xioname,[string]$username,[string]$password)
{
 $result=
  try{
    $header = Get-XtremAuthHeader -username $username -password $password
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/clusters/?name=$formattedname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content

    $format =`
    @{Expression={$data.name};Label="System Name";width=11;alignment="Center"},
    @{Expression={$data.'sys-psnt-serial-number'};Label="Serial Number";width=14;alignment="Center"}, `
    @{Expression={$data.'sys-health-state'};Label="Health Status";width=13;alignment="Center"},
    @{Expression={$data.'sys-sw-version'};Label="SW Version";width=10;alignment="Center"},
    @{Expression={$data.'num-of-bricks'};Label="Bricks";width=7;alignment="Center"},
    @{Expression={$data.'dedup-ratio-text'};Label="Dedupe Ratio";width=12;alignment="Center"},
    @{Expression={[decimal]::round(($data.'space-in-use')/1048576)};Label="Phys Capacity Used (GB)";width=24;alignment="Center"},
    @{Expression={[decimal]::round(($data.'logical-space-in-use')/1048576)};Label="Log Capacity Used (GB)";width=23;alignment="Center"},
    @{Expression={$data.'num-of-vols'};Label="# of Volumes";width=12;alignment="Center"},
    @{Expression={$data.iops};Label="IOPS";width=10}

    return $data | Format-Table $format
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }          

}

#Returns list of recent system events
Function Get-XtremEvents([string]$xioname,[string]$username,[string]$password){

}


######### VOLUME AND SNAPSHOT COMMANDS #########

#Returns List of Volumes
Function Get-XtremVolumes([string]$xioname,[string]$username,[string]$password){
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/volumes"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get)

    return $data.volumes | Select-Object @{Name="Volume Name";Expression={$_.name}} 
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremVolumeInfo([string]$xioname,[string]$username,[string]$password,[string]$volname){
    
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/volumes/?name=$volname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
    $hosts = @()
    
    $i = 0
    while($i -lt $data.'lun-mapping-list'.Count)
    {
      $hosts = $hosts + $data.'lun-mapping-list'[$i][0][1]
      $i++
    }
    
        $format =`
    @{Expression={$data.name};Label="Volume Name";width=15;alignment="Center"},
    @{Expression={[decimal]::round(($data.'vol-size')/1048576)};Label="Size (GB)";width=10;alignment="Center"}, `
    @{Expression={[decimal]::round(($data.'logical-space-in-use'))/1048576};Label="Logical Capacity Used (GB)";width=24;alignment="Center"},
    @{Expression={$data.index};Label="Volume ID";width=10;alignment="Center"},
    @{Expression={$data.iops};Label="IOPS";width=7;alignment="Center"},
    @{Expression={$data.'ancestor-vol-id' |Select-Object -Index 1 };Label="Parent Volume";width=15;alignment="Center"},
    @{Expression={$data.'creation-time'};Label="Time Created";width=20;alignment="Center"},
    @{Expression={$hosts};Label="Attached Hosts";width=100}
   
    return $data | Format-Table $format
  
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }  
    
}

#Creates a Volume
Function New-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize){
 $result=
  try{
   $header = Get-XtremAuthHeader -username $username -password $password 
   $formattedname = Get-XtremClusterName -xioname $xioname -header $header
   $body = @"
   {
      "vol-name":"$volname",
      "vol-size":"$volsize"
   }
"@
   $uri = "https://$xioname/api/json/types/volumes/"
   Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully create volume ""$volname"" with $volsize of capacity" 
  }
  catch{
   Get-XtremErrorMsg($result)
  }

}

#Modify a Volume 
Function Edit-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize){
  $result=
  try{
   $header = Get-XtremAuthHeader -username $username -password $password 
   $formattedname = Get-XtremClusterName -xioname $xioname -header $header
   $body = @"
   {
      "vol-name":"$volname",
      "vol-size":"$volsize"
   }
"@
   $uri = "https://$xioname/api/json/types/volumes/?name=$volname"
   Invoke-RestMethod -Uri $uri -Headers $header -Method Put -Body $body
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully modified volume ""$volname"" to have $volsize of capacity" 
  }
  catch{
   Get-XtremErrorMsg($result)
  }


}

#Deletes a Volume
Function Remove-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname){
 $result = try{
  $header = Get-XtremAuthHeader -username $username -password $password
  $formattedname = Get-XtremClusterName -xioname $xioname -header $header
  $uri = "https://$xioname/api/json/types/volumes/?name="+$volname
  Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
  Write-Host ""
  Write-Host -ForegroundColor Green  "Volume ""$volname"" was successfully deleted"
  }
  catch{
   Get-XtremErrorMsg -errordata  $result    
  }
 
}

#Returns List of Snapshots
Function Get-XtremSnapshots([string]$xioname,[string]$username,[string]$password){
 
 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/snapshots/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get)
    
    return $data.snapshots | Select-Object @{Name="Snapshot Name";Expression={$_.name}} 
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }

}

#Creates a Snapshot of a Volume
Function New-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$snapname){
$result =
 try{
 $header = Get-XtremAuthHeader -username $username -password $password
 $formattedname = Get-XtremClusterName -xioname $xioname -header $header
 $body = @"
  {
    "ancestor-vol-id":"$volname",
    "snap-vol-name":"$snapname"
  }
"@
  $uri = "https://$xioname/api/json/types/snapshots/"
  Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  Write-Host ""
  Write-Host -ForegroundColor Green "Snapshot of volume ""$volname"" with name ""$snapname"" successfully created"
  }
  catch{
    Get-XtremErrorMsg -errordata $result
  }
}

#Create Snapshots from a Folder
Function New-XtremSnapFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$snapfoldername){

}

#Create Snapshots of a set of Volumes
Function New-XtremSnapSet([string]$xioname,[string]$username,[string]$password,[string]$vollist,[string]$snaplist){

}


#Deletes an XtremIO Snapshot
Function Remove-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$snapname){
 $result = try{
      $header = Get-XtremAuthHeader -username $username -password $password
      $formattedname = Get-XtremClusterName -xioname $xioname -header $header
      $uri = "https://$xioname/api/json/types/snapshots/?name=$snapname"
      Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
      Write-Host ""
      Write-Host -ForegroundColor Green "Successfully deleted snapshot ""$snapname"""
      Write-Host ""
     }
     catch{
      Get-XtremErrorMsg -errordata $result
     }
}




######### VOLUME FOLDER COMMANDS#########

#Returns list of XtremIO Volume Folders
Function Get-XtremVolumeFolders([string]$xioname,[string]$username,[string]$password){

}

#Returns details of an XtremIO Volume Folder
Function Get-XtremVolumeFolderInfo([string]$xioname,[string]$username,[string]$password,[string]$foldername){

}

#Create a new Volume Folder
Function New-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername){

}

#Rename a Volume Folder
Function Edit-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername,[string]$changeto){

}

#Delete a Volume Folder
Function Remove-XtremVolumeFolder([string]$xioname,[string]$username,[string]$password,[string]$foldername){

}

######### INITIATOR COMMANDS #########

#Returns List of Initiators
Function Get-XtremClusterInitiators([string]$xioname,[string]$username,[string]$password){

   $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/initiators/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).initiators
    


    return $data | Select-Object @{Name="Initiator Name";Expression={$_.name}} 
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }
}

#Returns info for a specific XtremIO Initiator
Function Get-XtremInitiatorInfo([string]$xioname,[string]$username,[string]$password,[string]$initiatorname){
 $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/initiators/?name=$initiatorname"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
    
    $format =`
    @{Expression={$data.name};Label="Initiator Name";width=15;alignment="Center"},
    @{Expression={$data.'port-address'};Label="Address";width=24;alignment="Center"}, `
    @{Expression={$data.'ig-id'[1]};Label="Initiator Group";width=24;alignment="Center"},
    @{Expression={$data.index};Label="Index";width=10;alignment="Center"}


    return $data |Format-Table $format
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }
}

#Creates initiator and adds to initiator group
Function New-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname,[string]$address,[string]$igname){
  
  $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/initiators/"
    $body = @"
   {
      "initiator-name":"$initiatorname",
      "port-address":"$address",
      "ig-id":"$igname"
   }
"@

   $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method POST -Body $body)
   Write-Host ""
   Write-Host -ForegroundColor Green "Successfully created initiator ""$initiatorname"" with address ""$address"" in initiator group ""$igname"""
   Write-Host ""
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }
}

#Modifies initiator
Function Edit-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname,[string]$address,[string]$igname){

}

#Deletes initiator
Function Remove-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname){

}

######### INITIATOR GROUP COMMANDS #########

#Returns list of XtremIO Initiator Groups
Function Get-XtremInitiatorGroups([string]$xioname,[string]$username,[string]$password){
    
     $result=
  try{  
    $header = Get-XtremAuthHeader -username $username -password $password 
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $uri = "https://$xioname/api/json/types/initiator-groups"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get)

    return $data.'initiator-groups' | Select-Object @{Name="Initiator Group/Hostname";Expression={$_.name}} 
   }
   catch{
    Get-XtremErrorMsg -errordata $result
   }

}

#Returns info for a specific XtremIO initiator group
Function Get-XtremInitiatorGroupInfo([string]$xioname,[string]$username,[string]$password,[string]$igname){

}

#Creates initiator group
Function New-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

}

#Modifies initiator group
Function Edit-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

}

#Deletes initiator group
Function Remove-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

}

######### TARGET INFO COMMANDS #########




######### VOLUME MAPPING COMMANDS #########

#Returns list of volume mappings
Function Get-XtremVolumeMappings([string]$xioname,[string]$username,[string]$password){

}

#Maps volume to initiator group
Function New-XtremVolumeMapping([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$initgroup){
$result=try{
    $header = Get-XtremAuthHeader -username $username -password $password
    $formattedname = Get-XtremClusterName -xioname $xioname -header $header
    $body = @"
    {
    "vol-id":"$volname",
    "ig-id":"$initgroup"
    }
"@
    $uri = "https://$xioname/api/json/types/lun-maps/"
    Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
    Write-Host ""
    Write-Host -ForegroundColor Green "Volume ""$volname"" successfully mapped to initiator group ""$initgroup"""
   }
   catch{
    Get-XtremErrorMsg($result)
   }  

}

#Removes volume mapping
Function Remove-XtremVolumeMappings([string]$xioname,[string]$username,[string]$password,[string]$mapname){

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
    Write-Host ""
    Write-Host -ForegroundColor Red "Error: $errormsg"
    }
   catch{
    Write-Host ""
    Write-Host -ForegroundColor Red "Error: XtremIO name not resolveable"

   } 
  
}

Function New-XtremSessionName($xioname){

}

Function New-XtremSessionCredential([string]$username,[string]$password){

}

Function Get-XtremCommands(){



}

