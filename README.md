<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that wraps interactions with the XtremIO RESTful API
The latest release (3.0) was written and tested against XIOS 3.x and can be found [here](https://github.com/bkvarda/xtremlib/releases/tag/3.0).

## xtremlib 4.0 (in development)
No current release. Source will be updated in the 4.0 branch [here]()

#### Upcoming changes 
- Functions/switches that allow you to more easily manage complex snapshot workflows
- Allowing for object piping between cmdlets 
- Implementation of v2 API filters (faster performance)
- Implementation of performance-related commands
- Ability to run against XMS managing more than one system
- And more!

## xtremlib 3.0 (current)
Latest release available [here](https://github.com/bkvarda/xtremlib/releases/tag/3.0). Source is available in the 3.0 branch [here]()

#### Changes from 1.0 
- All Get commands now return the full object returned from XtremIO - you can do with it what you'd like.
- Error handling has been improved 
- Post/Delete commands (Removes and updates) continue to return $true if they successfully complete
- It should no longer be necessary to import the XtremIO certificate (cert validation is bypassed)
- Remove-XtremVolumeMapping is now significantly faster (due to 3.0 API updates in conjunction with modified cmdlet)
- You can now store encrypted credentials in a .txt file (useful for scripting)
- Some variable names have changed to be more consistent between functions
- Some cmdlet names have changes to be more consistent with PowerShell nomenclature


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
Then start an XtremIO session (this stores creds (encrypted pw) as global vars for the PowerShell session:
```
New-XtremSession -xioname 10.29.63.14 -credlocation C:\temp
```
Get Cluster Statistics
```
Get-XtremClusterStatus
```
Create a Volume
```
New-XtremVolume -volname navi -volsize 1048g
```
Create an Initiator Group
```
New-XtremInitiatorGroup -igname naviig
```
Map a Volume to an Initiator Group
```
New-XtremVolumeMapping -volname navi -igname naviig
```
Create a snapshot of a volume
```
New-XtremSnapshot -volname navi -snapname navisnap
```
Map the snapshot to and Initiator Group
```
New-XtremVolumeMapping -volname navisnap -igname naviig
```
Unmap the volume from an Initiator Group
```
Remove-XtremVolumeMapping -volname navi -igname naviig
```
Delete a volume or snapshot 
```
Remove-XtremVolume -volname navi
```
Delete an Initiator Group
```
Remove-XtremInitiatorGroup -igname naviig
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