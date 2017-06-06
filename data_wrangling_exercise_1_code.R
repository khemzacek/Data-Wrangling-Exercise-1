# Load packages to workspace
library(tidyr)
library(dplyr)

# 0: Load the data
refine <- read.csv("refine_original.csv") # %>% tbl_df()

# 1: Clean up brand names
##  standardize names to all lowercase
refine$company <- tolower(refine$company)

##  find misspellings & index locations
company <- c("philips", "akzo", "van houten", "unilever")
i <- !(refine$company %in% company)
data_frame(mispelling = refine$company[i], 
           index = (1:length(refine$company))[i])

##  fix misspellings
refine$company[c(1, 2, 4, 5, 6, 14, 15, 16)] <- company[1]
refine$company[c(10, 11)] <- company[2]
refine$company[c(22)] <- company[4]

# 2: Separate product code and number
refine <- separate(refine, Product.code...number, 
                   c("product_code", "product_number"), sep = "-")

# 3: Add product categories
##  define of product codes in data frame
prod_code_defs <- data_frame(product_code = c("p", "v", "x", "q"),
                             product_category = c("Smartphone", "TV", "Laptop", "Tablet"))

##  add product_categories column
refine <- left_join(refine, prod_code_defs, by = "product_code")

# 4: Add full address for geocoding
refine <- unite(refine, "full_address", address, city, country,
                sep = ", ", remove = FALSE)

# 5: Create dummy variables for company and product category
##  company columns
refine <- mutate(refine, company_philips = company == "philips",
                 company_akzo = company == "akzo",
                 company_van_houten = company == "van houten",
                 company_unilever = company == "unilever")

## product columns
refine <- mutate(refine, product_smartphone = product_category == "Smartphone",
                 product_tv = product_category == "TV",
                 product_laptop = product_category == "Laptop",
                 product_tablet = product_category == "Tablet")

# reorder columns
refine <- refine[c(1, 10, 11, 12, 13, 2, 3, 9, 14, 15, 16, 17, 4, 5, 6, 7, 8)]

# write cleaned data to .csv file
write.csv(refine, "refine_clean.csv")