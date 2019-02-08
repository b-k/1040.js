m4_form(f1040_sched_a)

adiv1=cell('>>>>>>>>>>>> Medical and Dental                       ', 0.9, '0'),
adiv2=cell('>>>>>>>>>>>> Taxes you paid                           ', 4.9, '0'),
adiv3=cell('>>>>>>>>>>>> Interest you paid                        ', 9.9, '0'),
adiv4=cell('>>>>>>>>>>>> Gifts to charity                         ', 15.9, '0'),
adiv5=cell('>>>>>>>>>>>> Casualty and theft losses                ', 19.9, '0'),
adiv6=cell('>>>>>>>>>>>> Job expenses                             ', 20.9, '0'),
adiv7=cell('>>>>>>>>>>>> Other                                    ', 27.9, '0'),
adiv8=cell('>>>>>>>>>>>> Total                                    ', 28.9, '0'),

Cell(medical_expenses, 1, Medical and dental expenses,, u itemizing)
Ce<||>ll(agi_yet_again, 2, AGI, <|CV(agi_again)|> itemizing)
Cell(agi_scaled, 2, AGI scaled, <|CV(f1040, AGI)* IF(Situation(over_65)+Situation(spouse_over_65), .075, .1)|>, itemizing)
Cell(excess_medical, 4, Medical expenses minus fraction of AGI, <|max(CV(medical_expenses) - CV(agi_scaled), 0)|>, itemizing)
Cell(local_taxes, 5, State/local Income OR general sales tax,, u itemizing)
Cell(real_estate_taxes, 6, Real estate taxes,, u itemizing)
Cell(property_taxes, 7, Personal property taxes,, u itemizing)
Cell(other_taxes, 8, Other taxes,, u itemizing)
Cell(total_taxes_deducted, 9, Total taxes paid to be deducted, <|min(10000, SUM(local_taxes, real_estate_taxes, property_taxes, other_taxes))|>, itemizing)
Cell(reported_mort_interest, 10, Home mortgage interest/points reported on Form 1099,, u itemizing mort)
Cell(unreported_mort_interest, 11, Home mortgage interest not reported on Form 1098,, u itemizing mort)
Cell(unreported_mort_points, 12, Home mortgage points not reported on Form 1098,, u itemizing mort)
Cell(mort_insurance_premiums_in, 13, Mortgage insurance premiums in,, u itemizing mort)
Cell(mort_insurance_limit, 13.1, mort insurance limit, <|IF((CV(f1040,AGI) - Fswitch((married,50000),100000)) < 0, 1, max(0,min(1,1-Ceil((CV(f1040,AGI) - Fswitch((married, 50000), 100000))/1000)/10.)))|>, itemizing mort)
Cell(mort_insurance_premiums, 13.2, Mortgage insurance premiums claimed,<|CV(mort_insurance_premiums_in)*CV(mort_insurance_limit)|>,  itemizing mort)
Cell(investment_interest, 14, Investment interest,, u itemizing)
Cell(total_interest_deduction, 15, Total interest to deduct, <|SUM(reported_mort_interest, unreported_mort_interest, unreported_mort_points, mort_insurance_premiums, investment_interest)|>, itemizing)

Cell(charity_cash, 16, Gifts to charity by cash or check,, u itemizing)
Cell(charity_noncash, 17, Gifts to charity other than by cash or check,, u itemizing)
Cell(charity_carryover, 18, <|Gifts to charity, carryover from prior year|>, , u itemizing)
Cell(charity_total, 19, <|Gifts to charity, total|>, <|SUM(charity_cash, charity_noncash, charity_carryover)|>, itemizing)
Cell(casualty_or_theft_losses, 20, Casualty and Theft Losses,, u itemizing)

Cell(employee_expenses, 21, <|Unreimbursed employee expenses—job travel, union dues, job education, etc.|>,, u itemizing)
Cell(tax_prep_fees, 22, Tax prep fees,, u itemizing)
Cell(other_work_expenses, 23, <|Other expenses—investment, safe deposit box, etc.|>,, u itemizing)

Cell(total_expenses, 24, Total expenses, <|SUM(employee_expenses, tax_prep_fees, other_work_expenses)|>, itemizing)
Ce<||>ll(agi_yet_agaain, 25, AGI, <|CV(agi_again)|>, itemizing)
Ce<||>ll(agi_rescaled, 26, AGI scaled, <|CV(agi_again)* 0.02|>, itemizing)
Cell(expenses_minus_agi_slice, 27, Expenses minus fraction of AGI, <|max(CV(total_expenses) - (CV(f1040, AGI)* 0.02), 0)|>, itemizing)

Cell(other_deductions, 28, Other deductions,, u itemizing)
Cell(total_itemized_deductions, 29, Total itemized deductions (assuming income < $155k), <|SUM(excess_medical, total_taxes_deducted, total_interest_deduction, charity_total, casualty_or_theft_losses, expenses_minus_agi_slice, other_deductions)|>, itemizing)
