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
    [parameter(Position=0)]
    [string]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [Parameter()]
    [String]$Password,
    [Parameter()]
    [String[]]$Properties

  )
  
  $Route = '/types/clusters'
  $GetProperty = 'name='+$XtremioName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties   

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
[Parameter(Mandatory=$true,Position=1)]
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
   if($ParentNames.Count -eq 1){
     $ParentNames = '['+$ParentNames+']'
   }
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

######### TAG COMMANDS #########

Function Get-XtremTags{

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
    
    $Route = '/types/tags'
 
    $ObjectSelection = 'tags'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremTag{
  
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
    [string]$TagName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Volume','ConsistencyGroup','Snapshot','SnapshotSet','InitiatorGroup','Initiator','Scheduler')]
    [String]$ObjectType
  )
   
  $Route = '/types/tags'
  $GetProperty = 'name=/'+$ObjectType+'/'+$TagName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

#Creates a Volume. If no folder specified, defaults to root. 
Function New-XtremTag{

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
[Parameter(Mandatory=$true)]
[ValidateSet('Volume','ConsistencyGroup','Snapshot','SnapshotSet','InitiatorGroup','Initiator','Scheduler')]
[String]$ObjectType,
[Parameter(Mandatory=$True,Position=0)]
[String]$TagName
)

   $Route = '/types/tags'
   $Body = @"
   {
      "entity":"$ObjectType",
      "tag-name":"$TagName"
   }
"@
   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
  

}


#Deletes a Volume
Function Remove-XtremTag{

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
  [String]$TagName,
  [Parameter(Mandatory=$true)]
  [ValidateSet('Volume','ConsistencyGroup','Snapshot','SnapshotSet','InitiatorGroup','Initiator','Scheduler')]
  [String]$ObjectType
  
  )

  $Route = '/types/tags'
  $GetProperty = 'name='+'/'+$ObjectType+'/'+$TagName

 
  New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
}

#Creates a Volume. If no folder specified, defaults to root. 
Function Set-XtremTag{

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
[String]$XtremioName = $global:XtremClusterName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
[ValidateSet('Volume','ConsistencyGroup','Snapshot','SnapshotSet','InitiatorGroup','Initiator','Scheduler')]
[Alias('object-type')]
[String]$ObjectType,
[Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$true,Position=1)]
[Alias('caption')]
[String]$TagName,
[Parameter(Mandatory=$true, Position=0)]
[String]$ObjectName
)

   $Route = '/types/tags'
   
   $GetProperty = 'name='+'/'+$ObjectType+'/'+$TagName 
   $Body = @"
   {
      "entity":"$ObjectType",
      "entity-details":"$ObjectName",
      "cluster-id":"$XtremioName"

   }
"@
   

  New-XtremRequest -Method PUT -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -GetProperty $GetProperty
  

}




######### MAPPING COMMANDS #########

Function Get-XtremVolumeMappings{

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
    
    $Route = '/types/lun-maps'
 
    $ObjectSelection = 'lun-maps'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremVolumeMapping{
  
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
    [string]$XtremioName=$global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter(Mandatory=$true,Position=0)]
    [string]$MappingName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/lun-maps'
  $GetProperty = 'name='+$MappingName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

#Creates a Volume. If no folder specified, defaults to root. 
Function New-XtremVolumeMapping{

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
[String]$InitiatorGroupName,
[Parameter(Position=2)]
[String]$Lun
)

   $Route = '/types/lun-maps'

     if($Lun){

  $Body = @"
    {
    "vol-id":"$VolumeName",
    "ig-id":"$InitiatorGroupName",
    "lun":"$Lun"
    }
"@

  }
  else{
    $body = @"
    {
    "vol-id":"$VolumeName",
    "ig-id":"$InitiatorGroupName"
    }
"@
  }
   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
  

}



#Deletes a  mapping
Function Remove-XtremVolumeMapping{

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

  [cmdletbinding()]
Param (
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [string]$XtremioName=$global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter(Mandatory=$true,Position=0)]
    [string]$VolumeName,
    [parameter(Mandatory=$true,Position=1)]
    [string]$InitiatorGroupName,
    [parameter()]
    [string]$Password
  )
   
  $Route = '/types/lun-maps'

  $VolumeIndex = (Get-XtremVolume $VolumeName -Username $Username -Password $Password).index
  $InitiatorGroupIndex = (Get-XtremInitiatorGroup $InitiatorGroupName -Username $Username -Password $Password).index 

  $MappingName = "$VolumeIndex"+"_"+"$InitiatorGroupIndex"+"_1"

  $GetProperty = 'name='+$MappingName
  

 New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
}


######### INITIATOR COMMANDS #########

