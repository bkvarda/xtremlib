<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This release was written and tested against XIOS 2.4, but should also work without issue on 3.0+ as
none of the RESTful calls leveraged were changed in 3.0. 


 
## Installation

#### Importing the XtremIO Security Certificate 
Before you can begin using the module, you will need to import the XtremIO security certificate into your Trusted
Root Certificate Authority. To do this, point your browser to either the IP Address or the hostname of your XtremIO
cluster. Click the 'security certificate' link to download the certificate, and save it somewhere on the computer
that will be executing the PS commands. Then, open up mmc, go to the 'Certificates - Current User' snap-in and navigate
to the 'Trusted Root Certification Authorities' folder. Right click on it, navigate to 'All Tasks', then click 'Import'. 
Go through the wizard and select the XtremIO certificate you saved earlier when prompted for a certificate file to import.

#### Installing the Module
Download entire contents as .zip Extract the xtremlib folder to a designated PowerShell module directory. If you do
not know where your PowerShell module directories are, open up a PowerShell prompt and examine the PSModulePath variable
by entering '$env:PSModulePath'. Once the folder has been placed in a module directory, module functions will be available
in PowerShell. 


 
## Usage
See module manifest for full list of functions. Use the xtremlib functions to get information from and make changes to XtremIO.
Better documentation will be created, but for now open the *.psm1 file to see the purpose of each function and the required 
switches/input. Most function switch input is case-sensitive, so assume that when entering names and information capitalization must
match. One-time credential setting is now possible (first screenshot). Can also specify credentials every command.  
Here are some examples:

![Alt text](http://i.imgur.com/cMSVfho.png "Example with stored credentials")

![Alt text](http://i.imgur.com/jl2JGpS.png "Example Commands")

![Alt text](http://i.imgur.com/bckO9Wz.png "More examples")

## Command List
####General Commands and Helpers
#####New-XtremSession (optional: -xioname <IP or name> -username <XIO username> -password <XIO password>)
Prompts for XtremIO login information and sets global variables. Once these are set they do not have to be specified for subsequent commands.
#####Edit-XtremName -xioname <IP or name>
Changes the global XtremIO IP or name for the current PS session
#####Edit-XtremUsername -username <XIO username>
Changes the global XtremIO username for the current PS session	
#####Edit-XtremPassword
Prompts to change global XtremIO password for the current PS session and saves as a secured string object
#####Remove-XtremSession 
Clears all global credential/IP for current PS session
#####Get-XtremClusterStatus
Returns general cluster information including name, serial #, code version, dedupe ratio, total capacity, total virtual consumed.
####Volume and Snapshot Commands
#####Get-XtremVolumes 
Returns list of all XtremIO volumes
#####Get-XtremVolumeInfo -volname <Volume name>
Returns information about a specific volume
#####New-XtremVolume -volname <Volume name> -volsize <Size followed by m,g,t) (optional: -folder <Volume folder, must be full path)
Creates a new volume of specified size. If folder is not defined, new volume placed in root
#####Edit-XtremVolume -volname <Volume name> -volsize <New size followed by m,g,t)
Modifies the size of an existing volume
#####Remove-XtremVolume -volname <Volume name>
Removes volume or snapshot. This will not prompt you so handle with care
#####Get-XtremSnapshots
Returns list of snapshots
#####New-XtremSnapshot -volname <Volume to snap> -snapname <Name of snapshot> (optional: -folder <Snapshot folder, must be full path)
Creates a snapshot from a given volume. Will place in root if folder is not specified.
#####Remove-XtremSnapshot -snapname <Snap to delete>
Removes snapshot
#####Get-XtremVolumeFolders
Returns list of volume folders
#####Get-XtremVolumeFolderInfo -foldername <full path of folder>
Returns info about a specific volume folder
#####New-XtremVolumeFolder -foldername <name of folder> (optional: -parentfolderpath <Full path of parent folder that will contain new folder>
Creates a new volume folder. If no parentfolderpath is specified, new folder is placed in root.
####Initiator Groups, Folders, and Initiators
#####Get-XtremIGFolders
Returns list of all initiator group folders
#####Get-XtremIGFolderInfo -foldername <name of folder>
Returns information about a specific folder. If folder is in root, use just the name. If its further, user format 'folder/subfolder/subfolder'
#####New-XtremIGFolder -foldername <name of folder> (optional: -parentfolderpath <full path of parent folder that will contain new folder>)
Creates a new initiator group folder. Parent folder path only needs to be defined if not creating in root.
#####Get-XtremInitiators
Returns list of initiators
#####Get-XtremInitiatorInfo -initiatorname <name of initiator>
Returns information about a specific initiator
#####New-XtremInitiator -initiatorname <name of initiator> -address <port address> -igname <init group to add init to>
Creates an initiator and adds to an existing initiator group. 
#####Get-XtremInitiatorGroups
Returns list of initiator groups
#####Get-XtremInitiatorGroupInfo -igname <name of init group>
Returns information about a specific initiator group
#####Remove-XtremInitiatorGroup -igname <name of init group>
Deletes an initiator group.
####Volume Mapping Commands
#####Get-XtremVolumeMappingList
Returns list of mapping IDs. More useful as a helper function. 
#####Get-XtremVolumeMapping -igname <name of init group>
Returns volumes attached to a specific initiator group
#####Get-XtremVolumeMapID -igname <name of init group> -volname <name of volume>
Returns mapping ID of a specific initiatorgroup/volume relationship. 
#####New-XtremVolumeMapping -igname <name of init group> -volname <name of volume>
Maps a volume to a specified initiator group
#####Remove-XtremVolumeMapping -igname <name of init group> -volname <name of volume>
Removes a volume/initiator group mapping, but preserves both IG and volume. 
## History
 
Began on 10/22/14 
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>