######################################################################################
# ///// Nuix Interpreted Comments BEGIN
# Needs Case: true
# Menu Title: Export by Tag to E&R v2.04 (Vetting Supported)
# encoding: utf-8
# ///// Nuix Interpreted Comments END
# Updates for this script are published at https://github.com/nicholasgcotton/NuixExportToEvidence-Reports
# Uses Nx.jar: https://github.com/Nuix/Nx
# UI and UI error logic taken from the Tag Nuker script: https://github.com/Nuix/Nukers
# Export to E&R Code from Export to E&R v 3A6
# Author: Nicholas COTTON
# Changelog: 
# 2024-01-23
# Added support to catch missing extensions on MSG items.
# 2022-03-30
# 2.03
# Fixed v8 license check API call.
# Added santity check for EXPORT_ITEMS vs EXPORT_LEGAL
# 2022-02-09 2.01
# Fixed progress % reproting.
# 2022-02-09 2.0
# Added progress dialogue. 
# General quality fixes. Should work for Nuix 7 through 9 now.
# Added ability to export emails in EML format.
# Fixed vetting options to require both EXPORT_LEGAL and FAST_REVIEW
# 2020-02-24
# Changed spreadsheet/native export option to ensure it does one or the other but not both
# Fixed true false logic using checklist boolean variables
# Added logic for which options must be used together.
# Changed to only report material children, put some csv items into ""
# Combined markup into main panel to avoid confusion.
# Script will now write your TA for you, although you must still double check it's correct. 
# Commented out code for selecting a subset of markups, as I couldn't figure out how to sort them out.
# 2020-06-23
# 1.71 adds logic to check to for Nuix license features and does not attempt to offer vettting related options when not supported.
# 2021-03-11
# Add github URL. Fixed some internal spelling for comments.
######################################################################################
###########################
# Dependencies/Requirements
###########################
script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.dialogs.ProcessingStatusDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"
LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)
#load File.join(__dir__, 'nx_progress.rb') # v1.0.0
require 'csv' # For the export inventory file
require 'time' # For sanity checking timezone issues in the export inventory file
require "fileutils" # For moving PDFs around and renaming vetted files with the r in front.
require 'set'  # Used for sorting which markup is in use against which markup we want to actually use.
pdf_exporter = $utilities.getPdfPrintExporter() #For the non-vetted export
native_exporter = $utilities.getBinaryExporter  #For exporting native items
email_exporter = $utilities.getEmailExporter # For exporting email items in EML format.
item_sorter = $utilities.getItemSorter() #Depreciated in Nuix 8.0, on the to-do list to use the new call, but for now it still works.
current_licence = $utilities.getLicence 	# Enable license feature checks	
bulk_annotater = $utilities.getBulkAnnotater # For applying a tag to everything that got exported.
export_metadata = "ExportID" 				#Custom Metadata for use with E&R
export_repeats = "ExportID-Duplicates"		#Custom Metadata to store previous ExportIDs. 	
evidence_source = $current_case.name		#For a better then nothing value in the "source" column on the exprot inventory file. 									
########################
# Licence Features Check
########################
# Testing Feature Detection Code, which is API version specific.
puts "Licence type is #{current_licence.getShortName}"
puts "Nuix Version is #{NUIX_VERSION}"
if NUIX_VERSION.to_f > 8
	puts "Licence features are #{current_licence.get_all_enabled_features}"
