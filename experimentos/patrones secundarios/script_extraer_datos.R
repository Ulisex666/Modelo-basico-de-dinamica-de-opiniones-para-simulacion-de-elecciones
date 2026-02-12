# Este es el script utilizado para extraer la edad y sexo de aquellos considerados
# en las encuestas realizadas, para poder evaluar la capacidad del modelo de
# replicar patrones secundarios

#### Carga de paqueterías ####
setwd("C:/Users/ulise/Documents/GitHub/Modelo-base-dinamica-de-opinion/experimentos/patrones secundarios")
library(tidyverse)
library(haven)
library(labelled)

# Se leen en memoria las tres bases de datos, las encuestas realizadas por el grupo 
# GEA-ISA sobre la intencion de voto en las elecciones mexicanas a nivel presidencial
# en el 2024
primera_encuesta = read_sav("primera_encuesta.sav")
segunda_encuesta = read_sav("segunda_encuesta.sav")
tercera_encuesta = read_sav("tercera_encuesta.sav")

# Vemos los atributos en la pregunta relacionada a la intencion de voto, clasificada
# por alianza de los partidos
attr(primera_encuesta$R61, "labels") # En la primera encuesta, se tiene en la pregunta R61
attr(segunda_encuesta$R74, "labels") # En la segunda encuesta, se tiene en la pregunta R74
attr(tercera_encuesta$R71, "labels") # En la tercera encuesta, se tiene en la 
filtro_morena = 2
filtro_prian = 1

pref_principales_primera <- primera_encuesta %>%
  filter(R61 == filtro_morena | R61 == filtro_prian)

pref_principales_segunda <- segunda_encuesta %>%
  filter(R74 == filtro_morena | R74 == filtro_prian)

pref_principales_tercera <- tercera_encuesta %>%
  filter(R71 == filtro_morena | R71 == filtro_prian)



