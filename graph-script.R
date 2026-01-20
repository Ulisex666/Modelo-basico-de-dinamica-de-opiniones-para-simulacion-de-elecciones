library(rlang)
library(ggplot2)
library(tidyverse)
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion")
df <- read.csv("trial-table.csv", skip = 6)
df_clean <- df %>%
  rename(
    tick = X.step.,
    learning_rate = learning.rate, 
    pref_A = pref.A,
    pref_B = pref.B,
    run = X.run.number.
  )

df_avg <- df_clean %>%
  group_by(learning_rate, tick) %>%
  summarise(
    mean_A = mean(pref_A),
    mean_B = mean(pref_B),
    sd_A = sd(pref_A),
    sd_B = sd(pref_B),
    .groups = "drop"
  )

par(mfrow = c(2, 5), mar = c(4, 4, 2, 1)) 

# 2. Obtener la lista de valores únicos de learning_rate
l_rates <- sort(unique(df_avg$learning_rate))

# 3. Crear un bucle para graficar cada caso
for (rate in l_rates) {
  
  # Filtrar los datos para el learning_rate actual
  subset_data <- df_avg[df_avg$learning_rate == rate, ]
  
  # Crear la base de la gráfica con la primera variable (pref_A)
  plot(subset_data$tick, subset_data$mean_A, 
       type = "l",           # "l" de líneas
       col = "blue", 
       ylim = c(-1, 1),       # Asumiendo que las preferencias van de 0 a 1
       main = paste("LR:", rate), 
       xlab = "Ticks", 
       ylab = "Pref",
       las = 1)              # Poner los números del eje Y horizontales
  
  # Añadir la segunda variable (pref_B) encima
  lines(subset_data$tick, subset_data$mean_B, 
        col = "red")
}

# 4. (Opcional) Volver a la configuración de una sola gráfica por pantalla
par(mfrow = c(1, 1))
