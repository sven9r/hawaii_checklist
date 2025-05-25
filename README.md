# Hawaiʻi Checklist Versioning

This repository tracks successive versions of our specimen checklist, automatically logging changes in sequence coverage and species counts.

## Prerequisites

* R ≥ 4.0 with the packages: **fs**, **here**, **readxl**, **openxlsx**, **dplyr**, **stringr**
* A file `versionized.R` defining `write_versioned_checklist()`

## Workflow

1. **Edit the Checklist**

   * Open the most recent `checklist_V*.xlsx` in `data/`.
   * Make your changes (add specimens, correct metadata, etc.).
   * **Save** as a **new** Excel file in `data/` named with today’s date and the next version number, e.g.:

     ```
     2025-06-05_checklist_V3.xlsx
     ```

2. **Load the Versioning Function**
   In your R session, source the helper script:

   ```r
   source("versionized.R")
   ```

   This provides the function:

   ```r
   write_versioned_checklist(df_curr, data_dir = "data")
   ```

3. **Read in Your Edited Sheet**

   ```r
   library(readxl)
   library(here)

   # Replace with your actual filename and sheet
   new_df <- read_excel(
     here("data", "2025-06-05_checklist_V3.xlsx"),
     sheet = "checklist_V3"
   )
   ```

4. **Generate the Next Version with a Log**

   ```r
   write_versioned_checklist(new_df, data_dir = here("data"))
   ```

   * The function auto‑detects the last `Vn` file,
   * Appends your delta summary to the **log** sheet,
   * Regenerates the **readME** metadata,
   * Writes a new `checklist_V(n+1).xlsx` (e.g. `2025-06-05_checklist_V4.xlsx`).

5. **Inspect the Version History**
   Open the **log** sheet in the new workbook or view the summary table below:

| Version | Date       | Total Entries | Entries With Sequence | Unique Species With Seq | % With Sequence | Δ Entries | Δ Species | Δ %Seq | Summary                                       |
| ------- | ---------- | ------------- | --------------------- | ----------------------- | --------------- | --------- | --------- | ------ | --------------------------------------------- |
| V1      | 2025-05-24 | 12,764        | 3,091                 | 2,599                   | 24.22%          | —         | —         | —      | —                                             |
| V2      | 2025-05-25 | 12,766        | 3,093                 | 2,601                   | 24.23%          | +2        | +2        | +0.01% | 2 species added; 2 sequences added; +0.01%    |
| V3      | 2025-06-05 | 12,800        | 3,200                 | 2,650                   | 25.00%          | +107      | +49       | +0.77% | 49 species added; 107 sequences added; +0.77% |

---

> **Tip:** Always keep your `data/` folder in sync with your Git history so collaborators can pull the latest versions and re‑run the versioning function themselves.
