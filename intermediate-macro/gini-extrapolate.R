# Load necessary libraries
library(readr)  # for read_csv
library(dplyr)  # for data manipulation
library(ggplot2)


print_gini_for_spreadsheet <- function(gini_vector) {
  # Loop through each element of the vector
  for(i in names(gini_vector)) {
    # Print year and value separated by a tab (you can change "\t" to "," for comma separation)
    cat(i, gini_vector[i], "\n", sep = "\t")
    # cat(sprintf("%s\t%2f1",i,gini_vector[i]))
  }
}



interpolate_and_plot_gini <- function(gini) {
  # Extract actual available years and values
  actual_years <- as.numeric(names(gini))
  actual_values <- gini
  
  # Create data frame from vectors
  data <- data.frame(Year = actual_years, Gini = actual_values)
  
  # Linear model using existing non-NA values
  fit <- lm(Gini ~ Year, data = na.omit(data))
  
  # Predict missing values using the model
  predicted_values <- predict(fit, newdata = data.frame(Year = actual_years))
  
  # Merge the actual and predicted values
  data$Gini_Interpolated <- ifelse(is.na(data$Gini), predicted_values, NA)
  
  # Updated `gini` vector with interpolated values
  gini_updated <- ifelse(is.na(gini), round(predicted_values, 1), gini)
  
  # Plotting
  myplot <- ggplot(data, aes(x = Year)) +
    geom_point(aes(y = Gini), color = "blue", size = 3) +
    geom_point(aes(y = Gini_Interpolated), color = "red", shape = 1, size = 3) +
    labs(title = "Actual and Interpolated Gini Index over Years",
         x = "Year",
         y = "Gini Index") +
    theme_minimal()
  
  # Return the updated gini vector
  
  gini_updated <- setNames(gini_updated, names(gini))
  # print(gini_updated)
  print_gini_for_spreadsheet(gini_updated)
  
  return(myplot)
}




# URL of the CSV file
url <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vTphQAFcdhnlbkMJskCiFihPblG8ko2SrffWci2JeRIhQ7j-cV-RRrb5ibfCiHoW8ZwJ5FxpGfRuv55/pub?gid=1428972764&single=true&output=csv"

# Read the data from URL
data <- read_csv(url)

# Check the structure and column names of the dataframe
print(head(data))
print(colnames(data))

# Assuming 'Country' and 'gini index' are the exact column names
# Filter data to include only rows where the Country is Australia
australia_data <- filter(data, Country == "Australia")


# Check to ensure 'Year' and 'gini index' columns accessibility
if(!"Year" %in% names(australia_data) || !"Gini index" %in% names(australia_data)) {
  stop("Required columns are not present in the dataset.")
}

# Extract 'gini index' values into a vector and name them according to 'Year'
gini <- australia_data$`Gini index`
names(gini) <- australia_data$Year

# Print the results to verify
print(australia_data)
print(gini)


interpolate_and_plot_gini(gini)


