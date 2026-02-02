setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia negativa")
library(tidyverse)
experimento3_table <- read.csv('experimento-3-negativa-table.csv', skip = 6)
experimento3_table <- experimento3_table %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    confidence = confidence.threshold
  )

experimento3_table <- experimento3_table[c('run_number', 'tick', 'confidence', 'pref_A', 'pref_B')]

experimento3_avg <- experimento3_table %>%
  group_by(confidence, tick) %>%
  summarise(
    mean_pref_A = mean(pref_A),
    mean_pref_B = mean(pref_B),
    .groups = 'drop'
  ) %>%
  
  mutate(
    pct_A = (mean_pref_A / 1070) * 100,
    pct_B = (mean_pref_B / 1070) * 100
  )

experimento3_avg <- filter(experimento3_avg, confidence<=1)

encuestas_reales <- data.frame(
  tick = c(69, 166, 259),
  pct_A_real = c(64, 61, 68),
  pct_B_real = c(36, 39, 32)
)


error_confidence <- experimento3_avg %>%
  inner_join(encuestas_reales, by = 'tick') %>%
  
  mutate(
    err_sq_A = (pct_A - pct_A_real)^2,
    err_sq_B = (pct_B - pct_B_real)^2,
    err_total_punto = (err_sq_A + err_sq_B) / 2
  ) %>%
  
  group_by(confidence) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  
  arrange(MSE)

head(error_confidence)

ggplot(error_confidence, aes(x=confidence, y = RMSE)) +
  geom_point(color = "#2C3E50", size = 1) +
  labs(
    title = "Error de acuerdo al valor de confidence threshold",
    x = "Confidence threshold",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  geom_point(data = filter(error_confidence, RMSE == min(RMSE)), 
             aes(x = confidence, y = RMSE), 
             color = "#E74C3C", size = 2) +
  theme_minimal(base_size = 12) 

experimento3_99_confidence <- read.csv(file = 'experimento-3-confidence-99-table.csv', skip = 6)
experimento3_99_confidence <- experimento3_99_confidence %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    confidence = confidence.threshold
  )

experimento3_99_confidence <-experimento3_99_confidence[c('run_number', 'tick', 'confidence', 'pref_A', 'pref_B')]

experimento3_99_confidence_avg <- experimento3_99_confidence %>%
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

ggplot(experimento3_99_confidence_avg, aes(x = tick)) +
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
    title = "Evolución de preferencia por A con 
    confidence threshold = 0.99",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por A (%)"
  )

ggplot(experimento3_99_confidence_avg, aes(x = tick)) +
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
    title = "Evolución de preferencia por B con 
    confidence threshold = 0.99",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por B (%)"
  )
  