#Returns List of Volumes
Function Get-XtremInitiatorGroups{

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
    
    $Route = '/types/initiator-groups'
 
    $ObjectSelection = 'initiator-groups'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

#Returns Statistics for a Specific Volume or Snapshot
Function Get-XtremInitiatorGroup{
  
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
    [string]$InitiatorGroupName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/initiator-groups'
  $GetProperty = 'name='+$InitiatorGroupName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

#Creates a Volume. If no folder specified, defaults to root. 
Function New-XtremInitiatorGroup{

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
[String]$XtremioName = $global:XtremClusterName,
[Parameter()]
[String]$Username,
[Parameter()]
[String]$Password,
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
[Alias('name')]
[String]$InitiatorGroupName,
[Parameter(Position=1)]
[String[]]$InitiatorList = $null
)

   $Route = '/types/initiator-groups'
   
   #if there is an initiator list, we'll do this
   if($InitiatorList){
       if($InitiatorList.Count -eq 1){
         $InitiatorList = '['+$InitiatorList+']'
       }
       $InitiatorList = ($InitiatorList | ConvertTo-Json).ToString()

       $Body = @"
       {
          "ig-name":"$InitiatorGroupName",
          "initiator-list":"$InitiatorList"
       }
"@
   }
   else{
       $Body = @"
       {
          "ig-name":"$InitiatorGroupName"
       }   
"@   
   
   }   


   $ObjectSelection = 'content'

  New-XtremRequest -Method POST -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Body $Body -Username $Username -Password $Password -ObjectSelection $ObjectSelection
  

}



#Deletes a Volume
Function Remove-XtremInitiatorGroup{

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

  [cmdletbinding()]
Param (
    [parameter()]
    [string]$XmsName,
    [parameter()]
    [string]$XtremioName = $global:XtremClusterName,
    [parameter()]
    [string]$Username,
    [parameter(Mandatory=$true,Position=0)]
    [string]$InitiatorGroupName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/initiator-groups'
  $GetProperty = 'name='+$InitiatorGroupName
 

  New-XtremRequest -Method DELETE -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -GetProperty $GetProperty
 
 
 
}

#Returns List of Volumes
Function Get-XtremInitiators{

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
    
    $Route = '/types/initiators'
 
    $ObjectSelection = 'initiators'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

Function Get-XtremInitiator{
  
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
    [string]$InitiatorName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/initiators'
  $GetProperty = 'name='+$InitiatorName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

######### TARGET INFO COMMANDS #########
#Returns List of Volumes
Function Get-XtremTargets{

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
    
    $Route = '/types/targets'
 
    $ObjectSelection = 'targets'

    New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -XtremioName $XtremioName -Properties $Properties -Username $Username -Password $Password -ObjectSelection $ObjectSelection

}

Function Get-XtremTarget{
  
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
    [string]$TargetName,
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/targets'
  $GetProperty = 'name='+$TargetName
  $ObjectSelection = 'content'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}



######### Performance Collection COMMANDS #########

Function Get-XtremPerformance{
  
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
    [ValidateSet('SnapshotGroup', 'Initiator', 'Target', 'XEnv', 'DataProtectionGroup', 'Volume', 'Cluster', 'Tag', 'InitiatorGroup', 'SSD', 'TargetGroup', 'Xms')]
    [string]$ObjectType,
    [parameter()]
    [ValidateSet('one_minute','ten_minutes','one_hour','one_day','auto','raw')]
    [String]$Granularity = 'one_hour',
    [Parameter()]
    [DateTime]$ToDateTime = (Get-Date),
    [Parameter()]
    [DateTime]$FromDateTime = (Get-Date $ToDateTime.AddDays(-30)),
    [parameter()]
    [string]$Password,
    [Parameter()]
    [string[]]$Properties
  )
   
  $Route = '/types/performance'
  $GetProperty = 'entity='+$ObjectType+'&granularity='+$Granularity+'&from-time='+(Get-Date $FromDateTime -format yyyy-MM-dd+H:mm:ss)+'&to-time='+(Get-Date $ToDateTime -format yyyy-MM-dd+H:mm:ss)
  
  $ObjectSelection = 'counters'

  New-XtremRequest -Method GET -Endpoint $Route -XmsName $XmsName -Username $Username -Password $Password -ObjectSelection $ObjectSelection -GetProperty $GetProperty -Properties $Properties
    
}

Function Export-XtremCSV{
[Cmdletbinding()]
Param(
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
[PSObject]$PerformanceData,
[Parameter(Mandatory=$true)]
[String]$ExportPath
)

  $data = $PerformanceData
  
  $members = $data.members
  $counters = $data.counters
  

  $dataarray = @()

    for($i = 0; $i -lt $counters.count; $i++){

    $dataobj = New-Object System.Object
    [datetime]$EpochTime = '1970-01-01 00:00:00'

        for($j = 0; $j -lt $members.count; $j++){
            
             #This is how I'm dealing with epoch time...
             if($j -eq 0)
             {
               
               $time = $EpochTime.AddMilliSeconds($counters[$i][$j])

               $dataobj | Add-Member -type NoteProperty -name $members[$j] -Value $time

             }
             else{

                $dataobj | Add-Member -type NoteProperty -name $members[$j] -Value $counters[$i][$j]
             }
             
        
          }
   
    $dataarray = $dataarray + $dataobj
    }

    $sort_order = "timestamp"
   
    $dataarray |sort $sort_order | Export-Csv $ExportPath -NoTypeInformation



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
Function Get-XtremClusters{
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

  #Special case...tags doesn't take cluster name and neither does performance
  if(($Endpoint -like '*tags*' -or $Endpoint -like '*performance*') -and ($Method -eq 'GET' -or $Method -eq 'DELETE')){
   $XtremioName = $null
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
                    
                    #another special case for performance calls...

                    if($Endpoint -like "*performance*"){
                      $PropertyString = $PropertyString
                    }
                    else{
                      $PropertyString = 'full=1&'+$PropertyString
                    }

                  }

           
                  #We now have a property string <if there are properties> and cluster name <if specified>, and a GET property <if specified> we need to build a full URI. Yes this is a lazy way to handle this.
                  
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

                  ##USE THIS BELOW LINE TO DEBUG WHAT URL IS BEING GENERATED :)
                  #Write-Host $Uri 
                  
                 
                  
                  ##Do this for GET Requests
                  if($Method -eq 'GET'){
                      
                      #special way of handling performance calls, special JSON serializer needs to be used as payload is large
                      if($Endpoint -like "*performance*"){

                        $jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
                        $jsonserial.MaxJsonLength = [int]::MaxValue
                        $data = $jsonserial.DeserializeObject((Invoke-WebRequest -Method $Method -Uri $Uri -Headers $Header))
                        
                        $data

                      }
                      else{
                    (Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Header).$ObjectSelection
                    }
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




