jsversion(<|
//2017 tax rate schedules
//Could be inlined, but not going to bother.
// https://www.irs.gov/pub/irs-prior/f1040es--2017.pdf
var tax_table = function (inval){
    var filing_status = fstatus();
    if (filing_status == "single") {
        if (inval < 9525) return inval * 0.1;
        if (inval < 38700) return    952.50 + 0.12 * (inval - 9525);
        if (inval < 82500) return   4453.50 + 0.22 * (inval - 38700);
        if (inval < 157500) return 14089.50 + 0.24 * (inval - 82500);
        if (inval < 200000) return 32089.50 + 0.32 * (inval - 157500);
        if (inval < 500000) return 45689.50 + 0.35 * (inval - 200000);
        return 150689.50 + 0.37 * (inval - 500000);
    } else if (filing_status == "married filing jointly") {
        if (inval < 19050) return inval * 0.1;
        if (inval < 77400) return 1905 + 0.12 * (inval - 19050);
        if (inval < 165000) return 8907 + 0.22 * (inval - 77400);
        if (fnval < 315000) return 28179 + 0.24 * (inval - 165000);
        if (inval < 400000) return 64179 + 0.32 * (inval - 315000);
        if (inval < 600000) return 91379 + 0.35 * (inval - 400000);
        return 161379 + 0.37 * (inval - 600000);
    } else if (filing_status == "married") {
        if (inval < 9525) return inval * 0.1;
        if (inval < 38700) return 952.50 + 0.12 * (inval - 9525);
        if (inval < 82500) return 4453.50 + 0.22 * (inval - 38700);
        if (inval < 157500) return 14089.50 + 0.24 * (inval - 82500);
        if (inval < 200000) return 32089.50 + 0.32 * (inval - 157500);
        if (inval < 300000) return 45689.50 + 0.35 * (inval - 200000);
        return 80689.50 + 0.37 * (inval - 300000);
    } else if (filing_status == "head of household") {
        if (inval < 13600) return inval * 0.1;
        if (inval < 51800) return 1360 + 0.12 * (inval - 13600);
        if (inval < 82500) return 5944 + 0.22 * (inval - 51800);
        if (inval < 157500) return 12698 + 0.24 * (inval - 82500);
        if (inval < 200000) return 30698 + 0.32 * (inval - 157500);
        if (inval < 500000) return 44298 + 0.35 * (inval - 200000);
        return 149298 + 0.37 * (inval - 500000);
    }
}

//The tax tables break income into $50 ranges, then uses the midpoint.
var tax_calc = function (inval){
    if (inval >=100000) return tax_table(inval)
    return tax_table(Math.round(inval/50)*50 + 25)
}

var eitc = function(income, k){
    if (fstatus()=="married") return 0
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    //See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    //phase-in rate, plateu start, plateu value, plateu end, phase-out rate, zero point
    data=[[7.65, 6670, 510, 8340, 7.65, 15010],
          [34, 10000, 3400,  18340, 15.98, 39617],
          [40, 14040, 5616, 18340, 21.06, 45007],
          [45, 14040, 6318, 18340, 21.06, 48340]];
     row = Math.min(kids,3);
    //if (income < 0) print("Negative income! (%s) Please fix." % (income,))
    if (income >= data[row][5]) return 0;
    if (income >= data[row][3]) return income*data[row][4]/100.;
    if (income <= data[row][1]) return income*data[row][0]/100.;
    return data[row][2];
}

var fstatus = function(){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    var deps = parseFloat(document.getElementById("nonkid_dependents").value)
    if (isNaN(deps)) deps = 0;
    var single = document.getElementsByName("spouse")[0].checked;
    if (single && kids+deps) return "head of household";
    if (single && !(kids+deps)) return "single";
    if (document.getElementsByName("spouse")[1].checked) return "married filing jointly";
    else return "married";
}

var max = function(a,b) { return Math.max(a,b)}
var min = function(a,b) { return Math.min(a,b)}
var Floor = function(a) { return Math.floor(a)}
var Ceil = function(a) { return Math.ceil(a)}

var exemption_fn = function(){
    var ct = 1
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    var deps = parseFloat(document.getElementById("nonkid_dependents").value)
    if (isNaN(deps)) deps = 0;
    ct += kids + deps
    var status = fstatus()
    if (status=="married" || status == "married filing jointly") ct += 1
    return ct;
}

//CTC
var thousandkids = function(){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    return kids*1000
}

var ctc_status = function(agi){
    var ded=0;
    var status = fstatus();
    if (status=="head of household" || status=="single") ded=75000;
    else if (status=="married filing jointly") ded=110000;
    else if (status=="married") ded=55000;
    diff = max(agi-ded, 0)
    return Math.ceil(diff/1000.)*1000*0.05
}


|>)

