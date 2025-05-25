
# ── USAGE EXAMPLE ─────────────────────────────────────────────────────────────
# Define your column descriptions first, e.g.:
# col_desc <- c(phylum="…", class="…", …)
#
# Then simply call:
# write_versioned_checklist(V1_final, data_dir="data", col_desc=col_desc)

source("versionized.R")
new_version <- read_excel(here("data", "test.xlsx"), sheet="checklist_V1") 
write_versioned_checklist(new_version, data_dir="data")

# ── END OF USAGE EXAMPLE ────────────────────────────────────────────────────