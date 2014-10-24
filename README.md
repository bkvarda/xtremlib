<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This is currently incomplete, I intend to include most API functionality as well as make content more presentable
 
## Installation

#### Importing the Module 
Download xtremlib.ps1 and copy to a PowerShell module directory. If you do not know where your PowerShell module directories are, 
open up a PowerShell prompt and examine the PSModulePath variable by entering '$env:PSModulePath'. Once the file has been placed in 
a module directory, run 'Import-Module xtremlib.ps1' in PowerShell.

#### Installing the Module
Instructions will be provided once manifest is created
 
## Usage
See module manifest (once complete). Use the xtremlib cmdlets to get information from and make changes to XtremIO. Current list of 
commands below (all of these work if syntax is all correct, some still need error handling logic and console text/style):
**Get-XtremClusterName ([string]$xioip,[string]$username,[string]$password)**

**Create-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$volsize)**

**Get-XtremStorageControllers ([string]$xioname,[string]$controllername,[string]$username,[string]$password)**

**Get-XtremClusterStatus ([string]$xioname,[string]$username,[string]$password)**

**Get-XtremClusterVolumes([string]$xioname,[string]$username,[string]$password)**

**Get-XtremClusterSnapshots([string]$xioname,[string]$username,[string]$password)**

**Get-XtremClusterInitiators([string]$xioname,[string]$username,[string]$password)**

**Remove-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname)**

**Create-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$snapname)**

**Remove-XtremSnap([string]$xioname,[string]$username,[string]$password,[string]$snapname)**

**Map-XtremVolume([string]$xioname,[string]$username,[string]$password,[string]$volname,[string]$initgroup)**


 
TODO: More to come...
 
 
## History
 
Started today!
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>