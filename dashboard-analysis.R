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

df %>% 
  filter(stage_status == 'Ganho') %>% 
  group_by(stage_name) %>% 
  mutate(
    stage_name = case_when(
      grepl('SERVICE', stage_name) ~ 'Service',
      grepl('POS', stage_name) ~ 'POS',
      T ~ 'Ambulante Essencial'
    )
  ) %>% 
  mutate(
    won_dates = date_won - date_created
  ) %>% 
  mutate(won_dates =( as.numeric(won_dates) / 3600) %>% round) %>% 
  group_by(stage_name) %>% 
  summarise(mean(won_dates)) %>% 
  rename('Estágio' = 1,
         'Média de Horas Gastas' = 2) -> plot_df

cor_primaria <- "#002F6C"  # Azul escuro
cor_texto <- "white"

plot_df %>%
  ggplot(aes(x = Estágio, y = `Média de Horas Gastas`, fill = Estágio)) +
  geom_col(show.legend = FALSE) +  # Remove legenda desnecessária
  scale_fill_manual(values = rep(cor_primaria, length(unique(plot_df$Estágio)))) +
  theme_minimal(base_size = 14) +  # Tema limpo e moderno
  labs(title = "Tempo Médio Gasto por Estágio",
       x = "Estágio",
       y = "Média de Horas Gastas para Ganho") +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major.y = element_line(color = "gray80", linetype = "dashed"),
    axis.text = element_text(color = cor_primaria),
    axis.title = element_text(color = cor_primaria, face = "bold"),
    plot.title = element_text(color = cor_primaria, face = "bold", hjust = 0.5, size = 16)
  )

df %>% 
  group_by(stage_status, stage_name) %>% 
  summarise(stage_count = n()) %>% 
  ungroup %>% 
  group_by(stage_name) %>% 
  mutate(stage_count_sum = sum(stage_count)) %>% 
  group_by(stage_status) %>% 
  mutate(stage_count_percent = stage_count / stage_count_sum) %>% 
  filter(stage_status == 'Perdido') %>% 
  ungroup %>% 
  select(2, ncol(.)) -> plot_df

plot_df %>%
  ggplot(aes(x = stage_name, y = stage_count_percent, fill = stage_name)) +
  geom_col(show.legend = FALSE) +  # Remove legenda desnecessária
  scale_fill_manual(values = rep(cor_primaria, length(unique(plot_df$stage_name)))) +
  
  # Adiciona rótulos com fundo branco e texto azul, formatado como porcentagem
  geom_label(aes(label = scales::percent(stage_count_percent, accuracy = 0.1)),
             fill = "white", color = cor_primaria, fontface = "bold", size = 5) +
  
  theme_minimal(base_size = 14) +  # Tema limpo e moderno
  labs(title = "Percentual de Perdidos por Estágio",
       x = '', y = '') +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major.y = element_line(color = "gray80", linetype = "dashed"),
    axis.text = element_text(color = cor_primaria),
    axis.title = element_text(color = cor_primaria, face = "bold"),
    plot.title = element_text(color = cor_primaria, face = "bold", hjust = 0.5, size = 16)
  )


df %>% 
  filter(!(is.na(organization) & is.na(person))) %>% 
  mutate(id = ifelse(is.na(person), organization, person),
         type = ifelse(is.na(person), 'organization', 'person')) %>% 
  select(-person, -organization) %>% 
  mutate(stage_name = gsub("^\\d+\\s*", "", stage_name)) -> new_df

new_df %>% 
  group_by(id) %>% 
  filter(date_created == max(date_created)) %>% 
  group_by(stage_name) %>% 
  mutate(stage_count = n()) %>% 
  ungroup %>% 
  select(stage_name, date_created, stage_count, stage_number) -> df_by_stage_name

new_df %>% 
  group_by(id) %>% 
  filter(date_created == max(date_created)) %>% 
  group_by(stage_detail) %>% 
  mutate(stage_count = n()) %>% 
  ungroup %>% 
  select(stage_name, stage_detail, date_created, stage_count) -> df_by_stage_detail

library(shiny)
library(tidyverse)
library(lubridate)
library(plotly)

# UI - Interface
ui <- fluidPage(
  titlePanel("Dashboard de Stage Count"),
  
  sidebarLayout(
    sidebarPanel(
      dateInput("date_filter", "Selecione a Data:", 
                value = max(df$date_created), 
                format = "dd/mm/yyyy", 
                language = "pt-BR"),
      
      selectInput("stage_filter", "Selecione o Tipo de Detalhamento:",
                  choices = c("Geral", unique(new_df$stage_name)),  # Adiciona "Geral" + detalhes disponíveis
                  selected = "Geral"),
      checkboxInput("compare", "Comparar as Datas", value = FALSE) 
    ),
    
    mainPanel(
      plotlyOutput("stage_plot", height = '700px'), width = 10
    )
  )
  
)



