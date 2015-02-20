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