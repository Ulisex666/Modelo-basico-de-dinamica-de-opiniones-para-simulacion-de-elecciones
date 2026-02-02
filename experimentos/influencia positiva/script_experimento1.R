setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia positiva")
library(tidyverse)
experiment_table <- read.csv('experimento-1-table.csv', skip = 6)

table_clean <- experiment_table %>%
  rename(
    tick = X.step.,
    learning_rate = learning.rate, 
    pref_A = pref.A,
    pref_B = pref.B,
    run_number = X.run.number.
  )

table_clean <- table_clean[c('tick', 'learning_rate', 'pref_A', 'pref_B', 'run_number')]

table_avg <- table_clean %>%
  group_by(learning_rate, tick) %>%
  
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


encuestas_reales <- data.frame(
  tick = c(69, 166, 259),
  pct_A_real = c(64, 61, 68),
  pct_B_real = c(36, 39, 32)
)

# 1. Unir simulaciones con datos reales solo en los ticks donde hay encuesta
analisis_error <- table_avg %>%
  inner_join(encuestas_reales, by = "tick") %>%
  
  # 2. Calcular el error cuadrático para cada punto y variable
  mutate(
    err_sq_A = (pct_A - pct_A_real)^2,
    err_sq_B = (pct_B - pct_B_real)^2,
    err_total_punto = (err_sq_A + err_sq_B) / 2
  ) %>%
  
  # 3. Agrupar por learning_rate para sacar el promedio de los 3 días
  group_by(learning_rate) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  
  # 4. Ordenar de menor a mayor error
  arrange(MSE)

# Ver los 5 mejores "learning rates" (los que mejor ajustan a la realidad)
head(analisis_error, 10)

# Suponiendo que ya tienes el dataframe 'analisis_error' calculado
ggplot(analisis_error, aes(x = learning_rate, y = RMSE)) +
  # Línea suavizada para ver la tendencia
  geom_point(color = "#2C3E50", size = 1) +
  # Resaltar el punto mínimo
  geom_point(data = filter(analisis_error, RMSE == min(RMSE)), 
             aes(x = learning_rate, y = RMSE), 
             color = "#E74C3C", size = 2) +
  # Etiquetas y estilo
  labs(
    title = "Error de acuerdo al valor del learning rate",
    x = "Learning Rate",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  theme_minimal(base_size = 14) 

df_best_fit <- filter(table_avg, learning_rate == 0.53)


# Usando tu dataframe filtrado con LR = 0.53
ggplot(df_best_fit, aes(x = tick)) +
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
    title = "Evolución de preferencia por A con learning rate = 0.53",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por A (%)"
  )

ggplot(df_best_fit, aes(x = tick)) +
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
    title = "Evolución de preferencia por B con learning rate = 0.53",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por B (%)"
  )