pyversion(<|
#in python at the moment, situations are just plain booleans
def Situation(x):
    return x

def fstatus():
    return status

#tax rate schedules---a reformat from the JS version above.
def tax_table(inval):
    filing_status = fstatus()
    if filing_status == "single":
        if inval < 9525: return inval * 0.1
        if inval < 38700: return    952.50 + 0.12 * (inval - 9525)
        if inval < 82500: return   4453.50 + 0.22 * (inval - 38700)
        if inval < 157500: return 14089.50 + 0.24 * (inval - 82500)
        if inval < 200000: return 32089.50 + 0.32 * (inval - 157500)
        if inval < 500000: return 45689.50 + 0.35 * (inval - 200000)
        return 150689.50 + 0.37 * (inval - 500000)
    if filing_status == "married filing jointly":
        if inval < 19050: return inval * 0.1
        if inval < 77400: return 1905 + 0.12 * (inval - 19050)
        if inval < 165000: return 8907 + 0.22 * (inval - 77400)
        if fnval < 315000: return 28179 + 0.24 * (inval - 165000)
        if inval < 400000: return 64179 + 0.32 * (inval - 315000)
        if inval < 600000: return 91379 + 0.35 * (inval - 400000)
        return 161379 + 0.37 * (inval - 600000)
    if filing_status == "married":
        if inval < 9525: return inval * 0.1
        if inval < 38700: return 952.50 + 0.12 * (inval - 9525)
        if inval < 82500: return 4453.50 + 0.22 * (inval - 38700)
        if inval < 157500: return 14089.50 + 0.24 * (inval - 82500)
        if inval < 200000: return 32089.50 + 0.32 * (inval - 157500)
        if inval < 300000: return 45689.50 + 0.35 * (inval - 200000)
        return 80689.50 + 0.37 * (inval - 300000)
    if filing_status == "head of household":
        if inval < 13600: return inval * 0.1
        if inval < 51800: return 1360 + 0.12 * (inval - 13600)
        if inval < 82500: return 5944 + 0.22 * (inval - 51800)
        if inval < 157500: return 12698 + 0.24 * (inval - 82500)
        if inval < 200000: return 30698 + 0.32 * (inval - 157500)
        if inval < 500000: return 44298 + 0.35 * (inval - 200000)
        return 149298 + 0.37 * (inval - 500000)

# The tax tables break income into $50 ranges, then uses the midpoint.
def tax_calc(inval):
    if inval >=100000: return tax_table(inval)
    return tax_table(round(inval/50)*50 + 25)

def eitc(income, kids):
    #See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    #phase-in rate, plateu start, plateu value, plateu end, phase-out rate, zero point
    data=[[7.65, 6670, 510, 8340, 7.65, 15010],
          [34, 10000, 3400,  18340, 15.98, 39617],
          [40, 14040, 5616, 18340, 21.06, 45007],
          [45, 14040, 6318, 18340, 21.06, 48340]]
    row=kids if kids <=3 else 3
    if income < 0: print("Negative income! (%s) Please fix." % (income,))
    if income >= data[row][5]: return 0
    if income >= data[row][3]: return income*data[row][4]/100.
    if income <= data[row][1]: return income*data[row][0]/100.
    return data[row][2]

def exemption_fn():
    status = fstatus()
    spouse = 1 if (status=="married" or status == "married filing jointly") else 0
    return 1 + kids + dependents + spouse

# CTC
def thousandkids():
    return kids*1000

def Floor(x):
    return int(x)

from math import ceil
def Ceil(x):
    return ceil(x)

def ctc_status(agi):
    ded=0;
    status = fstatus();
    if (status=="head of household" or status=="single"): ded=75000
    elif (status=="married filing jointly"): ded=110000
    elif (status=="married"): ded=55000
    diff = max(agi-ded, 0)
    return ceil(diff/1000.)*1000*0.05
|>)

m4_form(f1040sch1)
    Cell(taxable_tax_refunds, 10,Taxable state/local income tax refunds/credits/offsets,<|CV(f1040_tax_refund_ws, taxable_refund)|>)
    Cell(alimony, 11,Alimony income received,, u)
    Cell(sched_c, 12,Schedule C business income (UI),, u)
    Cell(cap_gains, 13,Capital gains,, u)
    Cell(rr_income,17,Rents and royalties from Schedule E,<|CV(f1040_sched_e,rr_income)|>,have_rr)
    Cell(farm_income, 18,Farm income from Schedule F (UI),, u)
    Cell(unemployment, 19,Unemployment compensation,, u)
    Cell(other_in, 21,Other income.,, u)
    Cell(sch1_magi_subtotal, 22, Schedule 1 subtotal, <|SUM(taxable_tax_refunds, alimony, sched_c, cap_gains, farm_income, unemployment, other_in)|>)


