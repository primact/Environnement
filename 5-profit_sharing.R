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


# Management rules: profit sharing

###--------------------------
# Initialisation
###--------------------------
# Get a object which contains the liability portfolio and related assumptions
central <- get(load(paste(racine@address$save_folder$central, "best_estimate.RData", sep = "/")))
ptf_passif <- central@canton@ptf_passif

# Current year
year <- 1L

###--------------------------
# Asset and liability before profit sharing
###--------------------------

# Liability portfolio at the end of the year before profit sharing
# ptf_eoy <- proj_annee_av_pb(an = year, x = ptf_passif, tx_soc = 0.155, coef_inf = 1, list_rd = c(0.02,0.01,0.01,0))

liab_eoy <- viellissement_av_pb(an = year, ptf_passif, coef_inf = 1, list_rd =c(0.02,0.01,0.01,0), tx_soc = 0.155)

asset_eoy <- update_PortFin(an = year, ptf_fin, new_mp_ESG = central@canton@mp_esg,
                            flux_milieu = liab_eoy[["flux_milieu"]], flux_fin = liab_eoy[["flux_fin"]])

# Get the updated asset portfolio
ptf_fin <- asset_eoy[["ptf"]]

# Get the financial incomes and the realized capital gain and loss on bonds
income <- asset_eoy[["revenu_fin"]]
var_vnc_bond <- asset_eoy[["var_vnc_oblig"]]

# Reallocate the asset portfolio
asset_realloc <- reallocate(ptf_fin, central@canton@param_alm@ptf_reference, central@canton@param_alm@alloc_cible)

# Compute the technical results, including Delta provisions on 'PRE'
result_tech <- calc_result_technique(liab_eoy, asset_realloc[["var_pre"]])
print(resultat_tech)

# Compute the financial results
result_fin <- calc_resultat_fin(income + var_vnc_bond, asset_realloc[["pmvr"]],
                                  frais_fin = 0, asset_realloc[["var_rc"]])

# Compute the TRA (return rate on assets according to the Frenc GAAP)
tra <- calc_tra(asset_realloc[["plac_moy_vnc"]], result_fin)
print(tra)

###--------------------------
# Apply the profit sharing algorithm
###--------------------------
result_revalo <- calc_revalo(central@canton, liab_eoy, tra,
                             asset_realloc[["plac_moy_vnc"]], result_tech)
#updated PPB
result_revalo$ppb

# Profit sharing rate
result_revalo$tx_pb

# Amont of profil sharing to allocate
result_revalo$add_rev_nette_stock

# Amount of gain of loss which are be realized for reaching the target revalorisation rate
result_revalo$pmvl_liq


###--------------------------
# Explore the profit sharing algorithm with simple examples
###--------------------------

# Step 0: initialisation
###-------------------------
# Data
tra_1 <- 0.05
tra_2 <- 0.02
tra_3 <- 0.01
tra_4 <- - 0.01

# 4 products and their profit sharing rates
pm_moy <- rep(100, 4)
tx_pb <- c(0.90, 0.95, 0.97, 1)

# Create an initial PPB as nul
ppb <- new(Class = "Ppb")
ppb@valeur_ppb <- ppb@ppb_debut <- 8 # The initial amount of PPB is equal to 8
ppb@hist_ppb <- rep(1, 8) # This amount have be endowed uniformaly during the last 8 years
ppb@seuil_rep <-  ppb@seuil_dot <- 0.5 # The PPB can be endowed or ceded until 50%

# Assume the loadings are nul
tx_enc_moy <- c(0, 0, 0, 0)

# Step 1: contractual profit sharing
###-------------------------
# Compute the financial result related to the liability
# base_fin_1 <- tra_1 * (sum(pm_moy) + ppb["ppb_debut"]) * pm_moy / sum(pm_moy)
base_fin_1 <- base_prod_fin(tra_1, pm_moy, ppb)
base_fin_2 <- base_prod_fin(tra_2, pm_moy, ppb)
base_fin_3 <- base_prod_fin(tra_3, pm_moy, ppb)
base_fin_4 <- base_prod_fin(tra_4, pm_moy, ppb)


# Revalorisation considering a minimum rate of 1% 
rev_stock_brut <- pm_moy * 0.01
ch_enc_th <- pm_moy * (1 + 0.01) * tx_enc_moy

