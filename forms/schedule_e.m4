m4_form(f1040_sched_e)

#an old draft:
#sum losses from royalties to possibly limited real estate losses
def rrlosses(rents, royalties, net, real_loss):
    if isinstance(net, tuple):
        total = 0
        for i in range(0, len(net)):
            if net[i]<0 and royalties[i]>0: total = total + net[i]
            if real_loss[i]<0: total = total + real_loss[i]
    else:
        if rents > 0: return real_loss
        elif net <0:         return net
    return 0

Cell(rents_received, 3, Rents received,, u have_rr)
Cell(royalties_received, 4, Royalties received,, u have_rr)
Ce<||>ll(sched_e_expenses_header , >>>>>>>>>>> expenses            , 4.9, have_rr)

Cell(rental_advertising, 5, Advertising,, u have_rr)
Cell(rental_auto_and_travel, 6, Auto and travel,, u have_rr)
Cell(rental_cleaning_and_maintenance, 7, Cleaning and maintenance,, u have_rr)
Cell(rental_commissions, 8, Commissions,, u have_rr)
Cell(rental_insurance, 9, Insurance,, u have_rr)
Cell(rental_professional_fees, 10, Legal and other professional fees,, u have_rr)
Cell(rental_management_fees, 11, Management fees,, u have_rr)
Cell(rental_mortgage_interest, 12, <|Mortgage interest paid to banks, etc|>,, u have_rr)
Cell(rental_other_interest, 13, Other interest,, u have_rr)
Cell(rental_repairs, 14, Repairs,, u have_rr)
Cell(rental_supplies, 15, Supplies,, u have_rr)
Cell(rental_taxes, 16, Taxes,, u have_rr)
Cell(rental_utilities, 17, Utilities,, u have_rr)
Cell(rental_depreciation, 18, Depreciation expense or depletion, <|CV(f4562, rental_property_depreciation)|>, have_rr)
Cell(rental_other_expenses, 19, Other,, u have_rr)
Cell(royalty_expenses, 4.5, Other,, u have_rr)
Cell(total_rental_expenses, 20, Total expenses, <|SUM(rental_advertising, rental_auto_and_travel, rental_cleaning_and_maintenance, rental_commissions, rental_insurance, rental_professional_fees, rental_management_fees, rental_mortgage_interest, rental_other_interest, rental_repairs, rental_supplies, rental_taxes, rental_utilities, rental_depreciation, rental_other_expenses)|>, have_rr)

Cell(net_rents, 21, Rents minus expenses, <|CV(rents_received) - CV(total_rental_expenses)|>, have_rr)
Cell(net_royalties, 21.1, Royalties minus expenses, <|CV(royalties_received) - CV(royalty_expenses)|>, have_rr)

Cell(deductible_rr_losses, 22, Deductible rental real estate loss after limitation, <|CV(f8582, total_losses_8582)|>, have_rr)

Cell(sched_e_sum3, 23.0, Total for line 3 for all rentals, <|CV(rents_received)|>, have_rr)
Cell(sched_e_sum4, 23.2, Total for line 4 for all royaltys, <|CV(royalties_received)|>, have_rr)
Cell(sched_e_sum12, 23.4, Total for line 12 for all propertiess, <|CV(mortgage_interest)|>, have_rr)
Cell(sched_e_sum18, 23.6, Total for line 18 for all propertiess, <|CV(depreciation)|>, have_rr)
Cell(sched_e_sum20, 23.8, Total for line 20 for all propertiess, <|CV(total_rental_expenses)|>, have_rr)

Cell(sched_e_income, 24, Positive RR Income (PI), <|max(0,CV(net_rents)) + max(0,CV(net_royalties))|>, have_rr)
Cell(rr_losses, 25, Royalty losses plus possibly limited rental losses (PI), <|IF(CV(rents_received) > 0, CV(deductible_rr_losses), <|min(0,CV(net_rents))|>) + min(CV(net_royalties),0)|>, have_rr)
Cell(rr_income, 26, Total rents and royalties, <|SUM(sched_e_income, rr_losses)|>, have_rr)

m4_form(f4562)
Cell(rental_property_value, 19, <|Rental property value, for 27.5yr straight line depreciation|>, , u have_rr)
Cell(rental_property_depreciation, 19, Rental property depreciation, <|CV(rental_property_value)/27.5|>, have_rr)
