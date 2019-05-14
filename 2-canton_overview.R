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

## Canton overview of the main assumptions

# Load the objet 'Be' corresponding to the central siuation.
central <- get(load(paste(racine@address$save_folder$central, "best_estimate.RData", sep = "/")))
class(central)

# 'central' contains the initial 'canton', and additional adjustements: 
# - a table with scenarios coming from the ESG.
# - the risk-neutralization of the bonds portfolio.
# - the computation of fixed death probabilities for reducing the computation times.

# Additional parameters
central@param_be

##-------------------
## ESG
##-------------------
class(central@esg)

# Number of simulations
central@esg@nb_simu

# Displays the variables from the ESG
nb_proj <- 5

# Equity - Index 1
matplot(t(central@esg@ind_action[[1]][,1:(nb_proj + 1)]), type='l', xlab='Years', ylab='Prices',
        main='Price Paths for Equty 1')

# Property - Index 1
matplot(t(central@esg@ind_immo[[1]][,1:(nb_proj + 1)]), type='l', xlab='Years', ylab='Prices',
        main='Price Paths for Property 1')

# Inflation
matplot(t(central@esg@ind_inflation[,1:(nb_proj + 1)]), type='l', xlab='Years', ylab='Prices',
        main='Inflation index')

# Simulated spot risk free rate curves at time 3 
matplot(t(central@esg@yield_curve[[3]]), type='l', xlab='Years', ylab='Rates',
        main='RFR curves')

##-------------------
## Canton
##-------------------

# Currennt year of projection
central@canton@annee 

# The economic scenario corresponding to the initial values for market risk 
central@canton@mp_esg

# High levels assumptions
central@canton@hyp_canton


# Initial value and parameters related to the 'Provision pour participation aux bénéfices'.
central@canton@ppb

# Initial values for:
# - the reference portfolio of assets
# - the target allocation of assets
# - a parameter which controls the part of capital gain which can be realized each year 
central@canton@param_alm@ptf_reference
central@canton@param_alm@alloc_cible
central@canton@param_alm@seuil_realisation_PVL

# Parameters for the regulatory profit sharing rules
central@canton@param_revalo@taux_pb_fi
central@canton@param_revalo@taux_pb_tech
central@canton@param_revalo@solde_pb_regl

# A parameter for the discretionnary profit sharing rules: the minimal rate of financial margin  
central@canton@param_revalo@tx_marge_min


