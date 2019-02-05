jsversion(<|
function get_amt_exemption(income){
    var status=fstatus();
    var s_or_hh = (status=="single" || status=="head of household")
    var mfj = (status=="married filing jointly")
    if (s_or_hh && income) return 70300
    if (mfj && income) return 109400
    if (status=="married") return 54700

    //No longer calculating phase-out
}


function get_tamt(income){
    if (income<=0) return 0
    var status=fstatus();
    return (status=="married")
       ? income * (income <=95550 ? .26 : .28) - 1911
       : income * (income <=191100? .26 : .28) - 3822;
}

function med_expenses(expenses, agi){
    var over_65 = situations[".over_65"] ||situations[".spouse_over_65"]

    if (!over_65) return 0
    return Math.max(Math.min(expenses, .025*agi), 0)
}
|>)

pyversion(<|
def get_amt_exemption(income):
    if (status=="single" or status=="head of household") and income < 500000:
        return 70300
    if (status=="married filing jointly") and income < 1e6:
        return 109400
    if (status=="married") and income < 500000:
        return 54700
    print("AMT exemption is partially implemented.")
    return 0


def get_tamt(income):
    if income==0: return 0
    if status=="married":
        return income * (.26 if  income <=95550 else .28) - 1911
    else:
        return income * (.26 if  income <=191100 else .28) - 3822

def med_expenses(expenses, agi):
    if (not (over_65 or  spouse_over_65)): return 0
    return max(min(expenses, .025*agi), 0)
|>)

m4_form(f6251)
Cell(agi_minus_ded, 1, AGI minus deductions, <|CV(f1040, agi_minus_deductions)|>, itemizing)

Cell(taxes_deducted, 2.05, State/local/other deducted on Schedule A or std deduction, <|IF(CV(f1040_sched_a, total_itemized_deductions)>0, CV(f1040_sched_a, total_taxes_deducted), CV(f1040,std_deduction))|>, itemizing)

Cell(amt_refund_deduction, 2.1, <|Tax refund from Form 1040, line 10 or line 21 (only L10 implemented)|>, <|CV(f1040sch1, taxable_tax_refunds)|>, itemizing)
Cell(amt_investment_expense_deduction, 2.15, Investment interest expense (UI), 0, itemizing)
Cell(amt_depletion_deduction, 2.2, Depletion (UI), 0, itemizing),
Cell(nold, 2.25, NOLD (UI), 0, itemizing),
Cell(amt_nold, 2.3, Alt NOLD (UI), 0, itemizing),

Cell(amt_income, 4, <|Alternative minimum taxable income. (PI)|>, <|CV(f1040, agi_minus_deductions) + CV(taxes_deducted) + CV(amt_refund_deduction) + CV(amt_investment_expense_deduction) + CV(amt_depletion_deduction) + CV(nold) + CV(amt_nold)|>, itemizing)

Cell(amt_exemption, 5, AMT exemption, <|get_amt_exemption(CV(amt_income))|>, itemizing)
Cell(amt_in_minus_exemption, 6, AMT income minus exemption, <|CV(amt_income)-CV(amt_exemption)|>, itemizing)

Cell(amt_preftc, 7, Tentative AMT pre-FTC (Simplified), <|get_tamt(CV(amt_in_minus_exemption))|>, itemizing)
Cell(amt_ftc, 8, AMT foreign tax credit (UI), 0, itemizing)
Cell(amt_tentative, 9, Tentative AMT, <|CV(amt_preftc)-CV(amt_ftc)|>, itemizing)
Cell(tax_from_1040, 10, Tax from F1040, <|CV(f1040, tax)+CV(f1040sch2, credit_repayment)-CV(f1040, ftc)|>, itemizing)
Cell(amt, 11, AMT, <|max(CV(amt_tentative) - CV(tax_from_1040), 0)|>, itemizing)
