library(tidyverse)
library(sf)
library(NPSpecies)
library(tigris)

# load nps species data
nps_species_data <- NPSpecies::species %>%
  rename(unit_code = ParkCode) %>% 
  rename_with(str_to_lower)

# park boundary data
park_bounds <- st_read("data/admin_bounds.gdb/") %>% 
  st_transform("+proj=longlat +ellps=WGS84 +datum=WGS84") %>%
  # cast to multipolygon so st_make_valid will work
  mutate(shape = st_cast(shape, to = "MULTIPOLYGON")) %>%
  # make valid to fix overlapping edges
  mutate(shape = st_make_valid(shape)) %>% 
  mutate(centroid = st_centroid(shape, of_largest_polygon = T),
         lon = st_coordinates(centroid)[, 1],
         lat = st_coordinates(centroid)[, 2])
# subset to geo data without sf geometries
geo_small <- park_bounds %>%
  st_drop_geometry() %>%
  select(unit_code, unit_name, unit_type, state, region, shape_Area, lat, lon)
write_tsv(geo_small, file = "data/nps_unit_metadata.tsv")
