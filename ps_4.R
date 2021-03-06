library(janitor)
library(devtools)
library(readxl)
library(lubridate)
library(gt)
library(ggthemes)
library(tidyverse)

a <- read_csv("ps_4_elections-poll-nc09-3.csv",
              col_types = cols(
                .default = col_character(),
                turnout_scale = col_double(),
                turnout_score = col_double(),
                w_LV = col_double(),
                w_RV = col_double(),
                final_weight = col_double(),
                timestamp = col_datetime(format = "")
              )) %>% 
  clean_names() %>%
  filter(!is.na(response), 
         !is.na(race_eth), 
         !is.na(final_weight))

a$response[a$response == "3"] <- "three"

table_data <- a %>% 
  select(response, race_eth, final_weight) %>% 
  group_by(response, race_eth) %>% 
  summarize(total = sum(final_weight, na.rm = TRUE)) %>% 
  spread(key = response, value = total) %>%
  ungroup() %>% 
  group_by(race_eth) %>% 
  mutate(all = sum(Dem, Rep, Und, three, na.rm = TRUE)) %>% 
  mutate(Dem = Dem / all,
         Rep = Rep / all,
         Und = Und / all) %>% 
  ungroup() %>% 
  select(race_eth, Dem, Rep, Und) %>% 
  slice(match(c("White", "Black", "Hispanic", "Asian", "Other"), race_eth))

gt(table_data) %>% 
  cols_label(
    Dem = "DEM.",
    Rep = "REP.",
    Und = "UND.",
    race_eth = ""
    ) %>% 
  fmt_percent(columns = vars(Dem, Rep, Und), decimals = 0) %>% 
  tab_style(style = cells_styles(bkgd_color = "#fbfafb", text_color = "#666666"), locations = cells_data()) %>%
  tab_style(style = cells_styles(bkgd_color = "#ffffff", text_color = "#666666"), locations = cells_data(columns = 1)) %>%
  tab_style(style = cells_styles(bkgd_color = "#dd0d27", text_color = "#ffffff"), locations = cells_data(columns = 3, rows = 1)) %>% 
  tab_style(style = cells_styles(bkgd_color = "#dd0d27", text_color = "#ffffff"), locations = cells_data(columns = 3, rows = 3)) %>%
  tab_style(style = cells_styles(bkgd_color = "#dd0d27", text_color = "#ffffff"), locations = cells_data(columns = 3, rows = 4)) %>% 
  tab_style(style = cells_styles(bkgd_color = "#0089c6", text_color = "#ffffff"), locations = cells_data(columns = 2, rows = 2)) %>% 
  tab_style(style = cells_styles(bkgd_color = "#0089c6", text_color = "#ffffff"), locations = cells_data(columns = 2, rows = 5))
            