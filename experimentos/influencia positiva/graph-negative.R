library(rlang)
library(tidyverse)
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/influencia negativa")
df <- read.csv("neg-infl-table.csv", skip = 6)
df_clean <- df %>%
  rename(
    tick = X.step.,
    confidence_threshold = confidence.threshold, 
    pref_A = pref.A,
    pref_B = pref.B,
    run = X.run.number.
  )

ticks_real <- c(0, 13500, 32000, 50000)
morena_real <- c(61, 64, 61, 68)
prian_real <- c(39, 36, 39, 32)

df_avg <- df_clean %>%
  group_by(confidence_threshold, tick) %>%
  summarise(
    mean_A = mean(pref_A),
    mean_B = mean(pref_B),
    sd_A = sd(pref_A),
    sd_B = sd(pref_B),
    .groups = "drop"
  )

df_avg$pct_A <- (df_avg$mean_A / 441) * 100
df_avg$pct_B <- (df_avg$mean_B / 441) * 100


plot(df_avg$tick, df_avg$mean_A, type = "n", 
     ylim = c(0, 100), 
     xlim = c(0, 50000),
     xlab = "Ticks", 
     ylab = "Porcentaje de agentes con preferencia A",
     main = "Cambio de opinión bajo influencia negativa",
     las = 1)

# 2. Definir los valores de learning_rate y los colores
c_tresholds <- sort(unique(df_avg$confidence_threshold))
colores <- terrain.colors(length(c_tresholds))

# 3. Dibujar una línea por cada learning_rate
for (i in 1:length(c_tresholds)) {
  datos_temp <- subset(df_avg, confidence_threshold == c_tresholds[i])
  lines(datos_temp$tick, datos_temp$pct_A, col = colores[i], lwd = 2)
}

# Graficar datos reales para MORENA y PRIAN
lines(ticks_real, morena_real, col = 'red', lwd = 2)
lines(ticks_real, prian_real, col = 'blue', lwd = 2)

for (i in 1:length(c_tresholds)) {
  datos_temp <- subset(df_avg, confidence_threshold == c_tresholds[i])
  lines(datos_temp$tick, datos_temp$pct_B, col = colores[i], lwd = 2)
}
# 4. Añadir una leyenda para saber qué color es cuál
legend("bottomleft", legend = c_tresholds, col = colores, 
       lwd = 2, title = "Cota de confianza", cex = 0.6, ncol = 2)