else
	puts "Unable to list all Nuix license features for this version of Nuix. Checking all features manually."
	puts "Has feature LOTUS_NOTES: #{current_licence.hasFeature("LOTUS_NOTES")}."
	puts "Has feature EXPORT_SINGLE_ITEM: #{current_licence.hasFeature("EXPORT_SINGLE_ITEM")}."
	puts "Has feature EXPORT_ITEMS: #{current_licence.hasFeature("EXPORT_ITEMS")}."
	puts "Has feature EXPORT_LEGAL: #{current_licence.hasFeature("EXPORT_LEGAL")}."
	puts "Has feature EXPORT_VIEW: #{current_licence.hasFeature("EXPORT_VIEW")}."
	puts "Has feature FAST_REVIEW: #{current_licence.hasFeature("FAST_REVIEW")}."
	puts "Has feature OCR_PROCESSING: #{current_licence.hasFeature("OCR_PROCESSING")}."
	puts "Has feature WORKER_SCRIPING: #{current_licence.hasFeature("WORKER_SCRIPING")}."
	puts "Has feature MOBILE_DEVICE_IMAGING: #{current_licence.hasFeature("MOBILE_DEVICE_IMAGING")}."
	puts "Has feature CASE_CREATION: #{current_licence.hasFeature("CASE_CREATION")}."
	puts "Has feature PRODUCTION_SET: #{current_licence.hasFeature("PRODUCTION_SET")}."
	puts "Has feature PARTIAL_LOAD: #{current_licence.hasFeature("PARTIAL_LOAD")}."
	puts "Has feature EXPORT_CASE_SUBSET: #{current_licence.hasFeature("EXPORT_CASE_SUBSET")}."
	puts "Has feature EXCHANGE_WS: #{current_licence.hasFeature("EXCHANGE_WS")}."
	puts "Has feature AUTOMATIC_CLASSIFIER_EDITING: #{current_licence.hasFeature("AUTOMATIC_CLASSIFIER_EDITING")}."
	puts "Has feature WORKER: #{current_licence.hasFeature("WORKER")}."
	puts "Has feature METADATA_IMPORT: #{current_licence.hasFeature("METADATA_IMPORT")}."
	puts "Has feature UNRESTRICTED_CASE_ACCESS: #{current_licence.hasFeature("UNRESTRICTED_CASE_ACCESS")}."
	puts "Has feature SYMANTEC_VAULT: #{current_licence.hasFeature("SYMANTEC_VAULT")}."
	puts "Has feature MAIL_XTENDER: #{current_licence.hasFeature("MAIL_XTENDER")}."
	puts "Has feature AXS_ONE: #{current_licence.hasFeature("AXS_ONE")}."
	puts "Has feature ZANTAZ: #{current_licence.hasFeature("ZANTAZ")}."
	puts "Has feature SOCIAL_MEDIA: #{current_licence.hasFeature("SOCIAL_MEDIA")}."
	puts "Has feature LIGHT_SPEED: #{current_licence.hasFeature("LIGHT_SPEED")}."
	puts "Has feature GWAVA: #{current_licence.hasFeature("GWAVA")}."
	puts "Has feature AOS_DATA: #{current_licence.hasFeature("AOS_DATA")}."
	puts "Has feature GRAPH: #{current_licence.hasFeature("GRAPH")}."
end
# Minimum Required Licence Feature to continue is EXPORT_ITEMS.
if !current_licence.hasFeature("EXPORT_ITEMS")
	CommonDialogs.showError("The current license cannot export files. See scripting console for license capabilities. This script will now exit.")
	exit 1
