<#
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This is currently incomplete, I intend to include most API functionality as well as make content more presentable

#TODO


Written by : Brandon Kvarda
             @bjkvarda
             

#>

#########DISABLE CERT VALIDATION####
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

######### GLOBAL VARIABLES #########
$global:XtremUsername =$null
$global:XtremPassword =$null
$global:XtremName =$null
$global:XtremClusterName = $null

######### SYSTEM COMMANDS ##########


#Returns Various XtremIO Statistics
Function Get-XtremCluster
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

  [cmdletbinding()]
Param (
    [parameter()]
    [string]$XmsName,
    [parameter(Mandatory=$true,Position=0)]
    [string]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [Parameter()]
    [String]$Password,
    [Parameter()]
    [String[]]$Properties

  )
  
  $Route = '/types/clusters/'
  $GetProperty = 'name='+$XtremioName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties   

}


######### VOLUME AND SNAPSHOT COMMANDS #########

#Returns List of Volumes
Function Get-XtremVolumes{

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

  [cmdletbinding()]
Param(
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [String]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter()]
    [string]$Password,
    [parameter()]
    [string[]]$Properties
  )
    
    $Route = '/types/volumes'
 
    $ObjectSelection = 'volumes'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremVolume{
  
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
      Get-XtremVolume -volname testvol

      .EXAMPLE
      Get-XtremVolume -xioname 10.4.45.24 -username admin -password Xtrem10 -volname testvol

  #>

  [cmdletbinding()]
Param (
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [string]$XtremioName,
    [parameter()]
    [string]$Username,
    [parameter(Mandatory=$true,Position=0)]
    [string]$VolumeName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/volumes/'
  $GetProperty = 'name='+$VolumeName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

#Creates a Volume. If no folder specified, defaults to root. 
Function New-XtremVolume{

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
[CmdletBinding()]

Param(
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$XtremioName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
[Alias('name')]
[String]$VolumeName,
[Parameter(Mandatory=$true,Position=1)]
[String]$VolumeSize
)

   $Route = '/types/volumes'
   $Body = @"
   {
      "vol-name":"$VolumeName",
      "vol-size":"$VolumeSize"
   }
"@
   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
  

}

#Modify a Volume 
Function Edit-XtremVolume{

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
  
  [CmdletBinding()]

Param(
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$XtremioName = $global:XtremClusterName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
[Alias('name')]
[String]$VolumeName,
[Parameter(Mandatory=$true)]
[ValidateSet('vol-size','vol-name','small-io-alerts','unaligned-io-alerts','vaai-tp-alerts')]
[String]$ParameterToModify,
[Parameter(Mandatory=$true)]
[String]$NewValue
)

   
   

   $Route = '/types/volumes'
   $GetProperty = 'name='+$VolumeName


   $Body = @"
   {
      
      "cluster-id":"$XtremioName",
      "$ParameterToModify":"$NewValue"
   }
"@
   $ObjectSelection = 'content'

  New-XtremRequest -Method PUT -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty 


}

#Deletes a Volume
Function Remove-XtremVolume{

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

  [CmdletBinding()]
  
  Param(
  [Parameter()]
  [String]$XmsName,
  [Parameter()]
  [String]$XtremioName,
  [Parameter()]
  [String]$Username,
  [Parameter()]
  [String]$Password,
  [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
  [Alias('name')]
  [String]$VolumeName
  
  )

  $Route = '/types/volumes/'
  $GetProperty = 'name='+$VolumeName
  
 
  New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
}

#Returns List of Snapshots
Function Get-XtremSnapshots{

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
 
 [cmdletbinding()]
Param(
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [String]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter()]
    [string]$Password,
    [parameter()]
    [string[]]$Properties
  )
    
    $Route = '/types/snapshots'
 
    $ObjectSelection = 'snapshots'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Creates a Snapshot of a Volume
Function New-XtremSnapshot{

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

[CmdletBinding()]

Param(
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$XtremioName = $global:XtremClusterName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true)]
[ValidateSet('tag-list','volume-list','consistency-group-id','snapshot-set-id')]
[String]$ParentType,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
[Alias('name')]
[String[]]$ParentNames,
[Parameter(Mandatory=$true)]
[String]$SnapshotSetName
)

   $Route = '/types/snapshots'
   $ParentNames = ($ParentNames | ConvertTo-Json).ToString()

   $Body = @"
   {
      "$ParentType":$ParentNames,
      "snapshot-set-name":"$SnapshotSetName",
      "cluster-id":"$XtremioName"
   }
"@
   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
}

#Creates a Snapshot of a Volume
Function New-XtremSnapshotRefresh{

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

[CmdletBinding()]

Param(
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$XtremioName = $global:XtremClusterName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true)]
[ValidateSet('from-volume-id','from-consistency-group-id','from-snapshot-set-id')]
[String]$ParentType,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
[Alias('name')]
[String]$ParentName,
[Parameter(Mandatory=$true)]
[ValidateSet('to-volume-id','to-consistency-group-id','to-snapshot-set-id')]
[String]$RefreshType,
[Parameter(Mandatory=$true)]
[String]$RefreshName,
[Parameter(Mandatory=$true)]
[String]$NewName,
[Parameter()]
[ValidateSet('true','false')]
[String]$DeleteOriginal = 'false'
)

   $Route = '/types/snapshots'
  

   $Body = @"
   {
      "$ParentType":"$ParentName",
      "cluster-id":"$XtremioName",
      "$RefreshType":"$RefreshName",
      "snapshot-set-name": "$NewName"
   }
