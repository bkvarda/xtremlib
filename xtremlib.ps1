<#
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This is currently incomplete, I intend to include most API functionality as well as make content more presentable

#TODO
 -Lots
 -Implement token-based security
 -Implement all basic storage creation/setting commands
 -Implement snapshot commands
 -Implement error handling logic

Written by : Brandon Kvarda
             @bjkvarda
             

#>

######### GLOBAL VARIABLES #########



######### GET/INFORMATIONAL COMMANDS ##########

#Returns XtremIO Cluster Name
Function Get-XtremClusterName ([string]$xioip,[string]$username,[string]$password)
{
  $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioip
  
  if($header -eq "failed"){
    return
  }
  else{
    $format = @{Expression={$._clusters};Label="System Name"}

    $clustername = (Invoke-RestMethod -Uri https://$xioip/api/json/types/clusters -Headers $header -Method Get).clusters.name
    Write-Host ""
    Write-Host -ForegroundColor Green "XtremIO Cluster Name: $clustername"
  }
}

#Returns information about StorageController
Function Get-XtremStorageControllers ([string]$xioname,[Parameter(Mandatory=$true)][string]$controllername,[string]$username,[string]$password)
{
  $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

  if($header -eq "failed"){
    return
  }
  
  else{
  $uri = "https://"+$xioname+"/api/json/types/storage-controllers/?name="+$controllername

  (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
  }
}
 

#Returns Various XtremIO Statistics
Function Get-XtremClusterStatus ([string]$xioname,[string]$username,[string]$password)
{
  $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

  if($header -eq "failed"){
    return
  }
  
  else{

  $uri = "https://"+$xioname+"/api/json/types/clusters/?name="+$xioname
  $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content
 
  $numvols = $data.'num-of-vols'
  $usedcap = $data.'ud-ssd-space-in-use'

  $format =`
@{Expression={$data.name};Label="System Name";width=11;alignment="Center"},
@{Expression={$data.'sys-psnt-serial-number'};Label="Serial Number";width=14;alignment="Center"}, `
@{Expression={$data.'sys-health-state'};Label="Health Status";width=13;alignment="Center"},
@{Expression={$data.'num-of-bricks'};Label="Bricks";width=7;alignment="Center"},
@{Expression={$data.'dedup-ratio-text'};Label="Dedupe Ratio";width=12;alignment="Center"},
@{Expression={$data.'num-of-vols'};Label="# of Volumes";width=12;alignment="Center"},
@{Expression={$data.iops};Label="IOPS";width=10}

  $data | Format-Table $format

  
 }            

}

#Returns Volume Information
Function Get-XtremClusterVolumes([string]$xioname,[string]$username,[string]$password)
{


}

#Returns Snapshot Information
Function Get-XtremClusterSnapshots([string]$xioname,[string]$username,[string]$password)
{



}

#Returns Initiator Information
Function Get-XtremClusterInitiators([string]$xioname,[string]$username,[string]$password)
{


}


######### ACTION COMMANDS #########

#Creates a Volume
Function Create-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize)
{
  $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

  if($header -eq "failed"){
    return
  }
  
  else{
  $body = @"
  {
     "vol-name":"$volname",
      "vol-size":"$volsize"
  }
"@
  
  $uri = "https://"+$xioname+"/api/json/types/volumes/"
  Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body 
  }
}

#Deletes a Volume
Function Remove-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname)
{
 $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

 if($header -eq "failed"){
    return
  }
  
 else{
 $uri = "https://"+$xioname+"/api/json/types/volumes/?name="+$volname
  
  $result = try{
    Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
    Write-Host ""
    Write-Host -ForegroundColor Green  "Volume ""$volname"" was successfully deleted"
  }
  catch{
    $result = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $responseBody = $reader.ReadToEnd(); 
    $errormsg = $responseBody | ConvertFrom-Json

    if($errormsg.message = "vol_obj_not_found")
    {
     Write-Host ""
     Write-Host -ForegroundColor Red "The volume name ""$volname"" does not exist"
    }
        
  }
 }
}

#Creates a Snapshot of a Volume
Function Create-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$snapname){

 $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname
 
 if($header -eq "failed"){
    return
  }

else
 {
  $body = @"
  {
    "ancestor-vol-id":"$volname",
    "snap-vol-name":"$snapname"
  }
"@
 
     $uri = "https://"+$xioname+"/api/json/types/snapshots/"
    Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
  }


}



#Deletes an XtremIO Snapshot
Function Remove-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$snapname)
{
 $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

 if($header -eq "failed"){
    return
  }

 else{
 $uri = "https://"+$xioname+"/api/json/types/snapshots/?name="+$snapname
    
    try{
     Invoke-RestMethod -Uri $uri -Headers $header -Method Delete
    }
    catch{
     Write-Host ""
     Write-Host -ForegroundColor Red "Error: Could not delete snapshot. Ensure that the snapshot name ""$snapname"" is correct and/or exists and try again"
    }
 }
}


#Maps volume to initiator group
Function Map-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$initgroup)
{
 $header = Get-XtremAuthHeader -username $username -password $password -xioname $xioname

 if($header -eq "failed"){
    return
  }

 else{
 $body = @"
 {
   "vol-id":"$volname",
   "ig-id":"$initgroup"
 }
"@
 }
 $uri = "https://"+$xioname+"/api/json/types/lun-maps/"
 Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body

}



######### REQUEST HELPERS #########


#Generates Header to be used in requests to XtremIO
Function Get-XtremAuthHeader([string]$username,[string]$password,[string]$xioname)
{
 
  $basicAuth = ("{0}:{1}" -f $username,$password)
  $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
  $basicAuth = [System.Convert]::ToBase64String($basicAuth)
  $headers = @{Authorization=("Basic {0}" -f $basicAuth)}
  $authstate = @()
  $validate = Verify-XtremCreds -headers $headers -xioname $xioname
  
  if($validate){
   return $headers
  } 
  else{
   return "failed"
  }
 
}

Function Verify-XtremCreds([hashtable]$headers,[string]$xioname)
{   
    $uri = "https://$xioname/api/json/types/"
    $header = $headers
    

    try{ 
      Invoke-RestMethod -Uri $uri -Headers $header -Method Get
      $true
     } 
    catch{
     
      Write-Host ""
      Write-Host -ForegroundColor Red "Invalid credentials, cluster domain name, or IP address"
      $false

    }

}

######### ETC #########

Function Get-XtremCommands()
{



}

