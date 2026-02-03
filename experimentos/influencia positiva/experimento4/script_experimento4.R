#### Lectura de los datos y limpieza ####

# Se establece el espacio de trabajo y las librerías a utilizar
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia positiva/experimento4")
library(tidyverse)

# Se lee la tabla obtenida del experimento y se cambian los nombres de las variables
experimento4_table <- read.csv('experimento-4-positiva-table.csv', skip = 6)
experimento4_table <- experimento4_table %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick,
    learning_rate = learning.rate
  )

# Se eligen unicamente las variables necesarias para el analisis
experimento4_table <- experimento4_table[c('run_number', 'tick', 'agents_per_tick', 'learning_rate' ,'pref_A', 'pref_B')]

# Se obtiene el promedio de todas las repeticiones realizadas por cada combinacion de valores de los parametros
experimento4_avg <- experimento4_table %>%
  group_by(learning_rate, tick) %>%
  summarise(
    mean_pref_A = mean(pref_A),
    mean_pref_B = mean(pref_B),
    .groups = 'drop'
  ) %>%
  
  # Se agregan dos columnas par indicar el porcentaje de preferencia
  mutate(
    pct_A = (mean_pref_A / 1070) * 100,
    pct_B = (mean_pref_B / 1070) * 100
  )

#### Calculo del error de las simulaciones ####

# Se crea un dataframe con base en los datos de las encuestas reales para calcular el error
encuestas_reales <- data.frame(
  tick = c(69, 166, 259),
  pct_A_real = c(64, 61, 68),
  pct_B_real = c(36, 39, 32)
)

# Se calcula el error en base a las encuestas y el resultado final de la eleccion
error_experimento4 <- experimento4_avg %>%
  # Se unen los valores de las encuestas reales a los experimentales
  inner_join(encuestas_reales, by = 'tick') %>%
  # Se calcula el error en cada una de las filas
  mutate(
    err_sq_A = (pct_A - pct_A_real)^2,
    err_sq_B = (pct_B - pct_B_real)^2,
    err_total_punto = (err_sq_A + err_sq_B) / 2
  ) %>%
  # Se agrupa el error en base a los parametros learning_rate y agents_per_tick
  group_by(learning_rate) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  # Se ordena de menor a mayor error
  arrange(MSE)

# Se muestran los mejores resultados
head(error_experimento4)

ggplot(error_experimento4, aes(x=learning_rate, y = RMSE)) +
  geom_point(color = "#2C3E50", size = 1) +
  labs(
    title = "Error de acuerdo al valor del parámetro
    learning rate",
    x = "Agentes interactuando por tick",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  theme_minimal(base_size = 12) 

#### Mejor modelo ####
# Se realizan 100 simulaciones del mejor modelo para graficar su evolución además de su variabilidad
# Este modelo se obtiene con 5 agentes, learning rate de 0,58
experimento4_mejor <- read.csv("experimento4-positiva-mejor-table.csv", skip=6)
experimento4_mejor <- experimento4_mejor %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick,
    learning_rate = learning.rate
  )
experimento4_mejor <- experimento4_mejor[c('run_number', 'tick', 'learning_rate', 'pref_A', 'pref_B')]
experimento4_mejor_avg <- experimento4_mejor %>%
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



ggplot(experimento4_mejor_avg, aes(x = tick)) +
  geom_ribbon(aes(ymin = pct_min_A, ymax = pct_max_A), 
              fill = "brown", alpha = 0.2) +
  
  geom_line(aes(y = pct_A), color = "brown4", size = 1) +
  
  geom_point(data = encuestas_reales, 
             aes(x = tick, y = pct_A_real, shape = "Datos reales"), 
             color = "red", size = 3, shape = 18) +
  
  theme_minimal() +
  labs(
    title = "Evolución de preferencia por A con learning rate = 0.58,
    5 interacciones por dia",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por A (%)"
  )