# Amount of contractual profit sharing considering the minimal rate
reval_contr_1 <- pb_contr(base_fin_1$base_prod_fin, tx_pb, rev_stock_brut, ch_enc_th, tx_enc_moy)
reval_contr_2 <- pb_contr(base_fin_2$base_prod_fin, tx_pb, rev_stock_brut, ch_enc_th, tx_enc_moy)
reval_contr_3 <- pb_contr(base_fin_3$base_prod_fin, tx_pb, rev_stock_brut, ch_enc_th, tx_enc_moy)
reval_contr_4 <- pb_contr(base_fin_4$base_prod_fin, tx_pb, rev_stock_brut, ch_enc_th, tx_enc_moy)


# Step 2: TMG
###-------------------------
# The PPB can finance the need ralated to the TMG garantee
tmg <- 0.02 # High TMG
# tmg <- 0    # No TMG
bes_tmg_stock <- pm_moy * tmg
bes_tmg_prest <- pm_moy * 0 # Assumption no TMG on benefits

financement_tmg <- finance_tmg(bes_tmg_prest, bes_tmg_stock, ppb)

# Update the PPB objet
ppb <- financement_tmg[["ppb"]]


# Step 3: Regulatory constraints on the PPB
###-------------------------
# Regulatory constraint: 8 years for using the PPB 
ppb_8 <- ppb_8ans(ppb)

# Update the PPB objet
ppb <- ppb_8[["ppb"]]

# Allocate this amount to each product, e.g. with the weights in terms of MP
som <- sum(pm_moy)
ppb8_ind <- ppb_8$ppb_8 * pm_moy / som

# Step 4: Reach the target rate
###-------------------------
# Assume the insured expects a rate on return of 3.00%
target_rate <- 0.03
bes_tx_cible <- pm_moy * target_rate

# Option #1 Use the PPB for reaching this target
tx_cibl_ppb_1 <- finance_cible_ppb(bes_tx_cible, reval_contr_1$rev_stock_nette_contr, ppb, ppb8_ind)
tx_cibl_ppb_2 <- finance_cible_ppb(bes_tx_cible, reval_contr_2$rev_stock_nette_contr, ppb, ppb8_ind)
tx_cibl_ppb_3 <- finance_cible_ppb(bes_tx_cible, reval_contr_3$rev_stock_nette_contr, ppb, ppb8_ind)
tx_cibl_ppb_4 <- finance_cible_ppb(bes_tx_cible, reval_contr_4$rev_stock_nette_contr, ppb, ppb8_ind)

# Mise a jour de la PPB, e.g. in case #1 
ppb <- tx_cibl_ppb_1$ppb

# Option #2 Sell shares for reaching this target

# Assume the amount of unrealized gain of shares which can be sold is limited to 5 
seuil_pmvl <- 5

# Revalorisation after selling shares
tx_cibl_pmvl_1 <- finance_cible_pmvl(bes_tx_cible, tx_cibl_ppb_1$rev_stock_nette, base_fin_1$base_prod_fin, seuil_pmvl, tx_pb)
tx_cibl_pmvl_2 <- finance_cible_pmvl(bes_tx_cible, tx_cibl_ppb_2$rev_stock_nette, base_fin_2$base_prod_fin, seuil_pmvl, tx_pb)
tx_cibl_pmvl_3 <- finance_cible_pmvl(bes_tx_cible, tx_cibl_ppb_3$rev_stock_nette, base_fin_3$base_prod_fin, seuil_pmvl, tx_pb)
tx_cibl_pmvl_4 <- finance_cible_pmvl(bes_tx_cible, tx_cibl_ppb_4$rev_stock_nette, base_fin_4$base_prod_fin, seuil_pmvl, tx_pb)

# Step 5: Apply the legal constraints on the overall portfolio
#---------------------------------------------------------------

# Technical results is zero
result_tech <- 0
it_tech <- rev_stock_brut

revalo_finale_1 <- finance_contrainte_legale(base_fin_1$base_prod_fin, base_fin_1$base_prod_fin_port,
                                           result_tech,  it_tech,
                                           tx_cibl_pmvl_1$rev_stock_nette,
                                           bes_tmg_prest,
                                           tx_cibl_ppb_1$dotation, 0, ppb,
                                           central@canton@param_revalo)


###--------------------------
# Summary function for launching all the steps over the year 
###--------------------------
result_proj_an <-proj_an(x = central@canton, annee_fin = central@param_be@nb_annee, pre_on = T)
