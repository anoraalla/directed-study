library(dplyr)

setwd("/home/anna/Downloads/DirectedStudy")
codes<-read.table(file="csv-codes.csv", header=TRUE, sep=",")
eurostat<-read.table(file="Eurostat.csv", header=TRUE, sep=",")
# table(eurostat$YEAR[eurostat$COUNTRY=="RO"])
Countries<-c("AT","BE","BG","CH","CY","CZ","DE","DK",
             "EE","EL","ES","EU27_2020","EU28","FI","FR","HR",
             "HU","IE","IS","IT","LT","LU","LV","ME",
             "MK","MT","NL","NO","PL","PT","RO","RS",
             "SE","SI","SK","TR","UK")
country_names <- c(AT="Austria",BE="Belgium",BG="Bulgaria",CH="Switzerland",CY="Cyprus",
                   CZ="Czechia",DE="Germany",DK="Denmark",EE="Estonia",EL="Greece",
                   ES="Spain",EU27_2020="EU",EU28="EU+UK",FI="Finland",FR="France",
                   HR="Croatia",HU="Hungary",IE="Ireland", IS="Iceland", IT="Italy",
                   LT="Lithuania", LU ="Luxembourg", LV="Latvia", ME="Montenegro",MK="North Macedonia",
                   MT="Malta", NL="Netherlands", NO="Norway", PL="Poland", PT="Portugal", 
                   RO="Romania", RS="Serbia", SE="Sweden", SI="Slovenia",SK="Slovakia",
                   TR="Turkey", UK ="United Kingdom")
for (country in Countries) {
  for (year in 2000:2022) {
    CodeCount <- nrow(eurostat[eurostat$COUNTRY==country && eurostat$YEAR==year])
    if (CodeCount==0) { 
      print("missing")
    }
  }
}



new_df <- eurostat %>%
  mutate(ISCOStandard = ifelse(ISCO88_3D != "Not stated", "ISCO88", "ISCO08")) %>%
  select(COUNTRY, YEAR, ISCOStandard) %>%
  distinct()

print(new_df)
