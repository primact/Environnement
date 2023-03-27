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
# Main Assumptions
###--------------------------

# Get a object which contains the liability portfolio and related assumptions
ptf_passif <- central@canton@ptf_passif

# Show lapses and mortality assumptions
# Flat assumption for total and partial lapses
head(ptf_passif@ht@tables_rach$TRT1@table) # Total
head(ptf_passif@ht@tables_rach$TRP1@table) # Partial

# SimBEL enables to consider cohort tables
head(ptf_passif@ht@tables_mort$TM1@table)

# The parameters for dynamic laspes
ptf_passif@ht@param_rach_dyn

# Functions are developped to get these assumptions
# Get the lapse rate for the table "TRP1" at age 50 and for a duration 2 
get_qx_rach(x = ptf_passif@ht,nom_table = "TRP1", age = as.integer(50), anc = as.integer(2))


# calculate the rate related to the dynamic lapse rules with a target rate of 0.03 and a revalorized rate of 0.01
get_rach_dyn(x = ptf_passif@ht,nom_table = "PRCT1", tx_cible = 0.03, tx_serv = 0.01)

# Plot the dynamic lapses rates
plot(seq(-0.05,0.05, by = 0.001), sapply(seq(-0.05, 0.05, by = 0.001), function(x){
  get_rach_dyn(ptf_passif@ht,"PRCT1", x, 0)}), t = "l", ylab = "Lapses rates", xlab = "Gap"
  ) 

###--------------------------
# Model points
###--------------------------

# Select the object which contains all the saving products
# These product are defined using the own names and stored in a list, e.g. 'epeuro1'
names(ptf_passif@eei)

# Show the layout of model points
head(ptf_passif@eei$epeuro1@mp)

produit <- ptf_passif@eei$epeuro1
# When the canton object is initialized, the death rates and lapse rates have been calculated for each model point
# and for each projection year for reducing the computation times. 
head(produit@tab_proba@qx_dc) # Death rates
head(produit@tab_proba@qx_rach_tot) # Total lapse rates
head(produit@tab_proba@qx_rach_part) # Partial lapse rates

# intial mathematical reserves
pm <- sum(produit@mp$pm)
print(pm)

###--------------------------
# Cash-flows calculation
###--------------------------

# Calculate new premiums
prim <- calc_primes(produit)

# Compute lapse and mortality rates for each model point for the current year
rates <- calc_proba_flux(produit,ptf_passif@ht)
# For instance, display the mortality rates
plot(rates$qx_dc)

# Compute dynamic rates for total and partial lapses
proba_dyn <- calc_proba_dyn(produit,ptf_passif@ht)

# Compute the minimum rates for each model points (max between the technical rate and the so-called 'TMG' which a garantee for a limited period)
r_min <- calc_tx_min(produit, an = 1)

# Compute all the benefits cash-flows
prest <- calc_prest(produit, method = "normal", an = 1L, y = list(
  proba_dyn = proba_dyn, tx_min = r_min, tx_soc = 0.155, choc_lapse_mass = 0)
  )

# Plot the amount of total lapses per model points and the related revalorisation
plot(prest$flux$rach_tot, las = 1, xlab = "Model points", ylab = "Amout of lapses")
plot(prest$flux$rev_rach_tot, las = 1, xlab = "Model points", ylab = "Amout of revalorisation on lapses")

# Plot the amount of management loadings
plot(prest$flux$enc_charg_prest, las = 1, xlab = "Model points", ylab = "Amout of management loadings")

# Plot the number of total lapses
plot(prest$stock$nb_rach_tot, las = 1, xlab = "Model points", ylab = "Number of total lapses")

# Main of amounts of benefits
sum(prest$flux$rach_tot) # Total lapses
sum(prest$flux$dc) # Deaths
sum(prest$flux$rach_part) # Partial lapses
sum(prest$flux$prest) # Total benefits


###--------------------------
# MP calculation
###--------------------------

# Compute the expected revalorisation rates for insured 
y2 <- list(ht=ptf_passif@ht, list_rd=c(0.02,0.01,0.01,0))
exp_rates <- calc_tx_cible(x = produit, y = y2)

# Compute the MP at the end of the year, but before profit sharing attribution
# Create a list with the needed inputs
y3 <- list(tab_prime = prim[["flux"]],
           tab_prest = prest[["flux"]],
           tx_min = r_min,
           tx_soc = 0.155)

pm_ep <- calc_pm(x = produit, method = "normal", an = 1L, tx_cible = exp_rates, y = y3)
print(pm_ep)

# Main of amounts of MPs
sum(pm_ep$stock$pm_deb) # Initial MP
sum(pm_ep$stock$pm_fin) # Final MP
sum(pm_ep$stock$pm_deb) - sum(pm_ep$stock$pm_fin)
sum(pm_ep$stock$pm_deb) - sum(pm_ep$stock$pm_fin) - sum(prest$flux$prest) # Total benefits correspond to the amount of Delta MP

###--------------------------
# Main function: forecasting the model points over one year before profit sharing attribution
###--------------------------
proj <- proj_annee_av_pb(an = 1L, x = ptf_passif, tx_soc = 0.155,
                         coef_inf = 1, list_rd = c(0.02,0.01,0.01,0))

# Resultats en terme flux aggreges par produit
proj[["flux_agg"]]
proj[["stock_agg"]]


