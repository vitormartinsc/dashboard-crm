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
  summarise(total_by_stage = n()) %>% 
  ungroup() %>% 
  ggplot(aes(stage_detail, total_by_stage, color=stage_status)) + 
  geom_line(size = 1.2, aes(color = stage_status, group=stage_status)) + 
  geom_point(size=2)+
  #geom_point(size = 3) + 
  labs(title = "Total por Status de Estágio",
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
  )  +
  
  coord_cartesian(ylim = c(0, 1000))  #



plotly_chart <- ggplotly(p)

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)

# UI - Interface do Usuário
ui <- dashboardPage(
  dashboardHeader(title = "Dashboard de Estágios"),
  dashboardSidebar(
    # Filtro para o Gráfico 1 (Filtrar por Status)
    selectInput("status", "Selecione o Status para o Gráfico 1:", 
                choices = unique(new_df$stage_status), selected = "A")
  ),
  dashboardBody(
    fluidRow(
      # Gráfico 1: Com filtro por status
      box(title = "Gráfico 1: Por Status", plotlyOutput("grafico1"), width = 12),
    ),
    fluidRow(
      # Gráfico 2: Sem filtro (todos os dados)
      box(title = "Gráfico 2: Todos os Dados", plotlyOutput("grafico2"), width = 12)
    )
  )
)

# Server - Lógica do Dashboard
server <- function(input, output) {
  
  # Gráfico 1 - Com filtro por status
  output$grafico1 <- renderPlotly({
    # Criando o gráfico com ggplot
    p1 <- new_df %>%
      filter(stage_status == input$status) %>%
      group_by(stage_status, stage_name) %>%
      summarise(total_by_stage = n(), .groups = "drop") %>%
      ggplot(aes(x = stage_name, y = total_by_stage, color = stage_status)) +
      geom_line(size = 1.2) +  # Linha para cada grupo
      geom_point(size = 3) +   # Pontos para cada grupo
      labs(title = "Total por Status de Estágio (Filtrado)",
           x = "Nome do Estágio",
           y = "Total por Estágio",
           color = "Status") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotacionar os nomes do eixo X
    
    # Transformar o gráfico ggplot em interativo com ggplotly
    ggplotly(p1)
  })
  
  # Gráfico 2 - Sem filtro (todos os dados)
  output$grafico2 <- renderPlotly({
    # Criando o gráfico com ggplot para todos os dados
    p2 <- new_df %>%
      group_by(stage_status, stage_name) %>%
      summarise(total_by_stage = n(), .groups = "drop") %>%
      ggplot(aes(x = stage_name, y = total_by_stage, color = stage_status)) +
      geom_line(size = 1.2) +  # Linha para cada grupo
      geom_point(size = 3) +   # Pontos para cada grupo
      labs(title = "Total por Status de Estágio (Todos)",
           x = "Nome do Estágio",
           y = "Total por Estágio",
           color = "Status") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotacionar os nomes do eixo X
    
    # Transformar o gráfico ggplot em interativo com ggplotly
    ggplotly(p2)
  })
}
# Rodar o app
shinyApp(ui = ui, server = server)
