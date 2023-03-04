jsversion(<|
function get_amt_exemption(income){
    var status=fstatus();
    var s_or_hh = (status=="single" || status=="head of household")
    var mfj = (status=="married filing jointly")
    if (s_or_hh && income<539900) return 75900
    if (mfj && income<1079800) return 118100
    if (status=="married" && income < 539900) return 59050

    return 0
    //No longer calculating phase-out
}


function get_tamt(income){
    if (income<=0) return 0
    var status=fstatus();
    return (status=="married")
       ? income * (income <=103050  ? 0.26 : 0.28) - 2061
       : income * (income <=206100 ? 0.26 : 0.28) - 4122
}

function med_expenses(expenses, agi){
    var over_65 = situations[".over_65"] ||situations[".spouse_over_65"]

    if (!over_65) return 0
    return Math.max(Math.min(expenses, 0.025*agi), 0)
}
|>)

pyversion(<|
def get_amt_exemption(income):
    if (status=="single" or status=="head of household") and income < 539900:
        return 75900
    if (status=="married filing jointly") and income < 1079800:
        return 118100
    if (status=="married") and income < 539900:
        return 59050
    print("AMT exemption is partially implemented.")
    return 0

def get_tamt(income):
    if income<=0: return 0
    if status=="married":
        return income * (0.26 if income <=103050  else 0.28) - 2061
    else:
        return income * (0.26 if income <=206100 else 0.28) - 4122

def med_expenses(expenses, agi):
    if (not (over_65 or  spouse_over_65)): return 0
    return max(min(expenses, 0.025*agi), 0)
|>)

m4_form(f6251)
Cell(taxable_income, 1, AGI minus deductions, <|CV(f1040, AGI) - CV(f1040, deductions) - CV(f1040, qbi)|>, itemizing)

Cell(taxes_deducted, 2.05, State/local/other deducted on Schedule A or std deduction, <|IF(CV(f1040_sched_a, total_itemized_deductions)>0, CV(f1040_sched_a, total_taxes_deducted), CV(f1040,std_deduction))|>, itemizing)

Cell(amt_refund_deduction, 2.1, <|Tax refund from Form 1040, line 10 or line 21 (only L10 implemented)|>, <|CV(f1040_tax_refund_ws, taxable_refund)|>, itemizing)
Cell(amt_investment_expense_deduction, 2.15, Investment interest expense (UI), 0, itemizing)
Cell(amt_depletion_deduction, 2.2, Depletion (UI), 0, itemizing),
Cell(nold, 2.25, NOLD (UI), 0, itemizing),
Cell(amt_nold, 2.3, Alt NOLD (UI), 0, itemizing),

Cell(amt_income, 4, <|Alternative minimum taxable income. (PI)|>, <|SUM(taxable_income, taxes_deducted, amt_refund_deduction, amt_investment_expense_deduction, amt_depletion_deduction, nold, amt_nold)|>, itemizing)

    Cell(amt_exemption, 5,
        AMT exemption (phase-out not implemented),
        <|get_amt_exemption(CV(amt_income))|>,
        itemizing
    )
    Cell(amt_in_minus_exemption, 6,
        AMT income minus exemption,
        <|max(0, CV(amt_income)-CV(amt_exemption))|>,
        itemizing
    )
    Cell(amt_preftc, 7,
        Tentative AMT pre-FTC (Simplified),
        <|get_tamt(CV(amt_in_minus_exemption))|>,
        itemizing
    )
    Cell(amt_ftc, 8,
        AMT foreign tax credit (UI), 0, itemizing
    )
    Cell(amt_tentative, 9,
        Tentative AMT,
        <|CV(amt_preftc)-CV(amt_ftc)|>,
        itemizing
    )
    Cell(tax_from_1040, 10,
        Tax from F1040 (and f8978 losses, not implemented),
        <|CV(f1040, tax)+CV(f1040sch2, credit_repayment)-CV(f1040sch3, ftc)|>,
        itemizing
    )
    Cell(amt, 11,
        AMT,
        <|max(CV(amt_tentative) - CV(tax_from_1040), 0)|>,
        itemizing
    )