end
###########################
# Instructions Popup Window
###########################
if !current_licence.hasFeature("EXPORT_LEGAL")
	javax.swing.JOptionPane.showMessageDialog(nil, "Instructions:
	NOTE: This license does not include the neceesary features to autopopulate exported items. 
	You MUST populate binary stores or native stores before attempting to run an export.
	1. Select the single tag for the items you wish to export. 
	2. Choose Export Options (PDFs, spreadsheets, other native files.)
	3. Create/Choose a new empty export directory.
	4. Entere a new unique T#_TA# for your export.
	5. Change Source/RE/Type/Description values to match E&R task (if known).
	6. Check desired vetting/redaction settings.
	8. Hit Ok and Confirm. 
	NOTE: Script is not complete until you are notified by another pop-up.")
	else
		javax.swing.JOptionPane.showMessageDialog(nil, "Instructions:
		1. Select the single tag for the items you wish to export. 
		2. Choose Export Options (PDFs, spreadsheets, other native files.)
		3. Create/Choose a new empty export directory.
		4. Entere a new unique T#_TA# for your export.
		5. Change Source/RE/Type/Description values to match E&R task (if known).
		6. Check desired vetting/redaction settings.
		8. Hit Ok and Confirm. 
		NOTE: Script is not complete until you are notified by another pop-up.")
end
####################
# Create GUI Window
####################
dialog = TabbedCustomDialog.new("Export Tagged Items to E&R")
# Have to calculate some values/layouts for the tags and markups.
all_tags = $current_case.getAllTags.sort
tag_choices = all_tags.map{|t|Choice.new(t)}
# Assume we can't, and then check if we can export markups.
export_markups_possible = false
if current_licence.hasFeature("FAST_REVIEW") && current_licence.hasFeature("EXPORT_LEGAL")
	export_markups_possible = true
	markup_set_lookup = {} 
	$current_case.getMarkupSets.sort_by{|ms|ms.getName}.each{|ms| markup_set_lookup[ms.getName] = ms}
end
# Main setings Tab
#These all pretty much do what they say on the tin.
main_tab = dialog.addTab("settings_tab","Export Settings")
main_tab.appendChoiceTable("tag","Choose One Tag to Export:",tag_choices)
main_tab.appendCheckBox("export_report","Save CSV Report.",true)
main_tab.appendCheckBox("write_ta","Save autogenerated summary task action text",true)
main_tab.appendCheckBox("export_pdfs","Save PDF copies.",true)
main_tab.appendCheckBox("export_emails","Export all email items as .EML files [note: requires available binaries].",false)
main_tab.appendCheckBox("export_spreadsheets","Export native items of spreadsheet files [note: requires available binaries.].",false)
main_tab.appendCheckBox("export_natives","Export native items for all files including emails in their original format [note: requires available binaries.].",false)
main_tab.appendDirectoryChooser("export_directory","Export Directory:")
main_tab.appendTextField("task_taskaction","Task & Task Action numbers:","")
main_tab.appendTextField("report_author","Signature block for report author","Cst. XYZ 12345")
main_tab.appendTextField("evidence_source","\"Source\" for report CSV:","#{evidence_source}")
main_tab.appendTextField("evidence_RE","\"RE\" for report CSV","RE")
main_tab.appendTextField("evidence_TYPE","\"Document Type\" for report CSV","DOCUMENT TYPE")
main_tab.appendTextField("evidence_DESCRIPTION","\"Document Description\" for report CSV","DOCUMENT DESCRIPTION")
if export_markups_possible
	main_tab.appendCheckBox("export_markups","Export Markup (vetted) copies of PDFs [NOTE: Use only when license supports EXPORT-LEGAL (e.g. eDiscovery workstation) or the script will crash.]",false)
	main_tab.appendCheckBox("apply_highlights","Apply Highlights",false)
	main_tab.appendCheckBox("apply_redactions","Apply Redactions",false)
	main_tab.appendStringChoiceTable("markup_set_names","Markup Sets",markup_set_lookup.keys)
end
# Controls which checkboxes are dependent on each other.
main_tab.enabledOnlyWhenChecked("evidence_RE","export_report") 
main_tab.enabledOnlyWhenChecked("evidence_TYPE","export_report")
main_tab.enabledOnlyWhenChecked("report_author","write_ta")
main_tab.enabledOnlyWhenChecked("evidence_DESCRIPTION","export_report")
main_tab.enabledOnlyWhenChecked("evidence_source","export_report")
main_tab.enabledOnlyWhenChecked("export_natives","export_spreadsheets")
if export_markups_possible
	main_tab.enabledOnlyWhenChecked("apply_highlights","export_markups")
 	main_tab.enabledOnlyWhenChecked("apply_redactions","export_markups")
 	main_tab.enabledOnlyWhenChecked("markup_set_names","export_markups")  
end
# Worker settings, not sure I need it, but leaving it in for now, probably only effects the markup/vetted export.
worker_settings_tab = dialog.addTab("worker_settings_tab","Worker Settings")
worker_settings_tab.appendLocalWorkerSettings("worker_settings")
# Validate user settings against predicatable obvious errors. 
dialog.validateBeforeClosing do |values|
	# Make sure user selected at least one tag
	if values["tag"].size < 1 or values["tag"].size > 1
		CommonDialogs.showWarning("You must check one and only one tag.")
		next false
	end
	# Make sure user selected an export_directory
	if values["export_directory"].strip.empty?
		CommonDialogs.showWarning("You must select an export directory.")
		next false
	end
	# Make sure user provided a T/TA
	if values["task_taskaction"].strip.empty?
		CommonDialogs.showWarning("You must input Task & Task Action numbers.")
		next false
	end
	# Make sure user provided an evidence source
		if values["evidence_source"].strip.empty?
		CommonDialogs.showWarning("You must input the source of the evidence (default is the Nuix case name).")
		next false
	end
	# Make sure export options are logical
	if values["export_spreadsheets"] == false && values["export_natives"] == true then
		CommonDialogs.showWarning("If you wish to export both spreadsheets and all other natives click both boxes.")
		next false
	end
	# Get user to confirm that they are about to export some data
	message = "You are about export items from #{values["tag"]} tag. Proceed?"
	title = "Proceed?"
	next CommonDialogs.getConfirmation(message,title)
end
# Display the actual dialog
# If the user cancels this would be the effective exit point, as no code below this will run until the exit popup. 
dialog.display
###################################
# Run script if settings validated
###################################
###################################
# Progress Dialog Outer Shell
###################################
ProgressDialog.forBlock do |progress_dialog|
	# Set the title, and whether an abort button and log area are shown
	progress_dialog.setTitle("Export by Tag to E&R")
	progress_dialog.setAbortButtonVisible(true)
	progress_dialog.setLogVisible(true)
	progress_dialog.setAbortButtonVisible(true)
	progress_dialog.setMainProgress(1,2)
	progress_dialog.setMainStatus("Exporting Items")
#	progress_dialog.logMessage("Stuff is happening: #{Time.now}")

# If user clicked ok and settings validated, lets get to work
	if dialog.getDialogResult == true
		# Pull out settings from dialog into handy variables
		# These are all thing=values["thing"]
		values = dialog.toMap
		tag = values["tag"]
		export_pdfs = values["export_pdfs"]
		export_report = values["export_report"]
		export_emails = values["export_emails"]
		export_spreadsheets = values["export_spreadsheets"]
		export_natives = values["export_natives"]
		export_directory = values["export_directory"]
		task_taskaction = values["task_taskaction"]
		temp_directory = values["export_directory"].gsub(/\\$/,"")+"\\#{task_taskaction}" # I know it's weird to use the tag again for the temp dir, but the production set inherits this name, so it just's cleaner. anyway we intend to delete it.
		evidence_source = values["evidence_source"]
		apply_redactions = values["apply_redactions"]
		worker_settings = values["worker_settings"]
		if export_markups_possible
			apply_highlights = values["apply_highlights"]
			export_markups = values["export_markups"]
			markup_sets = values["markup_set_names"].map{|name| markup_set_lookup[name]} # This is how we do if we are letting the user select a limited set of markup sets. 
		#	markup_sets = $current_case.getMarkupSets 									 # This would force selecting all markup sets. 
		end
		evidence_RE = values["evidence_RE"]
		evidence_TYPE = values["evidence_TYPE"]
		evidence_DESCRIPTION = values["evidence_DESCRIPTION"]
		report_author = values["report_author"]
		write_ta = values["write_ta"]
		###########################################
		# Things that don't need to be in the loop.
		###########################################
		if export_pdfs
			progress_dialog.logMessage("PDFs queued for export.")
			pdf_directory = File.join(export_directory,"PDF")
			java.io.File.new(pdf_directory).mkdirs
		end
		if export_spreadsheets or export_natives
			progress_dialog.logMessage("Natives queued for export.")
			native_directory = File.join(export_directory,"Natives")
			java.io.File.new(native_directory).mkdirs
		end
		if export_emails
			progress_dialog.logMessage("Emails (.EML format) queued for export.")
			email_directory = File.join(export_directory,"EML")
			java.io.File.new(email_directory).mkdirs
		end
		if export_report
			progress_dialog.logMessage("Metadata CSV queued for export.")		
		end
		if task_taskaction
			progress_dialog.logMessage("Task Action Report queued for export.")
		end
		if export_markups
			progress_dialog.logMessage("Vetted Items queued for export")
		end
		# Organize/Rank Items by Top Level Item Date
		search_items = $current_case.search("tag:\"#{tag.first}\"") 	      #.first becasue the single tag still gets passed as an array for some reason. 
		export_items = item_sorter.sortItemsByTopLevelItemDate(search_items)
		##########################################################
		# Creation of ExportID and Running the Single Item Exports
		##########################################################
		## This logic assigns the T/TA number metadata and subsequently exports whatever has been requested (not including markup which is done later).
		## The same loop is required for PDF, Spreadsheet, Native exports as well as CSV file creation, even if only one of those is getting done. 
		progress_dialog.setSubStatus("Exporting Requested Items...")
		progress_dialog.setSubProgress(0,export_items.size)
		export_items.each_with_index do |item,item_index| # Start Export Loop
			progress_dialog.setSubProgress(item_index+1)
			####Generate Unique ID in order of TopLevelItemDate 
			####(keeps emails and attachments together) starting from 0002
			base_number_string = (item_index+2)
			padded_number_string = base_number_string.to_s.rjust(7,"0")	
			### Determine the ID number		
			id_num = "#{task_taskaction}_#{padded_number_string}"				
			##### Enter or Updated ExportID custom metadata #
			# Get the item's custom metadata map
			item_custom_metadata = item.getCustomMetadata 
			# Get current ExportID value if present (checks for nil later)
			exportID_value = item_custom_metadata[export_metadata] 
			# Get current exportIDdup value if present (checks for nil later)
			previous_exportID_values = item_custom_metadata[export_repeats] 
			if exportID_value.nil?
				# If exportID is nil no complex thoughts aree required, as there are no duplicates to track.
				exportID_value = id_num	
			else
				# To backup ExportID to exportIDdup first check if exportIDdup already has a value.
				if previous_exportID_values.nil?	
					# If it's empty then put the old and new to start with both duplicates.
					previous_exportID_values = id_num + ", " + exportID_value 
				else
					# If it's NOT empty then ADD the new ID to the previous string. 
					previous_exportID_values = id_num + ", " + previous_exportID_values 
				end
				exportID_value = id_num
				item_custom_metadata[export_repeats] = previous_exportID_values
			end
			item_custom_metadata[export_metadata] = exportID_value
			# Begin Tracking of ExportID on Duplicates of Exported item.
			duplicates = item.getDuplicates
			duplicates.each_with_index do |item,item_index|
				duplicates_custom_metadata = item.getCustomMetadata
				duplicate_exportID = item_custom_metadata[export_metadata]
				if previous_exportID_values.nil?
					duplicates_custom_metadata[export_metadata] = "Duplicate of #{exportID_value}"
				else 
					duplicates_custom_metadata[export_repeats] = "Duplicate of #{previous_exportID_values}"
				end
			end 
			# Start per-file Export Section
			# A) Optionally Export PDFs 																	
			if export_pdfs
				pdf_file_name = "#{id_num}.PDF" 	# Determine the PDF file name
				pdf_export_file_path = File.join(pdf_directory,pdf_file_name)		# File name + path
				pdf_exporter.exportItem(item,pdf_export_file_path)
				progress_dialog.logMessage("Successfully Exported PDF: #{pdf_file_name} from item #{item.guid}") 
			end
			# B) Optionally export the native for spreadsheets, emails, or all natives. 
			# Allows for Spreadsheets and Email, Spreadsheets and Natives and Email, just Spreadsheets, just Email. Native implies spreadsheets but Email does not imply Natives or Spreadsheets.	
			# This requires the binaries to be populated, although it should also work with acess to the evidence files.
			if export_spreadsheets && !export_natives  then
				kind = "#{item.kind}"
				if kind == "spreadsheet" then
					extension = item.getOriginalExtension
					if extension.nil?
						extension = ".csv" # Ugly but it works.
					end
					native_file_name = "#{id_num}.#{extension}"
					native_export_file_path = File.join(native_directory,native_file_name)
					native_exporter.exportItem(item,native_export_file_path)
					progress_dialog.logMessage("Successfully Exported Native: #{native_file_name} from item #{item.guid}") 
				end
				else if export_spreadsheets && export_natives then 
					extension = item.getOriginalExtension
					if kind == "spreadsheet" && extension.nil?
						extension = "csv" # Ugly but it works, redux.
					end
                    if kind = "email" && extension.nil?
                        extension = "msg" # Ugly but it should work
                        # This is a hack and it would be better to somehow
                        # look up the correct extension for each item, but for now this will work.
                    end
					native_file_name = "#{id_num}.#{extension}"
					native_export_file_path = File.join(native_directory,native_file_name)
					native_exporter.exportItem(item,native_export_file_path)
					progress_dialog.logMessage("Successfully Exported Native: #{native_file_name} from item #{item.guid}")
				end
			end
			# Note Exporting Emails may be instead of OR in addition to Exporting all natives. This option forces .EML format.
			if export_emails then
				email_file_name = "#{id_num}.eml"
				email_export_file_path = File.join(email_directory,email_file_name)
				email_exporter.exportItem(item,email_export_file_path,{"format"=>"eml","includeAttachments"=>true})
				progress_dialog.logMessage("Successfully Exported Email: #{email_file_name} from item #{item.guid}")
			end
			if progress_dialog.abortWasRequested
				progress_dialog.logMessage("User has requested abort...")
				progress_dialog.setSubStatus("Aborting...")
				break
			end
		end		
			# End Native, Email, and or Spreadsheet items export section.
			##############################################
			# Create Item 001 inventory csv if requested.
			##############################################
			# Note, the first actual item will always be number 2, even if the CSV report #1 is not requested. I'm not going to change this becuase I think consistanty is less confusing, even when not totally logical. 
		if export_report then
			export_filename = "#{task_taskaction}_00001.csv"							
			report = File.join(export_directory,export_filename)						
			CSV.open(report, "w") do |writer|          									
				# Write header for CSV	
				writer << ["Filename/ExportID", "ExportID-Duplicates", "Vetting Codes", "Document Title", "RE", "Document Type", "Document Description", "Document Summary", "Source", "Document Date", "Document Time", "Original File Name", "Original File Type", "Evidence Path", "Attached or Embedded Items", "Nuix GUID", "Hash Values"]
				# Write contents for CSV based on each item.
				export_items.each_with_index do |item,item_index| # Runs script on as defined by original search way above. 
					exportid_forcsv = item.getCustomMetadata[export_metadata]
					exportiddup_forcsv = item.getCustomMetadata[export_repeats]
					t1 = Time.parse("#{item.date}") # needs to be tested against .nil?
					local_time = t1.getlocal
					csv_itemdate = local_time.strftime("%Y-%m-%d")
					csv_itemtime = local_time.strftime("%k:%M")
					child_items = item.getChildren
					material_children = child_items.select{|i|i.isAudited} # List of ONLY material items that are children of the given item. 
					if export_markups then
						writer << [exportid_forcsv, exportiddup_forcsv, item.getMarkupSets, item.name, "#{evidence_RE}", "#{evidence_TYPE}", "#{evidence_DESCRIPTION}", "#{item.comment}", evidence_source, csv_itemdate, csv_itemtime, item.name, "#{item.kind.getLocalisedName}", "#{item.getLocalisedPathNames}", "#{material_children}", "#{item.guid}", item.digests] 
					else
						writer << [exportid_forcsv, exportiddup_forcsv, "Vetting Not in Use", item.name, "#{evidence_RE}", "#{evidence_TYPE}", "#{evidence_DESCRIPTION}", "#{item.comment}", evidence_source, csv_itemdate, csv_itemtime, item.name, "#{item.kind.getLocalisedName}", "#{item.getLocalisedPathNames}", "#{material_children}", "#{item.guid}", item.digests]	
					end
				end
				progress_dialog.logMessage("Successfully Created CSV Metadata Report.")
			end
			if progress_dialog.abortWasRequested
				progress_dialog.logMessage("User has requested abort...")
				progress_dialog.setSubStatus("Aborting...")
				break
			end
		end
		progress_dialog.logMessage("Successfully Completed Requested Single Items Exports and Reports.")
		##############################
		# Legal Export of Markup Items
		###############################
		#Attempt legal export with stamped/vetted/redacted pdfs too, if requested (and it can only be requested if possible).
		#This has the side effect of creating a production set with a totally unrelated item number within Nuix. Recommend: ignore those or delete when done. 
		if export_markups then
			# Setup exporter for PDF export
			progress_dialog.setSubStatus("Exporting Vetted Items")
			progress_dialog.logMessage("Exporting Vetted Items... (background task)")
			exporter = $utilities.createBatchExporter(temp_directory)
			exporter.setMarkupSets(markup_sets,{
				"applyRedactions" => values["apply_redactions"],
				"applyHighlights" => values["apply_highlights"],
			})
			# Configure it to use worker settings specified by user
			exporter.setParallelProcessingSettings(worker_settings)
			# Not surprisingly we need to export PDFs
			exporter.addProduct("pdf",{
				"naming" => "guid",
				"path" => "VettedPDFs",
				"regenerateStored" => "false",
			})
			exporter.exportItems(export_items)
			Dir.glob("#{temp_directory}/**/*.pdf").each do |pdf_file|
				guid = File.basename(pdf_file,".*")
				pdf_path = pdf_file.gsub("/","\\")
				vet_items = $current_case.search("guid:#{guid}")
				vet_items.each_with_index do |item,item_index| # Renaming looop. This will only keep items with markup/vetting and will delete everything else. 
					markup_inuse = item.getMarkupSets
					if markup_inuse.empty?
						puts "No vetted copy required: skipping item with guid:#{guid}"
						else
						item_custom_metadata = item.getCustomMetadata 
						# Get current ExportID value if present (checks for ? later)
						exportID_target = item_custom_metadata[export_metadata]
						exportID_target = "r" + exportID_target
						puts "Vetted copy required and created at: ExportID target name: #{exportID_target}"
						rpdf_file_name = "#{exportID_target}.PDF" 	# Determine the PDF file name
						rpdf_file_path = File.join(export_directory,rpdf_file_name)		# File name + path
						FileUtils.mv(pdf_file,rpdf_file_path)
					end
				end
			end
			org.apache.commons.io.FileUtils.deleteDirectory(java.io.File.new(temp_directory))
		else
			progress_dialog.logMessage("Not exporting vetted versions")
		end
	###########################################################################################################################
	# This section writes the TA text for use in E&R, using the input from the initial dialog and the computer's current time. 
	###########################################################################################################################
	progress_dialog.setMainProgress(2,2)
	progress_dialog.setMainStatus("Finalizing")
	if write_ta then
		taskaction_file = "#{task_taskaction}.txt"
		taskaction_file = File.join(export_directory,taskaction_file)
		t2 = Time.now 
		local_time = t2.getlocal
		report_date = local_time.strftime("%Y-%m-%d")
		report_time = local_time.strftime("%k:%M")
		count_items = $current_case.search("tag:\"#{tag.first}\"").count
		last_attachment = count_items + 1 # Since item 0001 is the spreadsheet.
		file = File.open(taskaction_file, "w") { |file| file.write("Nuix Export from Tag:\"#{tag.first}\" \n\nOn #{report_date} at #{report_time} hours, #{report_author} exported #{count_items} items from Nuix case #{evidence_source} to E&R #{task_taskaction}. \n\n#{report_author}\n(NOTE: TA Text auto generated by E&R Export Script based on user input, verify accurancy then remove this note)\n\nAttachments\n#{task_taskaction}_00001.CSV #{evidence_DESCRIPTION}: INVENTORY SPREADSHEET \nInventory spreadsheet describing #{count_items} items exported from tag \"#{tag.first}\" to #{task_taskaction} on #{report_date}. Items are numbered from 2 to #{last_attachment}, this inventory spreadsheet is item 1. ") }
		progress_dialog.setSubStatus("Exporting Task Action report...")
		progress_dialog.logMessage("Task Action text report created.")
	end
	########################################
	# Track exported items via specific tag.
	########################################
	bulk_annotater.addTag("Exported|#{task_taskaction}",export_items) # Adds tag tracking which items were exported in which dataset. Items can have multiple tags if exported multiple times.
	end
	########
	#The End
	########
	progress_dialog.setSubStatus("")
	if progress_dialog.abortWasRequested
		progress_dialog.setMainStatus("Completed: User Aborted")
	else
		# Convenience method to set the progress dialog into a Completed state
		progress_dialog.setMainStatus("Completed.")
		progress_dialog.logMessage("Export Script Completed.")
		progress_dialog.setCompleted
	end
end
