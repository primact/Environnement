## Copyright (C) 2019 Prim'Act, Quentin Guibert
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <https://www.gnu.org/licenses/>.


###--------------------------
# Initialisation
###--------------------------
# Load the objet 'Be' in the central situation
central       <- get(load(paste(racine@address$save_folder$central, "best_estimate.RData", sep = "/")))
# Get the aggregated asset portfolio
ACTIF_central <- print_alloc(central@canton@ptf_fin)[5, 1]

# Load the objets 'Be' related to the shocks of the central formula
action_type_1 <- get(load(paste(racine@address$save_folder$action_type1, "best_estimate.RData", sep = "/")))
action_type_2 <- get(load(paste(racine@address$save_folder$action_type2, "best_estimate.RData", sep = "/")))
immo          <- get(load(paste(racine@address$save_folder$immo, "best_estimate.RData", sep = "/")))
spread        <- get(load(paste(racine@address$save_folder$spread, "best_estimate.RData", sep = "/")))
taux_up       <- get(load(paste(racine@address$save_folder$taux_up, "best_estimate.RData", sep = "/")))
taux_down     <- get(load(paste(racine@address$save_folder$taux_down, "best_estimate.RData", sep = "/")))
frais         <- get(load(paste(racine@address$save_folder$frais, "best_estimate.RData", sep = "/")))
mortalite     <- get(load(paste(racine@address$save_folder$mortalite, "best_estimate.RData", sep = "/")))
longevite     <- get(load(paste(racine@address$save_folder$longevite, "best_estimate.RData", sep = "/")))
rachat_up     <- get(load(paste(racine@address$save_folder$rachat_up, "best_estimate.RData", sep = "/")))
rachat_down   <- get(load(paste(racine@address$save_folder$rachat_down, "best_estimate.RData", sep = "/")))

###--------------------------
# Compute the best estimate  
###--------------------------

# SimBEL enables to save the results into an SQLite database
central@base <- new("DataBase", file_adress = paste(racine@root_address, "internal_ws/data/database", sep = "/"),
                    ecriture_base = T, choc_name = "central")

central@base@ecriture_base <- T # Option for writing into the database

# Launch the calculation
BE_central_result <- run_be(central, pre_on = F, parallel = F)

###--------------------------
# Compute the best estimate for each shock
###--------------------------

# Equity Type 1
action_type_1@base <- new("DataBase", file_adress = paste(racine@root_address, "internal_ws/data/database", sep = "/"),
                          ecriture_base = T, choc_name = "action_type_1")
action_type_1@base@ecriture_base <- T
BE_action_type_1_result <- run_be(action_type_1, F , F)

# Equity Type 2
action_type_2@base <- new("DataBase")
action_type_2@base@ecriture_base <- T
BE_action_type_2_result <- run_be(action_type_2,F,F)

# Property
immo@base <- new("DataBase")
immo@base@ecriture_base <- T
BE_immo_result          <- run_be(immo,F,F)

# Spread
spread@base <- new("DataBase")
spread@base@ecriture_base <- T
BE_spread_result        <-run_be(spread,F,F)

# Interest rate UP
taux_up@base <- new("DataBase")
taux_up@base@ecriture_base <- T
BE_taux_up_result       <- run_be(taux_up,F,F)

# Interest rate Down
taux_down@base <- new("DataBase")
taux_down@base@ecriture_base <- T
BE_taux_down_result     <- run_be(taux_down,F,F)

# Expenses
frais@base <- new("DataBase")
frais@base@ecriture_base <- T
BE_frais_result         <- run_be(frais,F,F)

# Mortality
mortalite@base <- new("DataBase")
mortalite@base@ecriture_base <- T
BE_mortalite_result     <- run_be(mortalite,F,F)

# Longevity
longevite@base <- new("DataBase")
longevite@base@ecriture_base <- T
BE_longevite_result     <- run_be(longevite,F,F)

# Lapse Up
rachat_up@base <- new("DataBase")
rachat_up@base@ecriture_base <- T
BE_rachat_up_result     <- run_be(rachat_up,F,F)

#Lapse down
rachat_down@base <- new("DataBase")
rachat_down@base@ecriture_base <- T
BE_rachat_down_result   <- run_be(rachat_down,F,F)

###--------------------------
# Compute the SCR
###--------------------------

# Get all the shocked best estimate
BE_central       <- BE_central_result$be@tab_be$be[1, 1]
BE_action_type_1 <- BE_action_type_1_result$be@tab_be$be[1, 1]
BE_action_type_2 <- BE_action_type_2_result$be@tab_be$be[1, 1]
BE_immo          <- BE_immo_result$be@tab_be$be[1, 1]
BE_spread        <- BE_spread_result$be@tab_be$be[1, 1]
BE_taux_up       <- BE_taux_up_result$be@tab_be$be[1, 1]
BE_taux_down     <- BE_taux_down_result$be@tab_be$be[1, 1]
BE_frais         <- BE_frais_result$be@tab_be$be[1, 1]
BE_mortalite     <- BE_mortalite_result$be@tab_be$be[1, 1]
BE_longevite     <- BE_longevite_result$be@tab_be$be[1, 1]
BE_rachat_up     <- BE_rachat_up_result$be@tab_be$be[1, 1]
BE_rachat_down   <- BE_rachat_down_result$be@tab_be$be[1, 1]