Cell(subtractions_divider, 22.9, >>>>>>>>>>>> Subtractions                                   , 0)
#23 Educator expenses . . . . . . . . . . . 23
#24 Certain business expenses of reservists, performing artists, and fee-basis government officials. Attach Form 2106 or 2106-EZ 24
#25 Health savings account deduction. Attach Form 8889 . 25
#26 Moving expenses, Form 3903 . . . . . . 26
#27 Deductible part of self-employment tax from Schedule SE . 27
#28 Self-employed SEP, SIMPLE, and qualified plans . . 28
#29 Self-employed health insurance deduction . . . . 29
#30 Penalty on early withdrawal of savings . . . . . . 30
#31a Alimony paid
#32 IRA deduction . . . . . . . . . . . . . 32
Cell(ira_deduction, 32, IRA deduction, ,u)
Cell(student_loan_interest_ded, 33, Student loan interest deduction , <|CV(student_loan_ws_1040, final_credit)|>, s_loans)
#tuition and fees subtraction, DPAD eliminated in 2017

Cell(subtractions_from_income, 36,Sum of subtractions from gross income (UI), <|SUM(ira_deduction, student_loan_interest_ded)|>)

m4_form(f1040)

Cell(income_divider, 6.9, >>>>>>>>>>>> Income                                   , 0)
Cell(wages,1,<|Wages, salaries, tips, from form W-2|>,  , u)
Cell(interest, 2.5,Taxable interest,  , u)
Cell(dividends, 3.5,Ordinary dividends,, u)
Cell(iras_pensions, 4.5,Taxable IRA distributions,, u)
Cell(taxable_ss_benefits, 20.5,Taxable social security benefits,, u over_65 spouse_over_65)

Cell(MAGI, 0,Total income for MAGI (PI), <|CV(f1040sch1, sch1_magi_subtotal) + SUM(wages, interest, dividends, iras_pensions, taxable_ss_benefits)|>)
Cell(total_in, 22,Total income, <|CV(MAGI) + CV(f1040sch1, rr_income)|>)


Cell(agi_divider,22.9, >>>>>>>>>>>> AGI                                   , 0)

Cell(t_and_i_divider, 36.9,>>>>>>>>>>>> Taxes and income                      , 0)

Cell(AGI, 7,Adjusted gross income, <|CV(total_in) - CV(f1040sch1, subtractions_from_income)|>, critical)

Cell(std_deduction,8,Standard deductions, <|Fswitch((married, 12000), (single, 12000), (married filing jointly, 24000), (head of household, 18000), 0)|>, )
Cell(deductions,8,Deductions, <|max(CV(std_deduction), CV(f1040_sched_a, total_itemized_deductions))|>, critical)

Cell(qbi, 9, Qualified business income, , u)
Cell(agi_minus_deductions, 41,AGI minus deductions, <|CV(AGI) - CV(deductions) - CV(qbi)|>)

Cell(taxable_income, 43,Taxable income, <|max(CV(agi_minus_deductions), 0)|>, critical)

Cell(tax, 44,Tax, <|tax_calc(CV(taxable_income))|>, critical)
Cell(amt_1040,45, Alternative minimum tax from Form 6251, <|CV(f6251, amt)|>)
Cell(credit_repayment, 46, Excess advance premium tax credit repayment. (UI), 0, u)
Cell(pretotal_tax, 47,Tax + AMT + F8962, <|SUM(tax, amt_1040, credit_repayment)|>)
Cell(ftc,48, Foreign tax credit, , u)
#49 Credit for child and dependent care expenses. Attach Form 2441 49
#50 Education credits from Form 8863, line 19 . . . . . 50
#51 Retirement savings contributions credit. Attach Form 8880 51
#52 Child tax credit. Attach Schedule 8812, if required . . . 52
#53 Residential energy credits. Attach Form 5695 . . . . 53
#54 Other credits from Form: a 3800 b 8801 c 54
Cell(total_credits, 55,Total credits, CV(ftc)) #Still using FTC as a stand-in for the whole list
Cell(tax_minus_credits, 56,Tax minus credits, <|max(CV(pretotal_tax)-CV(total_credits) -CV(ctc_ws_1040, ctc), 0)|>, critical)

#57 Self-employment tax. Attach Schedule SE 
#58 Unreported social security and Medicare tax from Form: a 4137 b 8919
#59 Additional tax on IRAs, other qualified retirement plans, etc. Attach Form 5329 if required
#60 a Household employment taxes from Schedule H
#b First-time homebuyer credit repayment. Attach Form 5405 if required

Cell(aca_fee, 61,Health care individual responsibility,, u)

