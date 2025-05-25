library(fs)
library(here)
library(readxl)
library(openxlsx)
library(dplyr)
library(tidyr)
library(purrr)



write_versioned_checklist <- function(df_curr,
                                      data_dir = here("data")) {
  # 1) find prior versions
  prev_files <- dir_ls(data_dir, regexp = "_checklist_V\\d+\\.xlsx$")
  if (length(prev_files)==0) {
    old_path    <- NULL
    old_version <- 0
  } else {
    prev_info <- tibble(path = prev_files,
                        version = as.integer(str_extract(path, "(?<=_checklist_V)\\d+(?=\\.xlsx)"))) %>%
      arrange(version)
    old_path    <- prev_info$path[nrow(prev_info)]
    old_version <- prev_info$version[nrow(prev_info)]
  }
  new_version <- old_version + 1
  
  # 2) build filenames & sheet names
  date_stamp <- format(Sys.Date(), "%Y-%m-%d")
  new_sheet  <- paste0("checklist_V", new_version)
  out_file   <- here(data_dir,
                     paste0(date_stamp, "_checklist_V", new_version, ".xlsx"))
  
  # 3) load previous data (if exists)
  if (!is.null(old_path)) {
    df_prev <- read_excel(old_path, sheet = paste0("checklist_V", old_version))
  } else {
    df_prev <- df_curr[0,]  # empty template for v1
  }
  
  # 3a) schema consistency check
  # (we’ll get col_desc below, so just check against df_prev if you like)
  
  # 3b) automatic import of column descriptions
  if (!is.null(old_path) && "readME" %in% excel_sheets(old_path)) {
    # skip first 6 rows to jump to the metadata table
    col_info_old <- read_excel(old_path,
                               sheet = "readME",
                               skip  = 6,
                               col_names = c("Column","Class","NA_Count","Unique_Values","Description"))
    col_desc <- setNames(col_info_old$Description, col_info_old$Column)
  } else {
    stop("No prior 'readME' sheet found; please run once with a manual col_desc.")
  }
  
  # 4) summary metrics
  make_summary <- function(df, version, date) {
    tibble(
      Version                 = paste0("V", version),
      Date                    = date,
      Total_Entries           = nrow(df),
      Entries_With_Sequence   = sum(!is.na(df$sequence)),
      Unique_Species_With_Seq = n_distinct(df$species[!is.na(df$sequence)]),
      Percent_With_Sequence   = round(Entries_With_Sequence / Total_Entries * 100, 2)
    )
  }
  summ_prev <- make_summary(df_prev, old_version,
                            if (!is.null(old_path)) as.Date(file_info(old_path)$birth_time)
                            else Sys.Date())
  summ_curr <- make_summary(df_curr, new_version, Sys.Date())
  
  # 5) build or append history
  new_entry <- summ_curr %>%
    mutate(
      Δ_Entries_With_Seq    = Entries_With_Sequence   - summ_prev$Entries_With_Sequence,
      Δ_Unique_Spp_With_Seq = Unique_Species_With_Seq - summ_prev$Unique_Species_With_Seq,
      Δ_Percent_With_Seq    = Percent_With_Sequence   - summ_prev$Percent_With_Sequence,
      Summary = paste0(
        abs(Δ_Unique_Spp_With_Seq), ifelse(Δ_Unique_Spp_With_Seq>0," species added; "," species deleted; "),
        abs(Δ_Entries_With_Seq),    ifelse(Δ_Entries_With_Seq>0," sequences added; "," sequences deleted; "),
        "Pct Δ: ", round(Δ_Percent_With_Seq,2), "%"
      )
    )
  
  if (!is.null(old_path) && "log" %in% excel_sheets(old_path)) {
    old_log <- read_excel(old_path, sheet = "log")
    history <- bind_rows(old_log, new_entry)
  } else {
    warning("No prior 'log' sheet—starting fresh with V1 summary.")
    history <- bind_rows(
      summ_prev %>% mutate(Δ_Entries_With_Seq=NA, Δ_Unique_Spp_With_Seq=NA,
                           Δ_Percent_With_Seq=NA, Summary=NA),
      new_entry
    )
  }
  
  # 6) build new readME metadata table
  col_info <- tibble(
    Column        = names(df_curr),
    Class         = sapply(df_curr, function(x) paste(class(x), collapse=", ")),
    NA_Count      = sapply(df_curr, function(x) sum(is.na(x))),
    Unique_Values = sapply(df_curr, function(x) length(unique(x)))
  ) %>% mutate(Description = col_desc[Column])
  
  # 7) write workbook
  wb <- createWorkbook()
  addWorksheet(wb, "log");     writeData(wb, "log", history, startRow=1)
  addWorksheet(wb, "readME");  writeData(wb, "readME",
                                         c("This workbook contains three sheets:",
                                           " • log:    version history summary",
                                           " • readME: column metadata & descriptions",
                                           paste0(" • ", new_sheet, ": the cleaned dataset"),
                                           ""),
                                         startRow=1, colNames=FALSE)
  writeData(wb, "readME", col_info, startRow=7)
  addWorksheet(wb, new_sheet); writeData(wb, new_sheet, df_curr)
  saveWorkbook(wb, out_file, overwrite=TRUE)
  message("Wrote: ", out_file)
}