# Get all the shocked assets
ACTIF_action_type_1 <- print_alloc(action_type_1@canton@ptf_fin)[5,1]
ACTIF_action_type_2 <- print_alloc(action_type_2@canton@ptf_fin)[5,1]
ACTIF_immo          <- print_alloc(immo@canton@ptf_fin)[5,1]
ACTIF_spread        <- print_alloc(spread@canton@ptf_fin)[5,1]
ACTIF_taux_up       <- print_alloc(taux_up@canton@ptf_fin)[5,1]
ACTIF_taux_down     <- print_alloc(taux_down@canton@ptf_fin)[5,1]


# Compute the SCRs for market risk
SCR_action_type_1 <- max(0, (ACTIF_central - BE_central) - (ACTIF_action_type_1 - BE_action_type_1))
SCR_action_type_2 <- max(0, (ACTIF_central - BE_central) - (ACTIF_action_type_2 - BE_action_type_2))
SCR_immo          <- max(0, (ACTIF_central - BE_central) - (ACTIF_immo - BE_immo))
SCR_spread        <- max(0, (ACTIF_central - BE_central) - (ACTIF_spread - BE_spread))
SCR_taux_up       <- max(0, (ACTIF_central - BE_central) - (ACTIF_taux_up - BE_taux_up))
SCR_taux_down     <- max(0, (ACTIF_central - BE_central) - (ACTIF_taux_down - BE_taux_down))
SCR_taux          <- max(SCR_taux_up, SCR_taux_down)


# Compute the SCRs for life underwriting risk
SCR_mortalite    <- max(0, (ACTIF_central - BE_central) - (ACTIF_central - BE_mortalite))
SCR_longevite    <- max(0, (ACTIF_central - BE_central) - (ACTIF_central - BE_longevite))
SCR_rachat_up    <- max(0, (ACTIF_central - BE_central) - (ACTIF_central - BE_rachat_up))
SCR_rachat_down  <- max(0, (ACTIF_central - BE_central) - (ACTIF_central - BE_rachat_down))
SCR_rachat       <- max(SCR_rachat_up, SCR_rachat_down)
SCR_frais        <- max(0, (ACTIF_central - BE_central) - (ACTIF_central - BE_frais))

#---Aggregate the SCR Equity  ---
corrActionType1 <- c(1, 0.75) 
corrActionType2 <- c(0.75 , 1)
MatCorrAction   <- matrix(c(corrActionType1, corrActionType2), nrow = 2, dimnames = list(c("ActionType1", "ActionType2")))

#--- Correlation matrix - Market risks  ---
corrTaux      <- c(1, 0.5, 0.5, 0.5, 0.25) 
corrActions   <- c(0.5, 1, 0.75, 0.75, 0.25)
corrImmo      <- c(0.5, 0.75, 1, 0.5, 0.25)
corrSpread    <- c(0.5, 0.75, 0.5, 1, 0.25)
corrChange    <- c(0.25, 0.25, 0.25, 0.25, 1)
MatCorrMarche <- matrix(c(corrTaux, corrActions, corrImmo, corrSpread, corrChange),
                        nrow = 5, dimnames = list(c("Taux", "Actions", "Immo", "Spread", "Change"), 
                                                  c("Taux", "Actions", "Immo", "Spread", "Change")))

#--- Correlation matrix - Life risks ---
corrMort   <- c(1, -0.25, 0, 0.25)
corrLong   <- c(-0.25, 1, 0.25, 0.25)
corrRachat <- c(0, 0.25, 1, 0.5)
corrFrais  <- c(0.25, 0.25, 0.5, 1)
MatCorrVie <- matrix(c(corrMort, corrLong, corrRachat, corrFrais),
                     nrow = 4, dimnames = list(c("Mort", "Long", "Rachat","Frais"),
                                               c("Mort", "Long", "Rachat","Frais")))

#--- COrrelation matrix- BSCR  ---
corrMarche  <- c(1, 0.25)
corrVie     <- c(0.25, 1)
MatCorrBSCR <- matrix(c(corrMarche, corrVie), nrow = 2, dimnames = list(c("Marche", "VIE"),c("Marche", "VIE")))

# SCR Equity
vectSCRAction   <- t(rbind(SCR_action_type_1, SCR_action_type_2))
aggregerAction  <- function(ligne){sqrt(t(vectSCRAction[ligne, ]) %*% MatCorrAction %*% vectSCRAction[ligne, ])}
SCR_action      <- as.numeric(aggregerAction(1))

# Compute SCR Market
vectSCRMarche   <- t(rbind(SCR_taux, SCR_action, SCR_immo, SCR_spread, SCR_change = 0))
aggregerMarche  <- function(ligne){sqrt(t(vectSCRMarche[ligne, ]) %*% MatCorrMarche %*% vectSCRMarche[ligne, ])}
SCRMarche       <- as.numeric(aggregerMarche(1))

# Compute SCR Life
vectSCRVie  <- cbind(SCR_mortalite, SCR_longevite, SCR_rachat, SCR_frais)
aggregerVie	<- function(ligne){sqrt(t(vectSCRVie[ligne, ]) %*% MatCorrVie %*% vectSCRVie[ligne, ])}
SCRVie      <- as.numeric(aggregerVie(1))

# Compute the BSCR
vectBSCR		  <- cbind(SCRMarche, SCRVie)
aggregerBSCR <- function(ligne){sqrt(t(vectBSCR[ligne, ]) %*% MatCorrBSCR %*% vectBSCR[ligne, ])}
BSCR         <- as.numeric(aggregerBSCR(1))

