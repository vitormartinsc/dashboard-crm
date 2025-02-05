setwd('C:/Users/servi/dashboard-crm/')
library(dplyr)
library(ggplot2)
library(tidyverse)
df = read_csv('deal_by_stage.csv')
df %>% 
  mutate(
    stage_detail_number = ifelse(
      !grepl('AMBULANTE ESSENCIAL', stage_name),
             substr(stage_detail, 1, 3) %>% as.numeric, 2)) %>% 
  arrange(stage_detail_number) %>% 
  filter(!grepl('CONTRATO|CONTATO|TYPEFORM', stage_detail))-> new_df




new_df %>% 
  group_by(stage_status, stage_detail) %>% 
  summarise(total_by_stage = n(), .groups = "drop") %>% 
  rename(
    `Nome do Estágio` = stage_detail,
    `Quantidade Total` = total_by_stage,
    `Status do Estágio` = stage_status
  ) %>%
  ggplot(aes(x = `Nome do Estágio`, y = `Quantidade Total`, group = `Status do Estágio`, color = `Status do Estágio`)) + 
  geom_line(size = 1.2) + 
  geom_point(size = 2, show.legend = F) +
  
  # Adiciona os labels acima dos pontos
  geom_text(aes(label = `Quantidade Total`, y = `Quantidade Total` + 40), vjust = 100,size = 4) +
  
  labs(title = "Total de Negócios por Status de Estágio",
       x = "Número do Estágio",
       y = "Total por Estágio",
       color = "Status") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    axis.title = element_text(size = 14),
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  coord_cartesian(ylim = c(0, 1000)) -> p

ggplotly(p)   # Ajusta o eixo Y sem cortar dados



new_df %>% 
  group_by(stage_status, stage_detail) %>% 
  summarise(total_by_stage = n()) %>% 
  ungroup() %>% 
  rename(
    `Nome do Estágio` = stage_detail,
    `Quantidade Total` = total_by_stage,
    `Status do Estágio` = stage_status
  ) %>%
  ggplot(aes(x = `Nome do Estágio`, y = `Quantidade Total`, fill = `Status do Estágio`)) + 
  geom_col(position = "dodge", width = 0.7) +
  labs(
    title = "Total por Status de Estágio",
    x = "Nome do Estágio",
    y = "Quantidade Total",
    fill = "Status do Estágio"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  coord_cartesian(ylim = c(0, 1000))  -> p




ggplotly(p)


new_df %>% 
  group_by(stage_status, stage_detail) %>% 
  summarise(total_by_stage = n()) %>% 
  ungroup %>% 
  group_by(stage_status) %>% 
  mutate(percent_by_stage = total_by_stage / sum(total_by_stage))


new_df %>% 
  group_by(stage_status, stage_detail) %>% 
  summarise(total_by_stage = n(), .groups = "drop") %>% 
  rename(
    `Nome do Estágio` = stage_detail,
    `Quantidade Total` = total_by_stage,
    `Status do Estágio` = stage_status
  ) %>% 
  write_csv('teste.csv')



