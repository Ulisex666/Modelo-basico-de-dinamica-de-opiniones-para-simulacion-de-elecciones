setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/patrones secundarios")
library(tidyverse)
library(haven)
library(labelled)

tercera_encuesta = read_sav("datos_sav/pref_principales_tercera.sav")
mujeres_tercera_encuesta <- filter(tercera_encuesta, sexo == 2)
hombres_tercera_encuesta <- filter(tercera_encuesta, sexo == 1)

mujeres_prian <- filter(mujeres_tercera_encuesta, R71 == 1)
mujeres_morena <- filter(mujeres_tercera_encuesta, R71 == 2)

hombres_prian <- filter(hombres_tercera_encuesta, R71 == 1)
hombres_morena <- filter(hombres_tercera_encuesta, R71 == 2)
