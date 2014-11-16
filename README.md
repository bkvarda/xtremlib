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
Run Get-XtremHelp in PowerShell for list of commands and examples. Use the xtremlib functions to get information from and make changes to XtremIO.
Most function switch input is case-sensitive, so assume that when entering names and information capitalization must
match. One-time credential setting is now possible using New-XtremSession. Credentials can also be specified for each command. 
Here are some examples (the below use special formatting for output, you can use your own custom object formatting):

![Alt text](http://i.imgur.com/cMSVfho.png "Example with stored credentials")

![Alt text](http://i.imgur.com/jl2JGpS.png "Example Commands")

![Alt text](http://i.imgur.com/bckO9Wz.png "More examples")

## Command List
In PowerShell, run Get-XtremHelp to list all of the available commands. Get-Help is also available for each command. 
You can also refer to examples.txt for more examples. 
## History
 
Began on 10/22/14 
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>