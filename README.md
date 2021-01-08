
<!-- README.md is generated from README.Rmd. Please edit that file -->

# apecsutils

<!-- badges: start -->

<!-- badges: end -->

The goal of `apecsutils` is to make some simple data management tasks
for APECS simpler.

Currently it helps with:

  - checking access permissions on data packages
  - adding access permissions to data packages

## Installation

You can install the development version of `apecsutils` from GitHub
using:

``` r
remotes::install_github("NCEAS/arcticdatautils")
remotes::install_github("mbjones/apecsutils")
```

## Example

This is a basic example which shows you how to solve the common problem
when a member of the APECS lab does not have sufficient permissions to
manage a data package.

Note, for any of these to work, you need to be logged in to the KNB
repository, and set your access token in the R `options` so R can
identify you. You can get this token from your KNB profile settings.
Paste the token for into the console, and not into a script, as you
don’t want to save this, and you should treat it like a secret
password.

``` r
options(dataone_token = "eyJhbGciOiJSUzI1NiJ9.eyJzdW...continuing_as_a_very_long_random_string")
```

Once we are logged in, we can check that both the lab leader and the SME
Group has `changePermission` permission on the package, and then we
update the package to add these permissions.

``` r
library(apecsutils)

# Identify a package by its identifier (pid) from the KNB repository
pid <- "resource_map_urn:uuid:22896aa3-38fd-4baa-888f-cea4b908309c"

# These are the identifiers for the lab leader and the lab group
ginny <- "http://orcid.org/0000-0002-7538-7081"
sme_group <- "CN=Sustainable Marine Ecosystems in Alaska Lab,DC=dataone,DC=org"

# Check if both ginny and sme_group have all permissions
check_package_access(pid, subjects = c(ginny, sme_group), permissions = c("read", "write", "changePermission"))
#> # A tibble: 15 x 3
#>    status    pid                             file                               
#>    <chr>     <chr>                           <chr>                              
#>  1 Good      urn:uuid:38b1033d-b9a1-4e5c-bc… Eelgrass_communities_in_southeast_…
#>  2 Good      resource_map_urn:uuid:22896aa3… resource_map_urn_uuid_22896aa3_38f…
#>  3 Missing … urn:uuid:685e3f18-f175-481a-8c… eelgrass_and_grazer_2018_derived.c…
#>  4 Missing … urn:uuid:a2cf7ce5-ccea-4f65-8d… eelgrass_and_grazer_2019_derived.c…
#>  5 Missing … urn:uuid:efeaa077-4936-4dff-9c… eelgrass_and_grazer_2017_derived.c…
#>  6 Missing … urn:uuid:301e41e7-c662-4496-95… Eelgrass_density_biometrics_2017.R…
#>  7 Missing … urn:uuid:9cfe3cc0-2bc5-4aad-ab… Eelgrass_density_biometrics_2019.R…
#>  8 Missing … urn:uuid:368685ab-9c21-4147-bf… Eelgrass_density_biometrics_2018.R…
#>  9 Missing … urn:uuid:dfa29354-a8b3-4399-97… Eelgrass_biometrics_2018_RAW.csv   
#> 10 Missing … urn:uuid:5e946e41-4f5f-4499-99… seagrass_transect_2017_RAW.csv     
#> 11 Missing … urn:uuid:7d845e07-12ec-4aac-be… Eelgrass_transect_2018_RAW.csv     
#> 12 Missing … urn:uuid:bd608121-ba05-4591-b3… Eelgrass_biometrics_2019_clean.csv 
#> 13 Missing … urn:uuid:2c815154-9efc-44bd-b1… seagrass_site_2017_RAW.csv         
#> 14 Missing … urn:uuid:93f3f8ca-36ad-40cb-9e… Eelgrass_transect_2019_RAW.csv     
#> 15 Missing … urn:uuid:c79aa46e-5e20-4559-86… seagrass_biometrics_CLEAN.csv
```

Finally, you can update the package to allow full access (or whatever
access needed) by Ginny and the Group, and show that the results have
changed by checking the status again.

