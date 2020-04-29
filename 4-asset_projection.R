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
# get the asset porfolio
ptf_fin <- central@canton@ptf_fin

# get a simulation
num_simu <- 10L

# get the year of projection
year <- 1L

# get the yield of each asset from the ESG table
rdt <- calc_rdt(ptf_fin, extract_ESG(central@esg, num_simu, year))

###--------------------------
# Equity (similar for property assets)
###--------------------------
# Print the equity portfolio
print(ptf_fin@ptf_action)

# Yield of equities
print(rdt$rdt_action)

###--------------------------
# Bond
###--------------------------
# Print the bond  portfolio
print(ptf_fin@ptf_oblig)

# Compute the cash-flows of the year
calc_flux_annee(ptf_fin@ptf_oblig)

# Compute the value of bonds after a shock on the yield curve/ For instance, take a parallel shift of 50 bps
curve_bef_shock <- central@canton@mp_esg@yield_curve
curve_af_shock <- central@canton@mp_esg@yield_curve + 0.005

vm_bef <- calc_vm_oblig(ptf_fin@ptf_oblig, curve_bef_shock)
vm_af <- calc_vm_oblig(ptf_fin@ptf_oblig, curve_af_shock)
gap <- vm_af - vm_bef 

# Compute the book value (French GAAP) considering the 'surcote-decote'
new_vnc <- calc_vnc(ptf_fin@ptf_oblig, ptf_fin@ptf_oblig@ptf_oblig$sd)
gap_vnc <- new_vnc - ptf_fin@ptf_oblig@ptf_oblig$val_nc

###--------------------------
# Cash
###--------------------------
# Print the cash
print(ptf_fin@ptf_treso)

# Return the yield
print(rdt$rdt_treso)

###--------------------------
# Asset projection over one year
###--------------------------

# Equity portfolio (update the equity portfolio and return the objet 'ptf_fin')
equity_after <- vieillissement_action_PortFin(ptf_fin, rdt)[["portFin"]]@ptf_action@ptf_action

# Update all the asset porftolio
# In SimBEL, we assume that:
# - the cash-flows are perceived in mid-year
# - the maturity of bonds is the end of the year
# These inputs cash-flows are compensated by the paiement of benefits
# For instance here, update the portfolio ignoring these benefits cash-flows
port_eoy <- update_PortFin(an = year , ptf_fin, central@canton@mp_esg, flux_milieu = 0, flux_fin = 0)

# Print the equity portfolio at the end of the year
print(port_eoy$ptf@ptf_action)

# The aggregated amount of cash-flows
print(port_eoy$revenu_fin)
# The amount of cash-flows per asset class
print(port_eoy$revenu_fin_det)

###--------------------------
# Provisions related to the asset portfolio
###--------------------------

# Assume the unrealized capital gain or loss on equities and properties are equal to 300000
pmvl_action_immo <- -300000

# Initial PRE is zero and it is amortized over 5 years  
pre_bef <- central@canton@ptf_fin@pre
print(pre_bef)

# Compute the new PRE
calc_PRE(x=central@canton@ptf_fin@pre, pmvl_action_immo = pmvl_action_immo) # 60000 = 300000/5



# Assume the realized capital gain are equal to 100000
pmvr_oblig <- 100000

# Update the 'Reverse de capitalisation
calc_RC(x = central@canton@ptf_fin@rc, pmvr_oblig = pmvr_oblig)

###--------------------------
# Reallocate the asset
###--------------------------
# A reference porftolio contains all the assets which can be bought on the market 
ptf_reference <- central@canton@param_alm@ptf_reference
# For instance, print the equities available
ptf_reference@ptf_action

port_af_alloc <- reallocate(x = ptf_fin, ptf_reference = ptf_reference, alloc_cible = central@canton@param_alm@alloc_cible)

# Initial allocation
print_alloc(ptf_fin)

# After reallocation
print_alloc(port_af_alloc$portFin)






