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


### GET/INFORMATION COMMANDS ###

#Returns XtremIO Cluster Name
Function Get-XtremClusterName ([string]$xioname,[string]$username,[string]$password)
{
  $header = Get-XtremAuthHeader -username $username -password $password
  $format = @{Expression={$._clusters};Label="System Name"}

  (Invoke-RestMethod -Uri https://$xioname/api/json/types/clusters -Headers $header -Method Get).clusters

}

#Returns information about StorageController
Function Get-XtremStorageControllers ([string]$xioname,[string]$controllername,[string]$username,[string]$password)
{

  $header = Get-XtremAuthHeader -username $username -password $password
  $uri = "https://"+$xioname+"/api/json/types/storage-controllers/?name="+$controllername

  (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content

}
 

#Returns Various XtremIO Statistics
Function Get-XtremClusterStatus ([string]$xioname,[string]$username,[string]$password)
{
  $header = Get-XtremAuthHeader -username $username -password $password
  $uri = "https://"+$xioname+"/api/json/types/clusters/?name="+$xioname

  (Invoke-RestMethod -Uri $uri -Headers $header -Method Get).content                                   

}


### ACTION COMMANDS ###

#Creates a Volume
Function Create-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize)
{
  $header = Get-XtremAuthHeader -username $username -password $password
  
  $body = @"
  {
     "vol-name":"$volname",
      "vol-size":"$volsize"
  }
"@
  
  $uri = "https://"+$xioname+"/api/json/types/volumes/"
  Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body
}

#Deletes a Volume
Function Remove-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname)
{
 $header = Get-XtremAuthHeader -username $username -password $password
 $uri = "https://"+$xioname+"/api/json/types/volumes/?name="+$volname
 Invoke-RestMethod -Uri $uri -Headers $header -Method Delete

}


### REQUEST HELPERS ###


#Generates Header to be used in requests to XtremIO
Function Get-XtremAuthHeader([string]$username,[string]$password)
{
  
  $basicAuth = ("{0}:{1}" -f $username,$password)
  $basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
  $basicAuth = [System.Convert]::ToBase64String($basicAuth)
  $headers = @{Authorization=("Basic {0}" -f $basicAuth)}

  return $headers

}

