library(dplyr)

#setwd("/home/anna/Downloads/DirectedStudy")
setwd("/Users/kapsitis/workspace-public/directed-study/eurostat")

codes08_frame <- read.table(file="ISCOcodes08.csv", header=TRUE, sep=",")
codes88_frame <- read.table(file="ISCOcodes88.csv", header=TRUE, sep=",")

all_codes08 <- as.vector(codes08_frame$ISCO08)

all_codes88 <- as.vector(codes88_frame$ISCO88)


eurostat <- read.table(file="Eurostat.csv", header=TRUE, sep=",")
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


# For the given country and year, return the vector with all ISCO codes (with available or unavailable values)
get_isco_codes <- function(country, year) {
  eurostat_filtered <- eurostat %>% filter(COUNTRY == country, YEAR == as.character(year))
  if (year <= 2010) {
    mycodes <- eurostat_filtered$ISCO88_3D
  } else {
    mycodes <- eurostat_filtered$ISCO08_3D
  }
  return(as.vector(mycodes))
}

# For the given country and year, return the vector with all ISCO codes (unavailable/empty values only)
get_empty_isco_codes <- function(country, year) {
  eurostat_filtered <- eurostat %>%
    filter(COUNTRY == country, 
           YEAR == as.character(year),
           grepl("^\\s*$", THS_POP))
  if (year <= 2010) {
    mycodes <- eurostat_filtered$ISCO88_3D
  } else {
    mycodes <- eurostat_filtered$ISCO08_3D
  }
  return(as.vector(mycodes))
}


CountryValues <- c()
YearValues <- c()
ISCOStandardValues <- c()
ValidCodesTotalValues <- c()
ExtraCodesTotalValues <- c()
MissingCodesTotalValues <- c()
UnavailableCodesTotalValues <- c()

ExtraCodesListValues <- c()
MissingCodesListValues <- c()
UnavailableCodesListValues <- c()



for (country in Countries) {
  for (year in 2000:2022) {
    CountryValues <- c(CountryValues, sprintf("%s (%s)", country_names[country], country))
    YearValues <- c(YearValues, year)
    if (year <= 2010) {
      ISCOStandardValues <- c(ISCOStandardValues, "ISCO88")
    } else {
      ISCOStandardValues <- c(ISCOStandardValues, "ISCO08")
    }
    mycodes <- get_isco_codes(country, year)
    unavailable_codes <- as.vector(get_empty_isco_codes(country, year))
    if (year <= 2010) {
      valid_codes <- as.vector(intersect(mycodes, all_codes88))
      extra_codes <- as.vector(setdiff(mycodes, all_codes88))
      missing_codes <- as.vector(setdiff(all_codes88, mycodes))
      unavailable_valid_codes <- as.vector(intersect(unavailable_codes, all_codes88))
    } else {
      valid_codes <- as.vector(intersect(mycodes, all_codes08))
      extra_codes <- as.vector(setdiff(mycodes, all_codes08))
      missing_codes <- as.vector(setdiff(all_codes08, mycodes))
      unavailable_valid_codes <- as.vector(intersect(unavailable_codes, all_codes08))
    }
    valid_codes <- sort(valid_codes)
    extra_codes <- sort(extra_codes)
    missing_codes <- sort(missing_codes)
    unavailable_valid_codes <- sort(unavailable_valid_codes)
    
    ExtraCodesTotalValues <- c(ExtraCodesTotalValues, length(extra_codes))
    ValidCodesTotalValues <- c(ValidCodesTotalValues, length(valid_codes))
    MissingCodesTotalValues <- c(MissingCodesTotalValues, length(missing_codes))
    UnavailableCodesTotalValues <- c(UnavailableCodesTotalValues, length(unavailable_valid_codes))
    
    ExtraCodesListValues <- c(ExtraCodesListValues, paste(extra_codes, collapse = ";"))
    MissingCodesListValues <- c(MissingCodesListValues, paste(missing_codes, collapse = ";"))
    UnavailableCodesListValues <- c(UnavailableCodesListValues, paste(unavailable_valid_codes, collapse = ";"))
  }
}

output_df <- data.frame(Country=CountryValues, 
                        Year=YearValues, 
                        ISCOStandard = ISCOStandardValues, 
                        ValidCodesTotal = ValidCodesTotalValues,
                        ExtraCodesTotal = ExtraCodesTotalValues,
                        MissingCodesTotal = MissingCodesTotalValues,
                        UnavailableCodesTotal = UnavailableCodesTotalValues,
                        ExtraCodesList = ExtraCodesListValues, 
                        MissingCodesList = MissingCodesListValues, 
                        UnavailableCodesList = UnavailableCodesListValues)
write.csv(output_df, "output.csv", row.names = FALSE)

