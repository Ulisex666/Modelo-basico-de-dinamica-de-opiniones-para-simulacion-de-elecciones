#### Lectura de los datos y limpieza ####

# Se establece el espacio de trabajo y las librerías a utilizar
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/confianza acotada/experimento2")
library(tidyverse)

experimento2_table <- read.csv('experimento-2-BC-table.csv', skip = 6)
experimento2_table <- experimento2_table %>%
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

# Para este experimento se evalúa el efecto de agents per tick en el modelo de
# BC. Seleccionamos las variables adecuadas para este análisis
experimento2_table <- experimento2_table[c('run_number', 'tick', 'agents_per_tick' ,'pref_A', 'pref_B')]

# Se obtiene el promedio de todas las repeticiones realizadas por cada combinacion de valores de los parametros
experimento2_avg <- experimento2_table %>%
  group_by(agents_per_tick, tick) %>%
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
error_experimento2 <- experimento2_avg %>%
  # Se unen los valores de las encuestas reales a los experimentales
  inner_join(encuestas_reales, by = 'tick') %>%
  # Se calcula el error en cada una de las filas
  mutate(
    err_sq_A = (pct_A - pct_A_real)^2,
    err_sq_B = (pct_B - pct_B_real)^2,
    err_total_punto = (err_sq_A + err_sq_B) / 2
  ) %>%
  # Se agrupa el error en base a los parametros agents_per_tick
  group_by(agents_per_tick) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  # Se ordena de menor a mayor error
  arrange(MSE)

# Se muestran los mejores resultados
head(error_experimento2)

##### Visualización de los resultados ####

ggplot(error_experimento2, aes(x=agents_per_tick, y = RMSE)) +
  geom_point(color = "#2C3E50", size = 1) +
  labs(
    title = "Error de acuerdo al valor del parámetro
    agents per tick",
    x = "Agents per tick",
    y = "Error Cuadrático Medio (RMSE %)"
  ) +
  theme_minimal(base_size = 12) 

#### Mejor modelo ####

# Se seleccionan las simulacioens correspondientes al mejor valor para el número de agentes
experimento2_mejor <- experimento2_table %>%
  filter(agents_per_tick == 7)

experimento2_mejor_avg <- experimento2_mejor %>%
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

ggplot(experimento2_mejor_avg, aes(x = tick)) +
  geom_ribbon(aes(ymin = pct_min_A, ymax = pct_max_A), 
              fill = "brown", alpha = 0.2) +
  
  geom_line(aes(y = pct_A), color = "brown4", size = 1) +
  
  geom_point(data = encuestas_reales, 
             aes(x = tick, y = pct_A_real, shape = "Datos reales"), 
             color = "red", size = 3, shape = 18) +
  
  theme_minimal() +
  labs(
    title = "Evolución de preferencia por A con agents per tick = 7",
    x = "Ticks (Días)",
    y = "Agentes con preferencia por A (%)"
  )
