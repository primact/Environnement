library(SimBEL)

rm(list = ls())

racine <- new("Initialisation", root_address = getwd())


# Chargement des adresses 
racine <- set_architecture(racine)


# Recuperation du canton initial
init_SimBEL(racine)

init_scenario(racine)