``` r
# Add permissions for both ginny and sme_group at all levels of access (YMMV)
add_package_access(pid, subjects = c(ginny, sme_group), permissions = c("read", "write", "changePermission"))
#> Warning in if (grepl("^https:\\/\\/orcid\\.org", subjects)) {: the condition has
#> length > 1 and only the first element will be used
#> Updating System Metadata for urn:uuid:685e3f18-f175-481a-8c79-56f0ede1a79e.
#> Updating System Metadata for urn:uuid:a2cf7ce5-ccea-4f65-8d30-e4f128fbd239.
#> Updating System Metadata for urn:uuid:efeaa077-4936-4dff-9c15-6f8d66bf7fe9.
#> Updating System Metadata for urn:uuid:301e41e7-c662-4496-9552-1466755e355f.
#> Updating System Metadata for urn:uuid:9cfe3cc0-2bc5-4aad-ab45-0cc471e3d74f.
#> Updating System Metadata for urn:uuid:368685ab-9c21-4147-bfbf-e79aa012e578.
#> Updating System Metadata for urn:uuid:dfa29354-a8b3-4399-9725-768dedcff5e1.
#> Updating System Metadata for urn:uuid:5e946e41-4f5f-4499-9969-766f01113971.
#> Updating System Metadata for urn:uuid:7d845e07-12ec-4aac-bede-a017e5dbff5b.
#> Updating System Metadata for urn:uuid:bd608121-ba05-4591-b3ff-993fc955a423.
#> Updating System Metadata for urn:uuid:2c815154-9efc-44bd-b14c-be09f47f0ac1.
#> Updating System Metadata for urn:uuid:93f3f8ca-36ad-40cb-9e8d-05f6eacf50db.
#> Updating System Metadata for urn:uuid:c79aa46e-5e20-4559-86e5-64166af2cf94.
#>              urn:uuid:38b1033d-b9a1-4e5c-bc09-9684eb55c53d 
#>                                                      FALSE 
#> resource_map_urn:uuid:22896aa3-38fd-4baa-888f-cea4b908309c 
#>                                                      FALSE 
#>              urn:uuid:685e3f18-f175-481a-8c79-56f0ede1a79e 
#>                                                       TRUE 
#>              urn:uuid:a2cf7ce5-ccea-4f65-8d30-e4f128fbd239 
#>                                                       TRUE 
#>              urn:uuid:efeaa077-4936-4dff-9c15-6f8d66bf7fe9 
#>                                                       TRUE 
#>              urn:uuid:301e41e7-c662-4496-9552-1466755e355f 
#>                                                       TRUE 
#>              urn:uuid:9cfe3cc0-2bc5-4aad-ab45-0cc471e3d74f 
#>                                                       TRUE 
#>              urn:uuid:368685ab-9c21-4147-bfbf-e79aa012e578 
#>                                                       TRUE 
#>              urn:uuid:dfa29354-a8b3-4399-9725-768dedcff5e1 
#>                                                       TRUE 
#>              urn:uuid:5e946e41-4f5f-4499-9969-766f01113971 
#>                                                       TRUE 
#>              urn:uuid:7d845e07-12ec-4aac-bede-a017e5dbff5b 
#>                                                       TRUE 
#>              urn:uuid:bd608121-ba05-4591-b3ff-993fc955a423 
#>                                                       TRUE 
#>              urn:uuid:2c815154-9efc-44bd-b14c-be09f47f0ac1 
#>                                                       TRUE 
#>              urn:uuid:93f3f8ca-36ad-40cb-9e8d-05f6eacf50db 
#>                                                       TRUE 
#>              urn:uuid:c79aa46e-5e20-4559-86e5-64166af2cf94 
#>                                                       TRUE

# Check if both ginny and sme_group have all permissions now
check_package_access(pid, subjects = c(ginny, sme_group), permissions = c("read", "write", "changePermission"))
#> # A tibble: 15 x 3
#>    status pid                               file                                
#>    <chr>  <chr>                             <chr>                               
#>  1 Good   urn:uuid:38b1033d-b9a1-4e5c-bc09… Eelgrass_communities_in_southeast_A…
#>  2 Good   resource_map_urn:uuid:22896aa3-3… resource_map_urn_uuid_22896aa3_38fd…
#>  3 Good   urn:uuid:685e3f18-f175-481a-8c79… eelgrass_and_grazer_2018_derived.csv
#>  4 Good   urn:uuid:301e41e7-c662-4496-9552… Eelgrass_density_biometrics_2017.Rmd
#>  5 Good   urn:uuid:9cfe3cc0-2bc5-4aad-ab45… Eelgrass_density_biometrics_2019.Rmd
#>  6 Good   urn:uuid:368685ab-9c21-4147-bfbf… Eelgrass_density_biometrics_2018.Rmd
#>  7 Good   urn:uuid:a2cf7ce5-ccea-4f65-8d30… eelgrass_and_grazer_2019_derived.csv
#>  8 Good   urn:uuid:efeaa077-4936-4dff-9c15… eelgrass_and_grazer_2017_derived.csv
#>  9 Good   urn:uuid:dfa29354-a8b3-4399-9725… Eelgrass_biometrics_2018_RAW.csv    
#> 10 Good   urn:uuid:5e946e41-4f5f-4499-9969… seagrass_transect_2017_RAW.csv      
#> 11 Good   urn:uuid:7d845e07-12ec-4aac-bede… Eelgrass_transect_2018_RAW.csv      
#> 12 Good   urn:uuid:bd608121-ba05-4591-b3ff… Eelgrass_biometrics_2019_clean.csv  
#> 13 Good   urn:uuid:2c815154-9efc-44bd-b14c… seagrass_site_2017_RAW.csv          
#> 14 Good   urn:uuid:93f3f8ca-36ad-40cb-9e8d… Eelgrass_transect_2019_RAW.csv      
#> 15 Good   urn:uuid:c79aa46e-5e20-4559-86e5… seagrass_biometrics_CLEAN.csv
```
