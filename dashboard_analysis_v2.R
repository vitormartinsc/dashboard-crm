df %>% 
  filter(!(is.na(organization) & is.na(person))) %>% 
  mutate(id = ifelse(is.na(person), organization, person),
         type = ifelse(is.na(person), 'organization', 'person')) %>% 
  select(-person, -organization) %>% 
  mutate(stage_name = gsub("^\\d+\\s*", "", stage_name)) -> new_df

filter_date = today() - months(1)

new_df %>% 
  mutate_if(is.POSIXct, ~ as_date(.)) %>% 
  filter(date_created >= filter_date) %>% 
  group_by(id) %>% 
  filter(date_created == max(date_created)) %>% 
  group_by(stage_detail) %>% 
  summarise(total_members = n())
