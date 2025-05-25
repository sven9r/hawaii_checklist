#USAGE EXAMPLE


Then simply call the new function:
source("versionized.R")
write_versioned_checklist()

How dooes it work?
When editing any version of the checklist, make sure to versionize again.
1.For that safe your changed in a NEW excel file into the data folder.
Keep in mind the versionized files need to be named: YYYY-MM-DD_checklist_Vx.xlsx
My script will search for all versions that are being tagged with V1, V2, V3 [...] etc.
2. Use the function I created to initalize/update a log sheet in our versionzied files.
For that call source("versionized.R") - your environment should have a function called write_versioned_checklist()
3. load your edited version into the environment, for example:
new_version <- read_excel(here("data", "test.xlsx"), sheet="checklist_V1") 
4. Use the new new function with your edited file.
The function will tage the last version available to create a new versionized file with a comprehensive LOG:
write_versioned_checklist(new_version, data_dir="data")

5. enjoy the log:
Version	Date	Total_Entries	Entries_With_Sequence	Unique_Species_With_Seq	Percent_With_Sequence	Δ_Entries_With_Seq	Δ_Unique_Spp_With_Seq	Δ_Percent_With_Seq	Summary
V1	5/25/25	12764	3091	2599	24.22				
V2	5/24/25	12766	3093	2601	24.23	2	2	0.01	2 species added; 2 sequences added; Pct Δ: 0.01%
