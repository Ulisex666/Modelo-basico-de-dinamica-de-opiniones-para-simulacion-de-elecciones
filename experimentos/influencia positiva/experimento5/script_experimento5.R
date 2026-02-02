#### Lectura de los datos y limpieza ####

# Se establece el espacio de trabajo y las librerías a utilizar
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia positiva/experimento5")
library(tidyverse)

# Se lee la tabla obtenida del experimento y se cambian los nombres de las variables
experimento5_table <- read.csv('experimento-5-positiva-table.csv', skip = 6)
experimento5_table <- experimento5_table %>%
  rename(
    tick = X.step., 
    run_number = X.run.number.,
    pref_A = pref.A,
    pref_B = pref.B,
    agents_per_tick = agents.updated.per.tick,
    learning_rate = learning.rate
  )

# Se eligen unicamente las variables necesarias para el analisis
experimento5_table <- experimento5_table[c('run_number', 'tick', 'agents_per_tick', 'learning_rate' ,'pref_A', 'pref_B')]

# Se obtiene el promedio de todas las repeticiones realizadas por cada combinacion de valores de los parametros
experimento5_avg <- experimento5_table %>%
  group_by(agents_per_tick, learning_rate, tick) %>%
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
error_experimento5 <- experimento5_avg %>%
  # Se unen los valores de las encuestas reales a los experimentales
  inner_join(encuestas_reales, by = 'tick') %>%
  # Se calcula el error en cada una de las filas
  mutate(
    err_sq_A = (pct_A - pct_A_real)^2,
    err_sq_B = (pct_B - pct_B_real)^2,
    err_total_punto = (err_sq_A + err_sq_B) / 2
  ) %>%
  # Se agrupa el error en base a los parametros learning_rate y agents_per_tick
  group_by(agents_per_tick, learning_rate) %>%
  summarise(
    MSE = mean(err_sq_A),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  # Se ordena de menor a mayor error
  arrange(MSE)

# Se muestran los mejores resultados
head(error_experimento5)

#### Grafico de los resultados ####


# Mapa de calor en base al error obtenido para todos los valores
ggplot(error_experimento5, aes(x = learning_rate, y = agents_per_tick, fill = RMSE)) +
  geom_tile() +
  # Usamos una escala de color 'inferno' o 'viridis' para que se note el contraste
  scale_fill_viridis_c(option = "magma", direction = -1) + 
  labs(
    title = "Mapa de Error: Learning Rate vs. Número de Agentes",
    x = "Learning Rate",
    y = "Número de Agentes",
    fill = "RMSE (%)"
  ) +
  theme_minimal()

# Acercamiento. Se eliminan parametros redundantes

error_filtrado <- error_experimento5 %>%
  filter(learning_rate > 0 & learning_rate < 1) %>%
  filter(agents_per_tick < 100)

# Mapa de calor centrado en los valores interesantes para los parametros analizados\
ggplot(error_filtrado, aes(x = learning_rate, y = agents_per_tick, fill = RMSE)) +
  geom_tile() +
  # Usamos una escala de color 'inferno' o 'viridis' para que se note el contraste
  scale_fill_viridis_c(option = "magma", direction = -1) + 
  labs(
    title = "Mapa de Error: Learning Rate vs. Número de Agentes",
    x = "Learning Rate",
    y = "Número de Agentes",
    fill = "RMSE (%)"
  ) +
  theme_minimal()