"@
   

   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
}

Function Remove-XtremSnapshot{

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

  [CmdletBinding()]
  
  Param(
  [Parameter()]
  [String]$XmsName,
  [Parameter()]
  [String]$XtremioName,
  [Parameter()]
  [String]$Username,
  [Parameter()]
  [String]$Password,
  [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
  [Alias('name')]
  [String]$SnapshotName
  
  )

  $Route = '/types/snapshots'
  $GetProperty = 'name='+$SnapshotName
  
 
  New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
}

#Returns List of Snapshots
Function Get-XtremSnapshotSets{

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
 
 [cmdletbinding()]
Param(
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [String]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter()]
    [string]$Password,
    [parameter()]
    [string[]]$Properties
  )
    
    $Route = '/types/snapshot-sets'
 
    $ObjectSelection = 'snapshot-sets'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Returns List of Snapshots
Function Get-XtremSnapshotSet{

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
 
 [cmdletbinding()]
Param(
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [String]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter()]
    [string]$Password,
    [parameter(Mandatory=$true,Position=0)]
    [string]$SnapshotSetName,
    [parameter()]
    [string[]]$Properties
  )
    
    $Route = '/types/snapshot-sets'
 
    $ObjectSelection = 'content'

    $GetProperty = 'name='+$SnapshotSetName

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty

}

Function Remove-XtremSnapshotSet{

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

  [CmdletBinding()]
  
  Param(
  [Parameter()]
  [String]$XmsName,
  [Parameter()]
  [String]$XtremioName,
  [Parameter()]
  [String]$Username,
  [Parameter()]
  [String]$Password,
  [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
  [Alias('name')]
  [String]$SnapshotSetName
  
  )

  $Route = '/types/snapshot-sets'
  $GetProperty = 'name='+$SnapshotSetName
  
 
  New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
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
   
   }
}

#Returns info for a specific XtremIO Initiator
Function Get-XtremInitiator([string]$xioname,[string]$username,[string]$password,[string]$initiatorname){

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
      Get-XtremInitiator -initiatorname testinit1

      .EXAMPLE
      Get-XtremInitiator -xioname 10.4.45.24 -username admin -password Xtrem10 -initiatorname testinit1

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
   
   }

}

#Returns info for a specific XtremIO initiator group
Function Get-XtremInitiatorGroup([string]$xioname,[string]$username,[string]$password,[string]$igname){

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
      Get-XtremInitiatorGroup -igname testig

      .EXAMPLE
      Get-XtremInitiatorGroup -xioname 10.4.45.24 -username admin -password Xtrem10 -igname testig

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
   
   }

}

######### TARGET INFO COMMANDS #########




######### VOLUME MAPPING COMMANDS #########

