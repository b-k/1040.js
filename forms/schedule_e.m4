m4_form(f1040_sched_e)

Cell(rents_received, 3, Rents received,, u have_rr)
Cell(royalties_received, 4, Royalties received,, u have_rr)

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
Cell(total_rental_expenses, 20, Total expenses, <|SUM(rental_advertising, 
            rental_auto_and_travel, rental_cleaning_and_maintenance, 
            rental_commissions, rental_insurance, rental_professional_fees,
            rental_management_fees, rental_mortgage_interest, rental_other_interest,
            rental_repairs, rental_supplies, rental_taxes, rental_utilities,
            rental_depreciation, rental_other_expenses)|>, have_rr)

    I'm doing that thing where only the part that was modified for content gets modified for formatting.

    Cell(net_rents, 21,
        Rents minus expenses,
        <|CV(rents_received) - CV(total_rental_expenses)|>,
        have_rr
    )
    Cell(net_royalties, 21.1,
        Royalties minus expenses,
        <|CV(royalties_received) - CV(royalty_expenses)|>,
        have_rr
    )
    Cell(deductible_rr_losses, 22,
        Limited deductible rental real estate loss and/or prior year losses,
        <|CV(f8582, total_losses_8582)|>,
        have_rr
    )
    Cell(post_8582_net_rents, 22.5,
        Rental profit or loss after line 22,
        <|IF(CV(net_rents)>0,
               CV(net_rents) + CV(deductible_rr_losses),
               CV(deductible_rr_losses))|>,
        have_rr
    )
    Cell(sched_e_income, 24,
        Positive RR Income (PI),
        <|max(0,CV(post_8582_net_rents)) + max(0,CV(net_royalties))|>,
        have_rr
    )
    Cell(rr_losses, 25,
        Royalty losses plus possibly limited rental losses (PI),
        <|min(0,CV(post_8582_net_rents)) + min(CV(net_royalties),0)|>,
        have_rr
    )
    Ce<||>ll(rr_losses, 25,
        Royalty losses plus possibly limited rental losses (PI),
        <|min(0,CV(post_8582_net_rents)) - min(CV(net_royalties),0)|>,
        have_rr
    )
    Cell(rr_income, 26,
        Total rents and royalties,
        <|SUM(sched_e_income, rr_losses)|>,
        have_rr
    )

    Reformatting the two cells of f4562 even though nothing changed
m4_form(f4562)
    Cell(rental_property_value, 19,
        <|Rental property value, for 27.5yr straight line depreciation|>, ,
        u have_rr
    )
    Cell(rental_property_depreciation, 19,
        Rental property depreciation,
        <|CV(rental_property_value)/27.5|>,
        have_rr
    )