# Server - Processamento
server <- function(input, output) {
  
  filtered_data <- reactive({
    
    if (input$stage_filter == "Geral") {
      data <- new_df %>% 
        group_by(stage_name) %>%  # Agrupar por stage_name
        filter(date_created <= input$date_filter) %>% 
        mutate(stage_count = n()) %>%  # Contagem de cada stage
        ungroup() %>% 
        select(stage_name, date_created, stage_count, stage_number) %>% 
        rename(id = stage_name) %>% 
        group_by(id) %>% 
        filter(date_created == max(date_created))  # Pega a data mais recente
      
      print(data)
      
      # Dados para comparação
      data_to_compare <- new_df %>% 
        group_by(stage_name) %>%  # Agrupar por stage_name
        filter(date_created == max(date_created)) %>% 
        mutate(today_count = n()) %>%  # Contagem de hoje
        ungroup() %>% 
        select(stage_name, date_created, today_count, stage_number) %>% 
        rename(id = stage_name) %>% 
        group_by(id) %>% 
        filter(date_created == max(date_created))  # Pega a data mais recente
      print(data_to_compare)
      
    } else {
      data <- new_df %>% 
        filter(date_created <= input$date_filter, stage_name == input$stage_filter) %>% 
        group_by(stage_detail) %>% 
        mutate(stage_count = n()) %>%  # Contagem de cada stage
        ungroup() %>% 
        select(stage_name, stage_detail, date_created, stage_count, stage_number) %>% 
        rename(id = stage_detail) %>% 
        group_by(id) %>% 
        filter(date_created == max(date_created)) %>% 
        ungroup() %>% 
        select(-stage_name)
      
      print(data)
      
      # Dados para comparação
      data_to_compare <- new_df %>% 
        filter(stage_name == input$stage_filter) %>% 
        group_by(stage_detail) %>% 
        mutate(today_count = n()) %>%
        filter(date_created == max(date_created)) %>% # Contagem de hoje
        ungroup() %>% 
        select(stage_detail, stage_name, date_created, today_count, stage_number) %>% 
        rename(id = stage_detail) %>% 
        group_by(id) %>% 
        filter(date_created == max(date_created)) %>% 
        ungroup() %>% 
        select(-stage_name)
      
      print(data_to_compare)
    }
    
    # Se for para comparar com a data mais recente
    if (input$compare) {
      final_data <- data %>% 
        left_join(data_to_compare, by = 'id')  # Junção entre os dados
    } else {
      final_data <- data %>% mutate(count_value = stage_count)
        
    }
    
    print(final_data)
    
    return(final_data)
  })
  

  
  output$stage_plot <- renderPlotly({
    
    # Verifica se a comparação está ativada
    data_for_plot <- filtered_data()
    
    if (input$compare) {
      data_for_plot <- data_for_plot %>%
        pivot_longer(cols = c(stage_count, today_count), names_to = "count_type", values_to = "count_value")
      
    }
    
    adjusted_size = data_for_plot$count_value %>% max
    
    print('plot::::')
    print(data_for_plot)
    
    if (input$compare && "count_type" %in% colnames(data_for_plot)) {
      p <- ggplot(data_for_plot, aes(x = id, y = count_value, fill = count_type))
    } else {
      p <- ggplot(data_for_plot, aes(x = id, y = stage_count))
    }
    
    p <- p +
      geom_col(position = "dodge", width = 0.6) +  # Barras lado a lado
      geom_text(aes(label = count_value, y = count_value + adjusted_size * 0.01), color = "#003366", fontface = "bold") +  
      theme_minimal(base_size = 14) +
      labs(title = "Stage Count por Stage Name", x = "Stage Name", y = "Stage Count") +
      theme(
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),
        axis.text.x = element_text(color = "#003366", size = 12, face = "bold", angle = 45),
        axis.text.y = element_text(color = "#003366", size = 12, face = "bold"),
        plot.title = element_text(color = "#003366", face = "bold", size = 16, hjust = 0.5)
      ) #+ 
      #scale_fill_manual(values = c("#003366"))
    
    ggplotly(p)
  })
}

# Rodar o App
shinyApp(ui, server)



  