#Returns list of volume mapping names
Function Get-XtremVolumeMappings{
[CmdletBinding()]

Param(
[Parameter()]
[string]$xioname,
[Parameter()]
[string]$username,
[Parameter()]
[string]$password
)

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
   
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method GET).'lun-maps'
    $list = @()
    
    Write-Host "Collecting data for all volumes, this may take some time depending on the number of volumes..."

    ForEach ($mapping in $data){
     $mapname = $mapping.name
     
     $uri = "https://$xioname/api/json/types/lun-maps/?name=$mapname"

     $mapdata = (Invoke-RestMethod -Uri $uri -Headers $header -Method GET).content
     
     $mapobject = New-Object System.Object
     
     $mapobject | Add-Member -type NoteProperty -name 'Volume Name' -Value $mapdata.'vol-name'
     $mapobject | Add-Member -type NoteProperty -name 'Host (IG)' -Value $mapdata.'ig-name'
     $list += $mapobject
    } 
    $list
    
    
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   
   }
 $result |Sort-Object 'Host (IG)' | Format-Table -AutoSize

}

#Returns Volumes mapped by Initiator group/hostname
Function Get-XtremVolumeMapping([string]$xioname,[string]$username,[string]$password,[string]$igname){

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
      Get-XtremVolumeMapping -igname testig

      .EXAMPLE
      Get-XtremVolumeMapping -xioname 10.4.45.24 -username admin -password Xtrem10 -igname testig

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
   
   }

}

