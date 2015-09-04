<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that wraps interactions with the XtremIO RESTful API
This is the 4.0 (for use with XIOS 4.0 +) module. Much has changed since the older release, if you want to use the previous version it is still available under releases.
The old release will be compatible with XIOS 3.X and 4.X, but this release will only work with 4.0+. Due to significant API changes, this module has undergone alot of rewrite
so commands have changed, with alot of new functionality. If you use the old module for automation, you should still be able to use it even after upgrading to 4.0... but new
features will only be available here. 

Looking for testers! If you work at EMC or are a customer with XtremIO and want an easy way
to contribute to the {Code} community, this would be huge!


#### Upcoming changes 
- Ability to leverage new 4.0 capabilities (CGs, Snapshot Sets, Snapshot Refresh, Perf metrics, etc)
- Allowing for object piping between cmdlets, positional parameters, and other 'PowerShell' things 
- Implementation of v2 API as well as filters for selecting only information you want.
- Ability to run against XMS managing more than one system
- And more!




#### Feedback
- Looking for testers!
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
Get-XtremClusters
```
Get All Cluster Statistics
```
Get-XtremCluster
Get-XtremCluster xio11
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
Get Info about a single Initiator Group:
```
Get-XtremInitiatorGroup naviig
Get-XtremInitiatorGroup -InitiatorGroupName naviig
```
Create a new Initiator Group
```
New-XtremInitiatorGroup naviig -InitiatorList init1,init2
New-XtremInitiatorGroup naviig
```
Retrieve all Targets and Initiators (names)
```
Get-XtremTargets
Get-XtremInitiators
```
Or retrieve all Targets and Initiators with the other kinds of info you are looking for:
```
Get-XtremInitiators -Properties name,port-address | Select name,port-address | Format-Table -AutoSize

name            port-address           
----            ------------           
Lab_C12_B4_HBA1 20:00:00:8f:74:12:01:02
Lab_C12_B3_HBA2 20:00:00:8f:74:22:01:11
Lab_C12_B5_HBA1 20:00:00:8f:75:12:01:01
Lab_C12_B4_HBA2 20:00:00:8f:74:22:01:12
Lab_C12_B6_HBA1 20:00:00:8f:75:12:01:02
Lab_C12_B5_HBA2 20:00:00:8f:75:22:01:11
Lab_C12_B6_HBA2 20:00:00:8f:75:22:01:12
C3_B1_HBA1      20:00:00:25:b5:a0:00:ef
C3_B2_HBA1      20:00:00:25:b5:a0:00:3f
C3_B1_HBA2      20:00:00:25:b5:b0:01:ef
Lab_C12_B1_HBA1 20:00:00:8f:73:12:00:01
C3_B2_HBA2      20:00:00:25:b5:b0:01:2f
Lab_C12_B2_HBA1 20:00:00:8f:73:12:00:02
Lab_C12_B1_HBA2 20:00:00:8f:73:22:00:11
Lab_C12_B3_HBA1 20:00:00:8f:74:12:01:01
Lab_C12_B2_HBA2 20:00:00:8f:73:22:00:12


Get-XtremTargets -Properties name,port-address | Select name,port-address | Format-Table -AutoSize

name          port-address                                           
----          ------------                                           
X1-SC1-fc1    51:4f:0c:51:42:5f:c8:00                                
X1-SC1-iscsi1 iqn.2008-05.com.xtremio:apm00144610315-514f0c51425fc900
X1-SC1-fc2    51:4f:0c:51:42:5f:c8:01                                
X1-SC2-fc1    51:4f:0c:51:42:5f:c8:04                                
X1-SC1-iscsi2 iqn.2008-05.com.xtremio:apm00144610315-514f0c51425fc901
X1-SC2-iscsi1 iqn.2008-05.com.xtremio:apm00144610315-514f0c51425fc904
X1-SC2-fc2    51:4f:0c:51:42:5f:c8:05                                
X1-SC2-iscsi2 iqn.2008-05.com.xtremio:apm00144610315-514f0c51425fc905
```
Get details about a specific Target or Initiator
```
Get-XtremInitiator init1
Get-XtremTarget X1-SC1-fc1
```
Get all volume mappings:
```
Get-XtremVolumeMappings
```
Or maybe you want to see a list of all volumes attached to all initiator groups sorted by initiator group?:
```
Get-XtremVolumeMappings -Properties vol-name,ig-name | Select vol-name,ig-name | Sort-Object ig-name | Format-Table -AutoSize

vol-name          ig-name   
--------          -------   
OracleQA1-Data1   Prod_C3_B1
VDI2-DS           Prod_C3_B1
OracleQA1-Data4   Prod_C3_B1
OracleQA1-Data3   Prod_C3_B1
OracleQA1-Data2   Prod_C3_B1
OracleProd1-Data1 Prod_C3_B1
OracleProd1-Data4 Prod_C3_B1
OracleProd1-Data3 Prod_C3_B1
OracleProd1-Data2 Prod_C3_B1
OracleProd-DS     Prod_C3_B1
OracleProd1-Data3 Prod_C3_B2
VDI2-DS           Prod_C3_B2
```
Return info about a specific mapping:
```
Get-XtremVolumeMaping 4_4_4
```
Map a volume or snapshot to an initiator group:
```
New-XtremVolumeMapping -VolumeName navi -InitiatorGroupName naviig -Lun 10
New-XtremVolumeMapping navi naviig 10
New-XtremVolumeMapping navi naviig
```
Delete a mapping:
```
Remove-XtremVolumeMapping -VolumeName navi -InitiatorGroupName naviig
Remove-XtremVolumeMapping navi naviig
```
And more...

