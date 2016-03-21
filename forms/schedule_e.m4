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

Cell(advertising, 5, Advertising,, u have_rr)
Cell(auto_and_travel, 6, Auto and travel,, u have_rr)
Cell(cleaning_and_maintenance, 7, Cleaning and maintenance,, u have_rr)
Cell(commissions, 8, Commissions,, u have_rr)
Cell(insurance, 9, Insurance,, u have_rr)
Cell(professional_fees, 10, Legal and other professional fees,, u have_rr)
Cell(management_fees, 11, Management fees,, u have_rr)
Cell(mortgage_interest, 12, <|Mortgage interest paid to banks, etc|>,, u have_rr)
Cell(other_interest, 13, Other interest,, u have_rr)
Cell(repairs, 14, Repairs,, u have_rr)
Cell(supplies, 15, Supplies,, u have_rr)
Cell(taxes, 16, Taxes,, u have_rr)
Cell(utilities, 17, Utilities,, u have_rr)
Cell(depreciation, 18, Depreciation expense or depletion,, u have_rr)
Cell(other_expenses, 19, Other,, u have_rr)
Cell(total_expenses, 20, Total expenses, <|SUM(advertising, auto_and_travel, cleaning_and_maintenance, commissions, insurance, professional_fees, management_fees, mortgage_interest, other_interest, repairs, supplies, taxes, utilities, depreciation, other_expenses)|>, have_rr)

Cell(net_rr, 21, Rents/royalties minus expenses, <|SUM(rents_received, royalties_received) - CV(total_expenses)|>, have_rr)

Cell(deductible_rr_losses, 22, Deductible rental real estate loss after limitation, <|CV(f8582, total_losses_8582)|>, have_rr)

Cell(sched_e_sum3, 23.0, Total for line 3 for all rentals, <|CV(rents_received)|>, have_rr)
Cell(sched_e_sum4, 23.2, Total for line 4 for all royaltys, <|CV(royalties_received)|>, have_rr)
Cell(sched_e_sum12, 23.4, Total for line 12 for all propertiess, <|CV(mortgage_interest)|>, have_rr)
Cell(sched_e_sum18, 23.6, Total for line 18 for all propertiess, <|CV(depreciation)|>, have_rr)
Cell(sched_e_sum20, 23.8, Total for line 20 for all propertiess, <|CV(total_expenses)|>, have_rr)

Cell(sched_e_income, 24, Positive RR Income, <|CV(net_rr)|>, have_rr)
Cell(rr_losses, 25, Royalty losses plus possibly limited rental losses, <|IF(CV(rents_received) > 0, CV(deductible_rr_losses), min(CV(net_rr),0))|>, have_rr)
Cell(rr_income, 26, Total rents and royalties, <|SUM(sched_e_income, rr_losses)|>, have_rr)
