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
Get-XtremClusterStatistics
```
Or you can return specific properties like this:
```
Get-XtremClusterStatistics -Properties iops,logical-capacity-in-use
```
Retrieve a list of all volumes:
```
Get-XtremVolumes
```
Or retrieve all volumes including certain properties:
```
Get-XtremVolumes -Properties iops,wr-bw,vol-id,creation-time
```
Retrieve a specific volume
```
Get-XtremVolume -VolumeName navi
```
Create a Volume
```
New-XtremVolume -VolumeName navi -VolumeSize 1048g
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
Create a snapshot set of volume(s), consistency group, volumes with certain tag(s), or snapshot set 
```
New-XtremSnapshot -ParentType volume-list -ParentNames navi,navi1 -SnapshotSetName navisnaps
New-XtremSnapshot -ParentType volume-list -ParentNames navi -SnapshotSetName navisnap
New-XtremSnapshot -ParentType consistency-group-id -ParentNames navicg -SnapshotSetName navisnaps
New-XtremSnapshot -ParentType tag-list -ParentNames PROD,PRODUCTION -SnapshotSetName navisnaps

```

Delete a volume or snapshot set 
```
Remove-XtremVolume -VolumeName navi
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