#62 Taxes from: a Form 8959 b Form 8960 c Instructions; enter code(s) 62
Cell(total_tax, 63,Total tax, <|SUM(tax_minus_credits, aca_fee)|>)
Cell(federal_tax_withheld, 65,Federal income tax withheld from Forms W-2 and 1099,, u)

Cell(payments_divider, 63.9,>>>>>>>>>>>> Payments                              , 0)
#65 2017 estimated tax payments and amount applied from 2015 return 65
Cell(eitc, 66.5,Earned income credit (EIC), <|eitc(CV(AGI), kids)|>)
#b Nontaxable combat pay election 66b
#67 Additional child tax credit. Attach Schedule 8812 . . . . . 67
#68 American opportunity credit from Form 8863, line 8 . . . 68
#69 Net premium tax credit. Attach Form 8962 . . . . . . 69
#70 Amount paid with request for extension to file . . . . . 70
#71 Excess social security and tier 1 RRTA tax withheld . . . . 71
#72 Credit for federal tax on fuels. Attach Form 4136 . . . . 72
#73 Credits from Form: a 2439 b Reserved c 8885 d 73
Cell(total_payments, 74,Total payments, <|SUM(federal_tax_withheld, eitc)|>)
Cell(refund, 75,Refund!, <|max(CV(total_payments)-CV(total_tax), 0)|>, critical)
Cell(tax_owed, 78,Tax owed, <|max(CV(total_tax)-CV(total_payments), 0)|>, critical)

m4_form(student_loan_ws_1040)
Cell(student_loan_interest, 1,Interest you paid in 2017 on qualified student loans,, u s_loans)

Then the complicated phase-out calculation
lines 2-4 are modified AGI before this point on the forms. With lines 23-32 unimplemented here,
line 4 is therefore == line 2 == 1040 line 22 == Cv(f1040, total_in)
Cell(loans_maxed, 1.1, <|Student loan interest, maxed at $2,500|>, <|min(CV(student_loan_interest), 2500)|>, s_loans)

Cell(phase_out_pct, 6, total income minus phase-out limit, <|min(1, max(CV(f1040, total_in) - Fswitch((married, 135000), 65000), 0)/Fswitch((married, 30000), 15000))|>, s_loans)

Cell(phased_out_loans, 8, phased-out loans, <|CV(loans_maxed)*CV(phase_out_pct)|>, s_loans)
Cell(final_credit, 9, Student loan interest credit, <|max(CV(loans_maxed) - CV(phased_out_loans), 0)|>, s_loans)

m4_form(ctc_ws_1040)
Cell(a_thousand_per_child, 1, <|$1,000 per child under 17|>, <|thousandkids()|>, have_kids)
Cell(ctc_subtraction, 5, <|5% of the rounded-up difference between AGI and a filing-status dependent number|>, <|ctc_status(CV(f1040, AGI))|>, have_kids)
Cell(credit_remaining, 6, <|$1,000 per child minus the subtraction|>, <|max(CV(a_thousand_per_child) - CV(ctc_subtraction), 0)|>, have_kids)

Line 8: Add the amounts from Form 1040, line 48, Form 1040, line 49, Form 1040, line 51, Form 5695, line 30, Form 1040, line 50, Form 8910, line 15, Form 8936, line 23, and Schedule R, line 22
I just use FTC to stand in for all of that.
Cell(tax_minus_some_credits, 9, Calculated tax minus some credits, <|CV(f1040, pretotal_tax) - CV(f1040, ftc)|>, )
Cell(ctc, 10, Child tax credit, <|min(CV(tax_minus_some_credits), CV(credit_remaining))|>, have_kids)


m4_form(f1040_tax_refund_ws)
Cell(last_year_refund, 1, <|Enter the income tax refund from Form(s) 1099­G, up to income taxes on 20145Schedule A|>,, u)
Cell(last_year_itemized_deductions, 1, <|Enter line 29 of your 2015 Schedule A|>,, u)
Cell(almost_std_deduction,3,Last year's standard deduction, <|Fswitch((married, 6300), (single, 6300), (married filing jointly, 12600), (head of household, 9300), 0)|>, )
Cell(srblind,4, <|Senior or blind exemption (blind not implemented)|>,<|(Situation(over_65)+Situation(spouse_over_65)==1)* Fswitch((married, 7600), (single, 7900), (married filing jointly, 13950), (head of household, 10900), 0) + (Situation(over_65)+Situation(spouse_over_65)==2)* Fswitch((married, 8850), (single, 7900), (married filing jointly, 15200), (head of household, 12450), 0)|>)
Cell(taxable_refund, 7, Taxable tax refund, <| min(CV(last_year_refund), max(CV(last_year_itemized_deductions) - (CV(almost_std_deduction)+CV(srblind)), 0))|>, )
