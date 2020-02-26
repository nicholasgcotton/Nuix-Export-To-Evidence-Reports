# NuixExportToEvidence-Reports (E&R III)
Nuix API Script to support exporting data from Nuix Workstation to Evidence & Reports 3 (E&R III)

This is a ruby script for use with Nuix Investigative Workstation or Nuix eDiscovery workstation (www.nuix.com).

Purpose: Export documents from Nuix with the following file structure (similar to legal export).

Task Number = T###
Task Action Number = TA###
Item Number = _######
such the file(s) for Task 1, Task Action 2 would be in the form
T1_TA2_000001

This script requires the NX.jar: https://github.com/Nuix/Nx
This script uses Nuix API calls documented: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/index.html

This script would not have been possible without the support of the Nuix tech support team.

To Do List
1) Add license checks to avoid attempting EXPORT_LEGAL when it will fail.
2) Add additional options for "SOURCE" column in the report CSV inventory file. 
3) Add ability to export all or some markup sets (currently locked to all). 
4) Add process dialog (borrow code from https://github.com/Nuix/Nukers). 
