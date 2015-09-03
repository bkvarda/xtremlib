<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that wraps interactions with the XtremIO RESTful API
This is the 4.0 (for use with XIOS 4.0 +) branch which is currently in development.The  

## xtremlib 4.0 (in development)
No current release. Source will be updated in the 4.0 branch [here]()

#### Upcoming changes 
- Ability to leverage new 4.0 capabilities (CGs, Snapshot Sets, Snapshot Refresh, Perf metrics, etc)
- Allowing for object piping between cmdlets 
- Implementation of v2 API as well as filters for selecting only information you want.
- Ability to run against XMS managing more than one system
- And more!




#### Feedback
- For feature request, please raise an issue
- For bugs, please, raise an issue


 
## Installation

#### Installing the Module
Place all contents into your [PowerShell Module folder](https://msdn.microsoft.com/en-us/library/dd878350%28v=vs.85%29.aspx), or use [Import-Module](https://technet.microsoft.com/en-us/library/hh849725.aspx)


 
## Usage
Run Get-XtremHelp in PowerShell for list of commands and examples. Use the xtremlib functions to get information from and make changes to XtremIO.
Most function switch input is case-sensitive, so assume that when entering names and information capitalization must
match. One-time credential setting is now possible using New-XtremSession. Credentials can also be specified for each command. 
Here are some examples (the below use special formatting for output, you can use your own custom object formatting):

First generate and store secure credentials:
```
New-XtremSecureCreds -path C:\temp
```
Then start an XtremIO session (this stores creds (encrypted pw)) as global vars for the PowerShell session:
```
New-XtremSession -XmsName 10.29.63.14 -XtremioName xio10 -CredLocation C:\temp
```
4.0 Introduced the ability for a single XMS to manage multiple XtremIO clusters. Even if you only manage one cluster, it's mandatory in this module to include the name. If you aren't sure of the name, run this:
```
Get-XtremClusterNames
```
Get All Cluster Statistics
```
Get-XtremCluster
```
Or you can return specific properties like this:
```
Get-XtremCluster -Properties iops,logical-capacity-in-use
```
Retrieve a list of all volumes:
```
Get-XtremVolumes
```
Or retrieve all volumes including certain properties. Most GET commands allow you to supply a properties list:
```
Get-XtremVolumes -Properties iops,wr-bw,vol-id,creation-time
```
Retrieve a specific volume
```
Get-XtremVolume -VolumeName navi
```
Positional parameters exist for most GET/DELETE commands, as well as less complex PUT/POST commands:
```
Get-XtremVolume navi
```
Create a Volume
```
New-XtremVolume -VolumeName navi -VolumeSize 1048g
New-XtremVolume navi 1048g
```
Edit a Volume
```
Edit-XtremVolume -VolumeName navi -ParameterToModify vol-name -NewValue navi2
Edit-XtremVolume -VolumeName navi -ParameterToModify vol-size -NewValue 16g
```
Return list of all snapshots
```
Get-XtremSnapshots
```
Return list of all snapshot sets
```
Get-XtremSnapshotSets
```

Create a snapshot set of volume(s), consistency group, volumes with certain tag(s), or snapshot set 
```
New-XtremSnapshot -ParentType volume-list -ParentNames navi,navi1 -SnapshotSetName navisnaps
New-XtremSnapshot -ParentType volume-list -ParentNames navi -SnapshotSetName navisnap
New-XtremSnapshot -ParentType consistency-group-id -ParentNames navicg -SnapshotSetName navisnaps
New-XtremSnapshot -ParentType tag-list -ParentNames PROD,PRODUCTION -SnapshotSetName navisnaps

```
Create a snapshot of a volume, consistency group, or snapshot set and refresh a volume, consistency group, or snapshot set
```
New-XtremSnapshotRefresh -ParentType from-volume-id -ParentName navi -RefreshType to-snapshot-set-id -RefreshName navisnaps -NewName navisnaps1
New-XtremSnapshotRefresh -ParentType from-consistency-group-id -ParentName navicg -RefreshType to-snapshot-set-id -RefreshName navisnaps -NewName navisnaps1
New-XtremSnapshotRefresh -ParentType from-snapshot-set-id -ParentName navisnaps -RefreshType to-consistency-group-id -RefreshName navicg -NewName navicg1
```

Delete a volume or snapshot set 
```
Remove-XtremVolume -VolumeName navi
```
This also deletes a snapshot if you like it more
```
Remove-XtremSnapshot -SnapshotName navisnap
```
Remove a snapshot set
```
Remove-XtremSnapshotSet -SnapshotSetName navisnapset
Remove-XtremSnapshotSet navisnapset
```
Retrieve list of all Tags
```
Get-XtremTags
```
Retrieve list of all Tags that are Volume Tags (this is an example of how to make things PowerShelly)
```
Get-XtremTags -Properties 'object-type' | Where 'object-type' -eq Volume | Select * | Format-Table -AutoSize

object-type guid                             name               index
----------- ----                             ----               -----
Volume      246588e85c1748b296c9c1286fdca8b9 /Volume/Test          24
Volume      0b3c79b04f0542cabfbcdd0be97bd97e /Volume/jesse         25
Volume      ef429dd7f7c0470eb70175726008e137 /Volume/aqrsqld       27
Volume      3fab56f5c96946ab9878fa7c75999d4d /Volume/QA            23
Volume      245c597e45a240fc8cf1a6833beb4687 /Volume                1
Volume      b9c2adb8fa69427c883641666d5e8705 /Volume/PRODUCTION     3
Volume      c783112035034dcfb3cc292b88732b52 /Volume/LAB           13
Volume      3794fa0fc5924f1fa04eedf12a0d2282 /Volume/Oracle        19

```
Get info about a specific Tag:
```
Get-XtremTag -TagName navitag -ObjectType Volume
```
Delete a Tag
```
Remove-XtremTag -TagName navitag -ObjectType Volume
```
Create a Tag
```
New-XtremTag navitag -ObjectType Volume
New-XtremTag -TagName navitag -ObjectType Snapshot
```
Assign a Tag to an Object:
```
Set-XtremTag -ObjectType Volume -ObjectName navi -TagName navitag
```
Or Assign a Tag to an Object this way:
```
Get-XtremTag navitag -ObjectType Volume | Set-XtremTag navi
Get-XtremTag navitag Snapshot | Set-XtremTag navi
```
Get Initiator Groups
```
Get-XtremInitiatorGroups
```

And many more!

## Full Command List
In PowerShell, run Get-XtremHelp to list all of the available commands. Get-Help is also available for each command. 

##Licensing
Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may 
obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” 
BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions
and limitations under the License.

##Support
Please file bugs and issues at the Github issues page. For more general discussions you can contact the EMC Code team at <https://groups.google.com/forum/#!forum/emccode-users>. The code and 
documentation are released with no warranties or SLAs and are intended to be supported through a community driven process.

## History
 
Began on 10/22/14 
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>