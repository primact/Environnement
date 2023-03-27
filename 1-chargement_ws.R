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

## Data loading

# Remove object in the current environment 
rm(list = ls())

# Load the library SimBEL
library(SimBEL)

# Create an object of class 'Initialisation' which will contain all the file paths to the data and parameters 
racine <- new("Initialisation", root_address = getwd())


# Load the file paths and basic parameters (number of simulation and the forecasting horizon) 
racine <- set_architecture(racine)


# Initialize the projet: load all the data and parameters and build the initial 'canton'. It is saved in the folder 'interval_ws/data/init
init_SimBEL(racine)

# Load the initial 'canton' from data and parameters
canton_init <- get(load(paste(racine@address[["save_folder"]][["init"]], "canton_init.RData", sep = "/")))

# Some adjustements are needed. We define a 'central' scenario and shocked scenarios which correspond to the canton's situation after each
# shocks of the Solvency II standard formula. The following command allows allows to do all the operations in one go. 
init_scenario(racine)