## How to Retrieve Historical Performance Stats
This was a new feature in 4.0, and because there are alot of options this is getting its own section. The command to be ran is like this:
```
Get-XtremPerformance -ObjectType <objecttype> -Granularity <granularity> -ObjectNames <[optional]specific object names> -Properties <[optional] specific properties> -FromDateTime <[optional] timeframe> -ToDateTime <[optional] timeframe>
```
These are the possible ObjectTypes:
```
SnapshotGroup, Initiator, Target, XEnv, DataProtectionGroup, Volume, Cluster, Tag, InitiatorGroup, SSD, TargetGroup, Xms
```
FromDateTime and ToDateTime are optional - default time range is 30 days from the current date. If you input specific ranges, they must be parseable by Get-Date, such as the below examples:
```
Get-XtremPerformance -ObjectType Cluster -Granularity one_day -FromDateTime '08/28/2015' -ToDateTime '09/4/2015'
Get-XtremPerformance -ObjectType Cluster -Granularity one_minute -FromDateTime '09/4/2015 08:00' -ToDateTime '09/4/2015 10:00'
Get-XtremPerformance -ObjectType Cluster -Properties avg__iops,avg__bw -Granularity one_hour -FromDateTime '09/4/2015 08:00' -ToDateTime '09/4/2015 11:00'
```

