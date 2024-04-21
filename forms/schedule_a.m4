m4_form(f1040_sched_a)

adiv1=cell('>>>>>>>>>>>> Medical and Dental                       ', 0.9, '0'),

Cell(medical_expenses, 1, Medical and dental expenses,, u itemizing)
Cell(agi_scaled, 3,
        AGI scaled,
        <|CV(f1040, AGI)* IF(Situation(over_65)+Situation(spouse_over_65), .075, .1)|>
        , itemizing
    )
Cell(excess_medical, 4,
        Medical expenses minus fraction of AGI,
        <|max(CV(medical_expenses) - CV(agi_scaled), 0)|>,
        itemizing
    )

adiv2=cell('>>>>>>>>>>>> Taxes you paid                           ', 4.9, '0'),
Cell(local_taxes, 5,
        State/local Income OR general sales tax,
        , u itemizing
    )
Cell(real_estate_taxes, 5.1,
        Real estate taxes,
        , u itemizing
    )

Cell(property_taxes, 5.2,
        Personal property taxes,
        , u itemizing
    )

Cell(salt_capped, 7,
        <|State/local/real estate taxes, capped|>,
        <|min(SUM(local_taxes, real_estate_taxes, property_taxes), Fswitch((maried filing separately, 5000), 10000))|>
        , itemizing
    )

Cell(other_taxes, 6,
        Other taxes,
        , u itemizing
    )
Cell(total_taxes_deducted, 7,
        Total taxes paid to be deducted,
        <|min(10000, SUM(salt_capped, other_taxes))|>,
        itemizing
    )
adiv3=cell('>>>>>>>>>>>> Interest you paid                        ', 7.9, '0'),
Cell(reported_mort_interest, 8,
        Home mortgage interest/points reported on Form 1099,
        , u itemizing mort
    )
Cell(unreported_mort_interest, 8.1,
        Home mortgage interest not reported on Form 1098,
        , u itemizing mort
    )
Cell(unreported_mort_points, 8.2,
        Home mortgage points not reported on Form 1098,
        , u itemizing mort
    )
Cell(investment_interest, 9,
        Investment interest,
        , u itemizing
    )
Cell(total_interest_deduction, 10,
        Total interest to deduct,
        <|SUM(reported_mort_interest, unreported_mort_interest, unreported_mort_points, investment_interest)|>,
        itemizing
    )

adiv4=cell('>>>>>>>>>>>> Gifts to charity                         ', 10.9, '0'),
Cell(charity_cash, 11,
        Gifts to charity by cash or check,
        , u itemizing
    )
Cell(charity_noncash, 12,
        Gifts to charity other than by cash or check,
        , u itemizing
    )

Cell(charity_carryover, 13,
        <|Gifts to charity, carryover from prior year|>,
        , u itemizing
    )
Cell(charity_total, 14,
       <|Gifts to charity, total|>,
       <|SUM(charity_cash, charity_noncash, charity_carryover)|>,
       itemizing
    )

adiv5=cell('>>>>>>>>>>>> Casualty and theft losses                ', 14.9, '0'),
Cell(casualty_or_theft_losses, 15,
        Casualty and Theft Losses,
        , u itemizing
    )

adiv6=cell('>>>>>>>>>>>> Job expenses, &c                         ', 20.9, '0'),
Cell(employee_expenses, 16.1,
        <|Unreimbursed employee expenses—job travel, union dues, job education, etc.|>,
        , u itemizing
    )
Cell(tax_prep_fees, 16.2,
        Tax prep fees,
        , u itemizing
    )
Cell(other_work_expenses, 16.3,
        <|Other expenses—investment, safe deposit box, etc.|>,
        , u itemizing
    )

Cell(expenses_minus_agi_slice, 16.4,
        Expenses minus fraction of AGI,
        <|max(SUM(employee_expenses, tax_prep_fees, other_work_expenses) - (CV(f1040, AGI)* 0.02), 0)|>,
        itemizing
    )

Cell(other_deductions, 16.5,
        Other deductions,
        , u itemizing
    )

adiv8=cell('>>>>>>>>>>>> Total                                    ', 28.9, '0'),
Cell(total_itemized_deductions, 29,
        Total itemized deductions,
        <|SUM(excess_medical, total_taxes_deducted, total_interest_deduction, charity_total, casualty_or_theft_losses, expenses_minus_agi_slice, other_deductions)|>,
        itemizing
    )
