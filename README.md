# Nuix Export To Evidence & Reports III (E&R III)
Nuix API Script to support exporting data from Nuix Workstation to Evidence & Reports 3 (E&R III)

This is a ruby script for use with Nuix Investigative Workstation or Nuix eDiscovery workstation (www.nuix.com).

## Purpose: 

Export documents from Nuix with a file structure approprioate for use with RCMP E&R III, including an inventory load file in CSV format that can be used to load all items exported from Nuix directly into E&R. 

## Installation (Required)
For the script to function you must: 
- Download [Export by Tag to E&R v1.71 Vetting.rb](https://github.com/nicholasgcotton/NuixExportToEvidence-Reports/blob/master/Export%20by%20Tag%20to%20E%26R%20v1.71%20Vetting.rb)
- Download [NX.jar](https://github.com/Nuix/Nx)
- Install both files to one of the Nuix scripts directories, on Windows, for example:
  - %appdata%\Nuix\Scripts - User level script directory
  - %programdata%\Nuix\Scripts - System level script directory

### Installation (Optional)
If you wish to view the ExportID and ExportID-Duplicates values within Nuix Workstation you can create a metadata profile that shows those custom metadata values. Alternatively, the "Export Load File.profile" below mirrors the inventory load file created by the script.
- Download [Export Load File.profile](https://github.com/nicholasgcotton/NuixExportToEvidence-Reports/blob/master/Export%20Load%20File.profile) and install to one of the Nuix Metadata Profiles directories, on Windows, for example:
  - %appdata%\Nuix\Metadata Profiles - User level Metadata Profile directory
  - %programdata%\Nuix\Metadata Profiles - System level Metadata Profile directory

## Production Options:
- Documents (Any/All as needed)
  - PDFs, 
  - Natives of kind:spreadsheet, 
  - Natives of all kinds, 
  - PDFs with markup (vetting) [only avaiable with EXPORT_LEGAL license].
- Load File (Recommended)
- Task Action report text (Optional)

## Naming Convention (generated based on user input)
- Task Number = T(NUMBER)
- Task Action Number = TA(NUMBER)
- Item Number = _(NUMBER) [Autogenerated]

### Resulting files (example input T1_TA2)
- T1_TA2.TXT - TASK ACTION (EXPORT REPORT)
- T1_TA2_000001.CSV - INVENTORY REPORT
- T1_TA2_000002.PDF - PDF DOCUMENT
- T1_TA2_000002.XLS - NATIVE DOCUMENT (Same filename root as the PDF copy of the same document)
- rT1_TA2_000001.PDF - PDF DOCUMENT WITH MARKUP (aka VETTING) as applied from within Nuix. Same file name as the PDF COPY, preceeded by "r". 

## User Interface
- Instructions Popup Window

![Instructions_V1 7](https://user-images.githubusercontent.com/24242174/75466151-c0ce6500-5957-11ea-9718-591115734632.png)

- Main User Interface

![UserInterface_V1 7](https://user-images.githubusercontent.com/24242174/75466153-c166fb80-5957-11ea-9f01-d06dd7f0203f.png)
(Note: "Export Markup", "Apply Highlights", and "Apply Redactions" options will only show when using Nuix eDiscovery Workstation with the "legal export" license feature.)

## Inventory Load file Specifications

If requested, the script will create a T#_TA#_000001.CSV file with the following information.

Load File Item | Sourced From (Nuix API call)
------------ | -------------
Filename/ExportID | Generated from the Task and Task Action numbers provided by the user. 
ExportID-Duplicates | List of any previous ExportIDs for that item.
Vetting Codes | Any markup applied to the item within Nuix (item.getMarkupSets), or hardcoded to "Vetting Not in Use" when that license feature is not supported.
Document Title | Original Filename (item.name)
RE | User input
Document Type | User input
Document Description | User input
Document Summary | Comment (item.comment)
Source | User input or current case name ($current_case.name)
Document Date | Item Date in local timezone (Time.parse("#{item.date}") + getLocal)
Document Time | Item Time in local timezone (Time.parse("#{item.date}") + getLocal)
Original File Name | Original Filename (item.name), same as "Document Title" since that column may need to be shortened for use in E&R
Original File Type | Nuix file kind (item.kind.getLocalisedName)
Evidence Path | Original path of item (item.getLocalisedPathNames)
Attached or Embedded Items | Material Child Items (item.getchildren + isAudited)
Nuix GUID | Nuix GUID unique ID (item.guid)
Hash Values | All hash values calculated for the item (e.g. MD5/SHA1) (item.digests)

## Task Action Report Text Specifications

If requested the script will create a T#_TA#.TXT file with the following text. 

> Nuix Export from Tag:{tag}
>
> On #{report_date} at #{report_time} hours, #{report_author} exported #{count_items} items from #{evidence_source} to E&R #{task_taskaction}. 
>
> #{report_author}
>
> (NOTE: TA Text auto generated by E&R Export Script based on user input, verify accurancy then remove this note)
>
> Attachments
> 01 #{evidence_DESCRIPTION}: INVENTORY SPREADSHEET
>
> Inventory spreadsheet describing #{count_items} items exported from tag \"#{tag}\" to #{task_taskaction} on #{report_date}. Items are numbered from 2 to #{last_attachment}, this inventory spreadsheet is item 1. ")

## Notes:
1) This script requires the NX.jar: https://github.com/Nuix/Nx
2) This script uses Nuix API calls documented: https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/index.html

## Thanks
1) This script would not have been possible without the support of the @Nuix tech support team, and all the code samples on https://github.com/Nuix.

### To Do List:
1) Add additional options for "SOURCE" column in the report CSV inventory file (item.custodian, custom metadata, case name, manual input).
2) Add ability to export all or some markup sets (currently locked to all). 
3) Add process dialog (borrow code from https://github.com/Nuix/Nukers). 
4) Check for depreciated API calls and update as required for Nuix >8. 
5) Add check for populated-stores for exporting each document type (PDF, Native). Currently it will fail badly if/when you attempt to export data that does not exist or is not available to the Nuix workstation app (e.g. if you have moved the evidence files and try to export natives). Workaround: populate stores (PDF/Native) of the type you intend to export ahead of time.

#### Completed Items
1) As of v1.71: Add license checks to avoid attempting EXPORT_LEGAL (documents with markup) when it will fail. Uses code from: https://github.com/Nuix/Export-Family-PDFs

### Known Bugs:
1) When exporting documents with markup (vetted documents) a Production set is created. Issue: Gives the appearance of a production set for every export, which is not the case. Current solution: ignore production sets. Goal Solution: Delete unnecessary production set after export is complete.
2) Crashes when attempting to export items (either PDFs or Natives) that are not accessible (in the case of PDFs this means not generated, in the case of natives this most likely means your evidence has moved). Workaround: Use Nuix feature "populate stores" for the PDFs or Natives on the items you wish to export before calling the script. 
3) Script sorts items by TopLevelITem date to ensure attachments follow their parent emails, regardless of the date of the attachment. For some reason it's occassionally possible to have PST files with no date attribute in Nuix. There is a work around for this, please get in touch if you need it. 

### Known Limitiations
1) Due to a limitation within Nuix there is no option to show the border/box around markup areas without actually applying the vetting and blacking out that area. (

## License

Copyright [2020] Nicholas Grant Cotton

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