These are the possible properties for the 'Cluster' object:
```     
      
        "avg__avg_latency", 
        "avg__wr_iops_32kb", 
        "avg__rd_iops_64kb", 
        "avg__avg_latency_64kb", 
        "avg__rd_latency_4kb", 
        "avg__rd_iops_8kb", 
        "avg__iops_128kb", 
        "avg__small_wr_iops", 
        "avg__rd_latency_8kb", 
        "avg__free_ud_ssd_space_in_base10", 
        "avg__rd_bw_16kb", 
        "avg__rd_bw_128kb", 
        "avg__bw_4kb", 
        "avg__bw_gt1mb", 
        "avg__wr_bw_by_block", 
        "avg__rd_latency_1kb", 
        "avg__unaligned_rd_iops", 
        "avg__unaligned_wr_bw", 
        "avg__unaligned_bw", 
        "avg__dedup_ratio", 
        "avg__logical_space_in_use", 
        "avg__bw_64kb", 
        "avg__rd_bw_4kb", 
        "avg__bw_8kb", 
        "avg__rd_latency_32kb", 
        "avg__wr_bw_gt1mb", 
        "avg__iops_64kb", 
        "avg__rd_latency_16kb", 
        "avg__wr_bw_1mb", 
        "avg__iops_512kb", 
        "avg__rd_bw_by_block", 
        "avg__rd_latency_gt1mb", 
        "avg__wr_bw", 
        "avg__iops_1kb", 
        "avg__rd_latency_512b", 
        "avg__wr_bw_2kb", 
        "avg__avg_latency_2kb", 
        "avg__iops_256kb", 
        "avg__bw", 
        "avg__iops_2kb", 
        "avg__rd_latency", 
        "avg__rd_latency_2kb", 
        "avg__small_iops", 
        "avg__bw_512b", 
        "avg__wr_latency_128kb", 
        "avg__bw_by_block", 
        "avg__wr_latency_16kb", 
        "avg__wr_iops_64kb", 
        "avg__rd_bw_512b", 
        "avg__wr_latency_512kb", 
        "avg__wr_iops", 
        "avg__avg_latency_8kb", 
        "avg__thin_provisioning_ratio", 
        "avg__wr_latency_512b", 
        "avg__wr_iops_512b", 
        "avg__bw_32kb", 
        "avg__iops_16kb", 
        "avg__wr_latency_32kb", 
        "avg__wr_iops_4kb", 
        "avg__rd_bw_1kb", 
        "avg__wr_latency_1mb", 
        "avg__small_wr_bw", 
        "avg__rd_bw_256kb", 
        "avg__wr_iops_by_block", 
        "avg__wr_latency_gt1mb", 
        "avg__bw_128kb", 
        "avg__wr_iops_2kb", 
        "avg__wr_iops_1kb", 
        "avg__wr_bw_512b", 
        "avg__avg_latency_128kb", 
        "avg__iops_32kb", 
        "avg__bw_2kb", 
        "avg__wr_bw_128kb", 
        "avg__shared_memory", 
        "avg__avg_latency_4kb", 
        "avg__iops", 
        "avg__rd_iops_2kb", 
        "avg__avg_latency_1kb", 
        "avg__rd_iops_by_block", 
        "avg__bw_16kb", 
        "avg__avg_latency_16kb", 
        "avg__logical_space_in_use_in_base10", 
        "avg__rd_iops_32kb", 
        "avg__avg_latency_512kb", 
        "avg__rd_bw_512kb", 
        "avg__rd_iops_16kb", 
        "avg__small_rd_iops", 
        "avg__rd_iops_512b", 
        "avg__free_logical_space_in_base10", 
        "avg__rd_iops_256kb", 
        "avg__rd_iops_512kb", 
        "avg__iops_gt1mb", 
        "avg__rd_bw_8kb", 
        "avg__rd_bw_64kb", 
        "avg__rd_bw", 
        "avg__bw_1mb", 
        "avg__num_of_vols", 
        "avg__bw_256kb", 
        "avg__ud_ssd_space_in_use_in_base10", 
        "avg__small_rd_bw", 
        "avg__wr_bw_4kb", 
        "avg__unaligned_rd_bw", 
        "avg__bw_1kb", 
        "avg__wr_bw_64kb", 
        "avg__rd_latency_512kb", 
        "avg__vol_size", 
        "avg__wr_bw_512kb", 
        "avg__wr_iops_256kb", 
        "avg__rd_latency_64kb", 
        "avg__shared_memory_in_use", 
        "avg__wr_bw_32kb", 
        "avg__dedup_space_in_use", 
        "avg__vol_size_in_base10", 
        "avg__wr_bw_1kb", 
        "avg__rd_bw_2kb", 
        "avg__iops_4kb", 
        "avg__rd_latency_128kb", 
        "avg__wr_bw_256kb", 
        "avg__iops_8kb", 
        "avg__iops_1mb", 
        "avg__ud_ssd_space", 
        "avg__rd_latency_1mb", 
        "avg__iops_512b", 
        "avg__ud_ssd_space_in_use", 
        "avg__bw_512kb", 
        "avg__compression_factor", 
        "avg__rd_iops_128kb", 
        "avg__wr_latency_256kb", 
        "avg__wr_iops_128kb", 
        "avg__unaligned_iops", 
        "avg__wr_latency_8kb", 
        "avg__wr_iops_8kb", 
        "avg__unaligned_wr_iops", 
        "avg__wr_latency_4kb", 
        "avg__wr_iops_16kb", 
        "avg__rd_bw_32kb", 
        "avg__wr_latency", 
        "avg__wr_iops_gt1mb", 
        "avg__data_reduction_ratio", 
        "avg__wr_latency_2kb", 
        "avg__wr_iops_1mb", 
        "avg__avg_latency_256kb", 
        "avg__rd_bw_1mb", 
        "avg__rd_iops_1mb", 
        "avg__wr_latency_1kb", 
        "avg__wr_iops_512kb", 
        "avg__small_bw", 
        "avg__wr_latency_64kb", 
        "avg__rd_iops_1kb", 
        "avg__space_in_use", 
        "avg__avg_latency_1mb", 
        "avg__wr_bw_8kb", 
        "avg__avg_latency_gt1mb", 
        "avg__iops_by_block", 
        "avg__rd_bw_gt1mb", 
        "avg__rd_latency_256kb", 
        "avg__avg_latency_512b", 
        "avg__avg_latency_32kb", 
        "avg__rd_iops_4kb", 
        "avg__wr_bw_16kb", 
        "avg__rd_iops_gt1mb", 
        "avg__ud_ssd_space_in_base10", 
        "avg__rd_iops"
```

As you can see, there are a ton, and they vary from object to object. To see the properties for your desired object, do this and check the properties that come back:
```
Get-XtremPerformance -ObjectType <objecttype> -Granularity one_minute
```
Then run the command with only a subset of the properties returned in the previous command:
```
Get-XtremPerformance -ObjectType Cluster -Properties avg__iops,avg__bw
```
The returned object has 4 properties: counters, members, links, and granularity. You probably want to do something with this data, so understanding the layout is pretty key.
```
'Members' are your columns, such as 'timestamp', 'guid', 'name', 'index', 'avg__iops', 'avg__bw'. Take note of the double '_'

'Counters' contains many objects, and each one contains values for each of the 'Members' in order (essentially, statistics at a particular time stamp) 

``` 
You can think of 'Members' as the columns, and 'Counters' as the rows. Powershell's Export-CSV won't just handle this object the way you'd expect without some specialized object formatting. Since I 
figure that many people will like to use this, I made module command that will do this for you. So putting it all together:
```
Get-XtremPerformance -ObjectType Cluster -Properties avg__iops,avg__bw | Export-XtremCSV -ExportPath C:\temp\performance.csv
```
That will create a CSV that you can use to create graphs or whatever. I've even taken care of the epoch conversion for you (the timestamps are Unix Epoch time). 


## Full Command List
In PowerShell, use Get-Help

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
 
Began around 08/2015 
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>