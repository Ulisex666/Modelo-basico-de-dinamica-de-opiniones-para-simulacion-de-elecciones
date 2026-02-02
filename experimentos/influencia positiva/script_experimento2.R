setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia positiva")
library(tidyverse)

experimento2_table <- read.csv('experimento-2-table.csv', skip = 6)
experimento2_table <- experimento2_table %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick
  )

experimento2_table <- experimento2_table[c('run_number', 'tick', 'agents_per_tick', 'pref_A', 'pref_B')]

experimento2_avg <- experimento2_table %>%
  group_by(agents_per_tick, tick) %>%
  summarise(
    mean_pref_A = mean(pref_A),
    mean_pref_B = mean(pref_B),
    .groups = 'drop'
  ) %>%
  
  mutate(
    pct_A = (mean_pref_A / 1070) * 100,
    pct_B = (mean_pref_B / 1070) * 100
  )

encuestas_reales <- data.frame(
  tick = c(69, 166, 259),
  pct_A_real = c(64, 61, 68),
  pct_B_real = c(36, 39, 32)
)

error_agents_per_tick <- experimento2_avg %>%
  inner_join(encuestas_reales, by = 'tick') %>%

mutate(
  err_sq_A = (pct_A - pct_A_real)^2,
  err_sq_B = (pct_B - pct_B_real)^2,
  err_total_punto = (err_sq_A + err_sq_B) / 2
) %>%

group_by(agents_per_tick) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  
  arrange(MSE)

head(error_agents_per_tick)




ggplot(error_agents_per_tick, aes(x=agents_per_tick, y = RMSE)) +
  geom_point(color = "#2C3E50", size = 1) +
  labs(
    title = "Error de acuerdo al número de agentes interactuando 
    por tick",
    x = "Agentes interactuando por tick",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  theme_minimal(base_size = 12) 


ggplot(slice(error_agents_per_tick, 1:10), aes(x=agents_per_tick, y = RMSE)) +
  geom_point(color = "#2C3E50") +
  geom_point(data = filter(error_agents_per_tick, RMSE == min(RMSE)), 
             aes(x = agents_per_tick, y = RMSE), 
             color = "#E74C3C", size = 2) +
  labs(
    title = "Error de acuerdo al número de agentes interactuando 
    por tick",
    x = "Agentes interactuando por tick",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  annotate("text", x = 5, y = 3, 
           label = "5 agentes por tick", 
           color = "red", fontface = "italic") +
  theme_minimal(base_size = 12) 
  
experimento2_5_agents <- read.csv(file = 'experimento-2-5-agents-table.csv', skip = 6)
experimento2_5_agents <- experimento2_5_agents %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick
  )

experimento2_5_agents <- experimento2_5_agents[c('run_number', 'tick', 'agents_per_tick', 'pref_A', 'pref_B')]
experimento2_5_agents_avg <- experimento2_5_agents %>%
  group_by(tick) %>%
  
  summarise(
    mean_pref_A = mean(pref_A),
    mean_pref_B = mean(pref_B),
    min_pref_A = min(pref_A),
    max_pref_A = max(pref_A),
    min_pref_B = min(pref_B),
    max_pref_B = max(pref_B),
    .groups = 'drop' 
  ) %>%
  
  mutate(
    pct_A = (mean_pref_A / 1070) * 100,
    pct_B = (mean_pref_B / 1070) * 100, 
    pct_min_A = (min_pref_A / 1070) * 100,
    pct_max_A = (max_pref_A / 1070) * 100,
    
    pct_B = (mean_pref_B / 1070) * 100,
    pct_min_B = (min_pref_B / 1070) * 100,
    pct_max_B = (max_pref_B / 1070) * 100
  )


# Usando tu dataframe filtrado con LR = 0.53
ggplot(experimento2_5_agents_avg, aes(x = tick)) +
  # 1. Creamos el sombreado (Capa de abajo)
  geom_ribbon(aes(ymin = pct_min_A, ymax = pct_max_A), 
              fill = "brown", alpha = 0.2) +
  
  # 2. Creamos la línea del promedio (Capa de arriba)
  geom_line(aes(y = pct_A), color = "brown4", size = 1) +
  
  geom_point(data = encuestas_reales, 
             aes(x = tick, y = pct_A_real, shape = "Datos reales"), 
             color = "red", size = 3, shape = 18) +
  
  # Estética
  theme_minimal() +
  labs(
    title = "Evolución de preferencia por A con learning rate = 0.53,
    5 interacciones por dia",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por A (%)"
  )

ggplot(experimento2_5_agents_avg, aes(x = tick)) +
  # 1. Creamos el sombreado (Capa de abajo)
  geom_ribbon(aes(ymin = pct_min_B, ymax = pct_max_B), 
              fill = "deepskyblue", alpha = 0.2) +
  
  # 2. Creamos la línea del promedio (Capa de arriba)
  geom_line(aes(y = pct_B), color = "deepskyblue4", size = 1) +
  
  geom_point(data = encuestas_reales, 
             aes(x = tick, y = pct_B_real), 
             color = "blue", size = 3, shape = 18) +  
  # Estética
  theme_minimal() +
  labs(
    title = "Evolución de preferencia por B con learning rate = 0.53,
    5 interacciones por día",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por B (%)"
  )