#Maps volume to initiator group
Function New-XtremVolumeMapping([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$igname,[string]$lunid){

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

      .PARAMETER $lunid
      LUN # you want the volume mapped to have on the host

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
  if($lunid){
  $body = @"
    {
    "vol-id":"$volname",
    "ig-id":"$igname",
    "lun":"$lunid"
    }
"@

  }
  else{
    $body = @"
    {
    "vol-id":"$volname",
    "ig-id":"$igname"
    }
"@
  }
    $uri = "https://$xioname/api/json/types/lun-maps/"
    $data = (Invoke-RestMethod -Uri $uri -Headers $header -Method Post -Body $body)
    Write-Host ""
    Write-Host -ForegroundColor Green "Volume ""$volname"" successfully mapped to initiator group ""$igname"""
    
    return (Invoke-RestMethod -Uri $data.links.href -Headers $header -Method Get).content
    }

   catch{
       $error = (Get-XtremErrorMsg -errordata  $result) 
        Write-Error $error
        
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
    $volid = (Get-XtremVolume -xioname $xioname -volname $volname -username $username -password $password).index
    $igid = (Get-XtremInitiatorGroup -xioname $xioname -username $username -password $password -igname $igname).index
    $tgid = "1"
    $mapname = "$volid"+"_"+"$igid"+"_"+"$tgid"
    $header = Get-XtremAuthHeader -username $username -password $password 
    $uri = "https://$xioname/api/json/types/lun-maps/?name=$mapname"
    $request = (Invoke-RestMethod -Uri $uri -Headers $header -Method DELETE)

    Write-Host ""
    Write-Host -ForegroundColor Green "Successfully deleted mapping of volume ""$volname"" from host/ig ""$igname"""
    return $true
   }
   catch{
   $error = (Get-XtremErrorMsg -errordata  $result) 
   Write-Error $error
   
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
Function Get-XtremClusterNames{
[CmdletBinding()]
Param(
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter()]
[String[]]$Properties
)

  $Route = '/types/clusters'
  $ObjectSelection = 'clusters'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -Properties $Properties
  
 
}

#Builds the REST request
Function New-XtremRequest {
[cmdletbinding()]
Param(
[Parameter(Mandatory=$true)]
[ValidateSet('GET','PUT','POST','DELETE')]
[String]$Method,
[Parameter(Mandatory=$true)]
[String]$Endpoint,
[Parameter()]
[String]$XmsName,
[Parameter()]
[String]$XtremioName,
[Parameter()]
[Array]$Body,
[Parameter()]
[String[]]$Properties = $null,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter()]
[String]$ObjectSelection = '',
[Parameter()]
[String]$GetProperty = $null
)

  ##Set up variables
  #If there is a global Username set, use the globals

  if($global:XtremUsername){
  $Username = $global:XtremUsername
  $XmsName = $global:XtremName
  $XtremioName = $global:XtremClusterName
  $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($global:XtremPassword)
  $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
  }

$result = try{    
                  ##Construct Auth Header and full URI
                  $BaseUri = "https://$XmsName/api/json/v2"
                  $Header = Get-XtremAuthHeader -username $username -password $password
                  
                  $PropertyString = ''
                  $ClusterString = '' 

                  

                        #If properties were specified, builds a string for querying those
                       if($Properties){
                        Foreach($Property in $Properties){
                          if($Property -eq $Properties[($Properties.Length -1)]){
                       
                            $PropertyString += 'prop=' + $Property 

                          }
                          else{
                           $PropertyString += 'prop='+ $Property + '&'
                          }
                    
                        }
                       }
                       else{
                         $PropertyString = $null
                       }
                      #If a cluster name was specified, builds a string for that
                      if($XtremioName -and ($Method -eq 'GET' -or $Method -eq 'DELETE')){

                       

                          $ClusterString = 'cluster-name='+$XtremioName

                        
                      }
                      else{

                        $ClusterString = $null 
                      }

                  
                  if($PropertyString){

                    $PropertyString = 'full=1&'+$PropertyString

                  }

           
                  #We now have a property string <if there are properties> and cluster name <if specified>, and a GET property <if specified> we need to build a full URI
                  
                  if($GetProperty -and $ClusterString -and $PropertyString){
                   
                    $Uri = $BaseUri + $Endpoint +'?'+$GetProperty+'&'+$ClusterString+'&'+$PropertyString 
                  }
                  elseif($GetProperty -and $ClusterString -and !$PropertyString){
                    
                    $Uri = $BaseUri + $Endpoint + '?'+$GetProperty+'&'+$ClusterString
                  }
                  elseif($GetProperty -and $PropertyString -and !$ClusterString){

                    $Uri = $BaseUri + $Endpoint + '?'+ $GetProperty + '&' + $PropertyString

                  }
                  elseif($GetProperty -and !$PropertyString -and !$ClusterString){

                    $Uri = $BaseUri + $Endpoint + '?' + $GetProperty

                  }
                  elseif(!$GetProperty -and $PropertyString -and $ClusterString){

                    $Uri = $BaseUri + $Endpoint + '?' + $ClusterString + '&' + $PropertyString

                  }
                  elseif(!$GetProperty -and !$PropertyString -and $ClusterString){

                    $Uri = $BaseUri + $Endpoint + '?' + $ClusterString

                  }
                  elseif(!$GetProperty -and $PropertyString -and !$ClusterString){

                    $Uri = $BaseUri + $Endpoint + '?' + $PropertyString 

                  }
                  else{
                    
                    $Uri = $BaseUri + $Endpoint 

                  }


                   Write-Host $Uri 
                  
                 
                  
                  ##Do this for GET Requests
                  if($Method -eq 'GET'){
                    
                    (Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Header).$ObjectSelection
       
                  }

                  ##Do this for POST Requests
                  if($Method -eq 'POST'){

                    $data = (Invoke-RestMethod -Method $Method -Uri $Uri -Body $Body -Headers $Header)

                    $href = $data.links.href
                    Write-Host $data
                    Write-Host $href
                    #Sometimes there are more than one object being created, so we'll return them all in an array
                    if($href.count -gt 1){
                      
                      $arr = @()

                      For($i = 0; $i -lt $href.count; $i++){
                        Write-Host $href[$i]
                        $tmp = (Invoke-RestMethod -Method GET -Uri $href[$i] -Headers $Header).$ObjectSelection
                        Write-Host $tmp 
                        $arr += $tmp 
                      }

                      $arr
                    }

                    else{                  

                    
                    (Invoke-RestMethod -Method GET -Uri $href -Headers $Header).$ObjectSelection
                   }

                  }

                  ##Do this for PUT Requests
                  if($Method -eq 'PUT'){

                    $req = (Invoke-WebRequest -Method $Method -Uri $Uri -Headers $Header -Body $Body)

                    if($req.StatusCode -eq 200){

                      Write-Host -ForegroundColor Green "Request Successful"
                      $true

                    }

                    

                  }

                  ##Do this for DELETE Requests
                  if($Method -eq 'DELETE'){

                    $req = (Invoke-WebRequest -Method $Method -Uri $Uri -Headers $Header)

                    if($req.StatusCode -eq 200){

                      Write-Host -ForegroundColor Green "Delete Request Successful"
                      $true


                  }
                }
            }
            catch{

              Get-XtremErrorMsg -errordata $result


            }

  $result 

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
function New-XtremSession([string]$XtremioName,[string]$XmsName, [string]$Username, [string]$Password, [string]$CredLocation) {

   <#
     .DESCRIPTION
      Defines global variables (IP/hostname, username, and password) so they do not have to be explicitly defined for subsequent calls.
      If you do not define any switches, New-XtremSession will prompt you for credentials. This is best for an interactive session.
      When automating, it is best to run with switches at the beginning of scripts - I.E New-XtremSession -xioname name -username name -password pw.
      This will not prompt, and you can run other functions further down your script without explicitly sending credential arguments.

      .PARAMETER $XmsName
      IP Address or hostname for XtremIO XMS. Optional if interactive prompts

      .PARAMETER $XtremioName
      Name of the XtremIO you are sending the command to. This is new in 4.0 as XMS can manage multiple systems

      .PARAMETER $Username
      Username for XtremIO XMS. Optional if interactive prompts

      .PARAMETER $Password
      Password for XtremIO XMS. Optional if interactive prompts
      
      .PARAMETER $CredLocation
      Specifies the location of stored credentials made using the New-XtremSecureCreds function. 

      .EXAMPLE
      New-XtremSession

      .EXAMPLE
      New-XtremSession -XmsName 10.4.45.24 -XtremioName cluster01 -Username admin -Password Xtrem10

      .EXAMPLE
      New-XtremSession -XmsName 10.4.45.24 -XtremioName cluster01 -credlocation C:\temp

  #>

    if($XmsName){
      #secure creds have already been defined
      if($CredLocation)
      { 
        $pwdlocation = $credlocation + "\xiopwd.txt"
        $userlocation = $credlocation + "\xiouser.txt"
        $global:XtremName = $XmsName
        $global:XtremClusterName = $XtremioName
        $global:XtremUsername = Get-Content $userlocation
        $global:XtremPassword = Get-Content $pwdlocation | ConvertTo-SecureString 

        Write-Host -ForegroundColor Green "Session variables set"
        return $true
      }
    
      #plain text creds have been defined as part of the command
      else{
        $global:XtremName = $XmsName
        $global:XtremUsername = $Username
        $global:XtremClusterName = $XtremioName
        $securepassword = ConvertTo-SecureString $password -AsPlainText -Force
        $global:XtremPassword =$securepassword
        
        Write-Host -ForegroundColor Green "Session variables set"
        return $true

      }
    
    }
   
    #else it's an interactive session
    else{
    $global:XtremName = Read-Host -Prompt "Enter XtremIO XMS Hostname or IP Address"
    $global:XtremClusterName = Read-Host -Prompt "Enter XtremIO Cluster name"
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
  $global:XmsName = $null


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
  Get-Help Get-XtremVolume
  Get-Help New-XtremVolume
  Get-Help Edit-XtremVolume
  Get-Help Remove-XtremVolume
  Get-Help Get-XtremSnapshots
  Get-Help New-XtremSnapshot
  Get-Help Remove-XtremSnapshot
  Get-Help Get-XtremVolumeMapping
  Get-Help New-XtremVolumeMapping
  Get-Help Remove-XtremVolumeMapping
  Get-Help Get-XtremVolumeFolders
  Get-Help Get-XtremVolumeFolder
  Get-Help New-XtremVolumeFolder
  Get-Help Get-XtremIGFolders
  Get-Help Get-XtremIGFolder
  Get-Help New-XtremIGFolder
  Get-Help Get-XtremInitiators
  Get-Help Get-XtremInitiator
  Get-Help New-XtremInitiator
  Get-Help Get-XtremInitiatorGroups
  Get-Help Get-XtremInitiatorGroup
  Get-Help New-XtremInitiatorGroup
  #Get-Help Edit-XtremInitiatorGroup
  Get-Help Remove-XtremInitiatorGroup


}




