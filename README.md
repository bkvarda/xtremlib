<snippet>
  <content>
# xtremlib
 
xtremlib is a PowerShell Module that acts as a wrapper for interactions with the XtremIO RESTful API
This is currently incomplete, I intend to include most API functionality as well as make content more presentable.

 
## Installation

#### Importing the Module 
Download entire  contents as .zip. Extract the xtremlib folder to your computer. Open a PowerShell session
and run 'Import-Module <location where you put xtremlib>. xtremlib will now be available for your current session 

#### Installing the Module
Download entire contents as .zip Extract the xtremlib folder to a designated PowerShell module directory. If you do
not know where your PowerShell module directories are, open up a PowerShell prompt and examine the PSModulePath variable
by entering '$env:PSModulePath'. Once the folder has been placed in a module directory, module functions will be available
in PowerShell. 
 
## Usage
See module manifest for full list of functions. Use the xtremlib functions to get information from and make changes to XtremIO.
Better documentation will be created, but for now open the *.psm1 file to see the purpose of each function and the required 
switches/input.  Here are some examples:

![Alt text](http://i.imgur.com/jl2JGpS.png "Example Commands")

![Alt text](http://i.imgur.com/bckO9Wz.png "More examples")

## History
 
Began - 10/22
Error handling logic added - 10/25
Most core functions are complete - 10/26 
 

></content>
  <tabTrigger>readme</tabTrigger>
</snippet>