jsversion(<|
function get_amt_exemption(income){
    var status=fstatus();
    var s_or_hh = (status=="single" || status=="head of household")
    var mfj = (status=="married filing jointly")
    if (s_or_hh && income < 119200) return 53600
    if (mfj && income < 158900) return 83400
    if (status=="married" && income < 79450) return 41700

    var base = 83400;
    var subtraction= 79540; //married

    if (s_or_hh) {base=53600; subtraction = 119200}
    if (mfj) {base=41700; subtraction = 158900}

    return max(base - (income - subtraction)/4., 0)

    //didn't do the part about certain children under age 24.
}


function get_tamt(income){
    if (income<=0) return 0
    var status=fstatus();
    return (status=="married")
       ? income * (income <=92700 ? .26 : .28) - 1854
       : income * (income <=185400? .26 : .28) - 3708;
}

function med_expenses(expenses, agi){
    var over_65 = situations[".over_65"] ||situations[".spouse_over_65"]

    if (!over_65) return 0
    return Math.max(Math.min(expenses, .025*agi), 0)
}
|>)

pyversion(<|
def get_amt_exemption(income):
    if (status=="single" or status=="head of household") and income < 119200:
        return 53600
    if (status=="married filing jointly") and income < 158900:
        return 83400
    if (status=="married") and income < 79450:
        return 41700
    print("AMT exemption is partially implemented.")
    return 0


def get_tamt(income):
    if income==0: return 0
    if status=="married":
        return income * (.26 if  income <=92700 else .28) - 1854
    else:
        return income * (.26 if  income <=185400 else .28) - 3708

def med_expenses(expenses, agi):
    if (not (over_65 or  spouse_over_65)): return 0
    return max(min(expenses, .025*agi), 0)
|>)

m4_form(f6251)
amt_div1=cell(0.1, >>>>>>>>>>>>> AMT income           ),
amt_div2=cell(28.9, >>>>>>>>>>>>> AMT                  ),
Ce<||>ll(agi_minus_ded, 1, AGI minus deductions, <|CV(f1040, agi_minus_deductions)|>, itemizing)

Cell(amt_medical, 2, Medical and dental, <|med_expenses(CV(f1040_sched_a, excess_medical), CV(f1040, AGI))|>, itemizing)
Cell(taxes_deducted, 3, Taxes deducted on Schedule A, <|CV(f1040_sched_a, total_taxes_deducted)|>, itemizing)

mort_interest_adjustment=cell(4, <|home mortgage interest adjustment, if any, from line 6 of the worksheet in the instructions for this line 4 (UI)|>, '0'),

Cell(misc_deductions, 5, Miscellaneous deductions from Schedule A, <|CV(f1040_sched_a, expenses_minus_agi_slice)|>, itemizing)
amt_deduction_deduction=cell(6, <|Reduction for limited deductions (UI)|>, 0)
Cell(amt_refund_deduction, 7, <|Tax refund from Form 1040, line 10 or line 21 (only L10 implemented)|>, <|CV(f1040sch1, taxable_tax_refunds)|>, itemizing)
Cell(amt_investment_expense_deduction, 8, Investment interest expense (UI), 0, itemizing)
Cell(amt_depletion_deduction, 9, Depletion (UI), 0, itemizing),
Cell(nold, 10, NOLD (UI), 0, itemizing),
Cell(amt_nold, 11, Alt NOLD (UI), 0, itemizing),
## Got bored. All of these will not be implemented

# 12 Interest from specified private activity bonds exempt from the regular tax . . . . . . . . . . 12
# 13 Qualified small business stock, see instructions . . . . . . . . . . . . . . . . . . . 13
# 14 Exercise of incentive stock options (excess of AMT income over regular tax income) . . . . . . . . 14
# 15 Estates and trusts (amount from Schedule K-1 (Form 1041), box 12, code A) . . . . . . . . . 15
# 16 Electing large partnerships (amount from Schedule K-1 (Form 1065-B), box 6) . . . . . . . . . 16
# 17 Disposition of property (difference between AMT and regular tax gain or loss) . . . . . . . . . 17
# 18 Depreciation on assets placed in service after 1986 (difference between regular tax and AMT) . . . . 18
# 19 Passive activities (difference between AMT and regular tax income or loss) . . . . . . . . . . 19
# 20 Loss limitations (difference between AMT and regular tax income or loss) . . . . . . . . . . . 20
# 21 Circulation costs (difference between regular tax and AMT) . . . . . . . . . . . . . . . 21
# 22 Long-term contracts (difference between AMT and regular tax income) . . . . . . . . . . . 22
# 23 Mining costs (difference between regular tax and AMT) . . . . . . . . . . . . . . . . 23
# 24 Research and experimental costs (difference between regular tax and AMT) . . . . . . . . . . 24
# 25 Income from certain installment sales before January 1, 1987 . . . . . . . . . . . . . . 25 ( )
# 26 Intangible drilling costs preference . . . . . . . . . . . . . . . . . . . . . . . 26
# 27 Other adjustments, including income-based related adjustments . . . . . . . . . . . . . 27

    needs mort_interest_adjustment and amt_deduction_deduction:
Cell(amt_income, 28, <|Alternative minimum taxable income. (PI)|>, <|CV(f1040, agi_minus_deductions) + CV(amt_medical) + CV(taxes_deducted)  + CV(misc_deductions)  + CV(amt_refund_deduction) + CV(amt_investment_expense_deduction) + CV(amt_depletion_deduction) + CV(nold) + CV(amt_nold)|>, itemizing)
Cell(amt_exemption, 29, AMT exemption, <|get_amt_exemption(CV(amt_income))|>, itemizing)
Cell(amt_in_minus_exemption, 30, AMT income minus exemption, <|CV(amt_income)-CV(amt_exemption)|>, itemizing)

#30 Subtract line 29 from line 28. If more than zero, go to line 31. If zero or less, enter -0- here and on lines 31, 33, and 35, and go to line 34 . . . . . . . . . . . . . . . . . . . . . . . . . . 30

Cell(amt_preftc, 31, Tentative AMT pre-FTC (PI), <|get_tamt(CV(amt_in_minus_exemption))|>, itemizing)
Cell(amt_ftc, 32, AMT foreign tax credit (UI), 0, itemizing)
Cell(amt_tentative, 33, Tentative AMT, <|CV(amt_preftc)-CV(amt_ftc)|>, itemizing)
Cell(tax_from_1040, 34, Tax from F1040, <|CV(f1040, tax)+CV(f1040, credit_repayment)-CV(f1040, ftc)|>, itemizing)
Cell(amt, 35, AMT, <|max(CV(amt_tentative) - CV(tax_from_1040), 0)|>, itemizing)
