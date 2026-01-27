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
    MSE = mean(err_total_punto),
    RMSE = sqrt(MSE),
    .groups = "drop"
  ) %>%
  
  # 4. Ordenar de menor a mayor error
  arrange(MSE)

# Ver los 5 mejores "learning rates" (los que mejor ajustan a la realidad)
head(analisis_error, 10)

plot(analisis_error$learning_rate, analisis_error$RMSE, 
     type = "p", 
     col = "darkblue", 
     lwd = 2,
     main = "Learning rate vs RMSE", 
     xlab = "Learning rate", 
     ylab = "RMSE (%)",
     las = 1)

# 2. (Opcional) Resaltar el punto con el error mínimo
mejor_lr <- analisis_error[which.min(analisis_error$RMSE), ]

points(mejor_lr$learning_rate, mejor_lr$RMSE, 
       col = "red", pch = 19, cex = 1.5)

# 3. (Opcional) Añadir una etiqueta al punto mínimo
text(mejor_lr$learning_rate, mejor_lr$RMSE, 
     labels = paste("Min RMSE:", round(mejor_lr$RMSE, 2)), 
     pos = 4, col = "red", cex = 0.8)

# 4. Añadir una rejilla para facilitar la lectura
grid(nx = NULL, ny = NULL, col = "gray", lty = "dotted")

