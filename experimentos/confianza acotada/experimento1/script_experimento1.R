#### Lectura de los datos y limpieza ####

# Se establece el espacio de trabajo y las librerías a utilizar
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/confianza acotada/experimento1")
library(tidyverse)

experimento1_table <- read.csv('experimento-1-BC-table.csv', skip = 6)
experimento1_table <- experimento1_table %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick,
    learning_rate = learning.rate,
    spatial_interactions = spatial.interactions.,
    confidence_threshold = confidence.threshold
  )

# Para este experimento se evalúa el efecto de learning rate en el modelo de
# BC. Seleccionamos las variables adecuadas para este análisis
experimento1_table <- experimento1_table[c('run_number', 'tick', 'learning_rate' ,'pref_A', 'pref_B')]

# Se obtiene el promedio de todas las repeticiones realizadas por cada combinacion de valores de los parametros
experimento1_avg <- experimento1_table %>%
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

#### Cálculo del error del modelo ####

# Se crea un dataframe con base en los datos de las encuestas reales para calcular el error
encuestas_reales <- data.frame(
  tick = c(69, 166, 259),
  pct_A_real = c(64, 61, 68),
  pct_B_real = c(36, 39, 32)
)

# Se calcula el error en base a las encuestas y el resultado final de la eleccion
error_experimento1 <- experimento1_avg %>%
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
head(error_experimento1)

##### Visualización de los resultados ####

ggplot(error_experimento1, aes(x=learning_rate, y = RMSE)) +
  geom_point(color = "#2C3E50", size = 1) +
  labs(
    title = "Error de acuerdo al valor del parámetro
    learning rate",
    x = "Learning rate",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  theme_minimal(base_size = 12) 

#### Mejor modelo ####

# Se seleccionan las simulacioens correspondientes al mejor valor de learning rate
experimento1_mejor <- experimento1_table %>%
  filter(learning_rate == 0.58)

experimento1_mejor_avg <- experimento1_mejor %>%
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

ggplot(experimento1_mejor_avg, aes(x = tick)) +
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

