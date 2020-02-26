# Nuix Export To Evidence & Reports III (E&R III)
Nuix API Script to support exporting data from Nuix Workstation to Evidence & Reports 3 (E&R III)

This is a ruby script for use with Nuix Investigative Workstation or Nuix eDiscovery workstation (www.nuix.com).

Purpose: Export documents from Nuix with the following file structure (similar to legal export).

Documents: Optionall a) PDFs, b) Natives of kind:spreadsheet c) Natives of all kinds d) PDFs with markup (vetting) [only avaiable with EXPORT_LEGAL license]

Task Number = T(NUMBER)
Task Action Number = TA(NUMBER)
Item Number = _(NUMBER)

such the file(s) for Task 1, Task Action 2 would be in the form

T1_TA2_000001.CSV - INVENTORY REPORT

T1_TA2_000002.PDF - PDF DOCUMENT

T1_TA2_000002.XLS - NATIVE DOCUMENT (Same filename root as the PDF copy of the same document)

rT1_TA2_000001.PDF - PDF DOCUMENT WITH MARKUP (aka VETTING) as applied from within Nuix. Same file name as the PDF COPY, preceeded by "r". 

This script requires the NX.jar: https://github.com/Nuix/Nx
This script uses Nuix API calls documented: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/index.html
This script would not have been possible without the support of the Nuix tech support team, and all the code samples on https://github.com/Nuix.

To Do List:
1) Add license checks to avoid attempting EXPORT_LEGAL (documents with markup) when it will fail.
2) Add additional options for "SOURCE" column in the report CSV inventory file (item.custodian, custom metadata, case name, manual input).
3) Add ability to export all or some markup sets (currently locked to all). 
4) Add process dialog (borrow code from https://github.com/Nuix/Nukers). 
5) Check for depreciated API calls and update as required for Nuix >8. 
