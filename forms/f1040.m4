jsversion(<|
var exemption_multiplier=4000  //changes annually

//2015 tax rate schedules
//Could be inlined, but not going to bother.
var tax_calc = function (inval){
    var filing_status = fstatus();
    if (filing_status == "single") {
        if (inval < 9225) return inval * 0.1;
        if (inval < 37450) return 922.50 + 0.15 * (inval - 9225);
        if (inval < 90750) return 5156.25 + 0.25 * (inval - 37450);
        if (inval < 189300) return 18481.25 + 0.28 * (inval - 90750);
        if (inval < 411500) return 46075.25 + 0.33 * (inval - 189300);
        if (inval < 413200) return 119401.25 + 0.35 * (inval - 411500);
        return 119996.25 + 0.396 * (inval - 413200);
    } else if (filing_status == "married filing jointly") {
        if (inval < 18450) return inval * 0.1;
        if (inval < 74900) return 1845 + 0.15 * (inval - 18450);
        if (inval < 151200) return 10312.50 + 0.25 * (inval - 74900);
        if (inval < 230450) return 29387.50 + 0.28 * (inval - 151200);
        if (inval < 411500) return 51577.50 + 0.33 * (inval - 230450);
        if (inval < 464850) return 111324 + 0.35 * (inval - 411500);
        return 129996.50 + 0.396 * (inval - 464850);
    } else if (filing_status == "married") {
        if (inval < 9225) return inval * 0.1;
        if (inval < 37450) return 922.50 + 0.15 * (inval - 9225);
        if (inval < 75600) return 5156.25 + 0.25 * (inval - 37450);
        if (inval < 115225) return 14693.75 + 0.28 * (inval - 75600);
        if (inval < 205750) return 25788.75 + 0.33 * (inval - 115225);
        if (inval < 232425) return 55662 + 0.35 * (inval - 205750);
        return 64998.25 + 0.396 * (inval - 232425);
    } else if (filing_status == "head of household") {
        if (inval < 13150) return inval * 0.1;
        if (inval < 50200) return 1315 + 0.15 * (inval - 13150);
        if (inval < 129600) return 6872.50 + 0.25 * (inval - 50200);
        if (inval < 209850) return 26722.50 + 0.28 * (inval - 129600);
        if (inval < 411500) return 49192.50 + 0.33 * (inval - 209850);
        if (inval < 439000) return 115737 + 0.35 * (inval - 411500);
        return 125362 + 0.396 * (inval - 439000);
    }
}

var eitc = function(income, k){
    if (fstatus()=="married") return 0
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    //See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    //phase-in rate, plateu start, plateu value, plateu end, phase-out rate, zero point
    data=[[7.65, 6610, 506, 8270, 7.65, 14880],
          [34, 9920, 3373,  18190, 15.98, 39296],
          [40, 13931, 5572, 18190, 21.06, 44648],
          [45, 13930, 6269, 18190, 21.06, 47955]];
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
exemption_multiplier=4000  #changes annually

#in python at the moment, situations are just plain booleans
def Situation(x):
    return x

def fstatus():
    return status

#2015 tax rate schedules
#Single taxpayers only for now
def tax_calc(inval):
    filing_status = fstatus()
    if filing_status == "single":
        if inval < 9225: return inval * 0.1
        if inval < 37450: return 922.50 + 0.15 * (inval - 9225)
        if inval < 90750: return 5156.25 + 0.25 * (inval - 37450)
        if inval < 189300: return 18481.25 + 0.28 * (inval - 90750)
        if inval < 411500: return 46075.25 + 0.33 * (inval - 189300)
        if inval < 413200: return 119401.25 + 0.35 * (inval - 411500)
        return 119996.25 + 0.396 * (inval - 413200)
    if filing_status == "married filing jointly":
        if inval < 18450: return inval * 0.1
        if inval < 74900: return 1845 + 0.15 * (inval - 18450)
        if inval < 151200: return 10312.50 + 0.25 * (inval - 74900)
        if inval < 230450: return 29387.50 + 0.28 * (inval - 151200)
        if inval < 411500: return 51577.50 + 0.33 * (inval - 230450)
        if inval < 464850: return 111324 + 0.35 * (inval - 411500)
        return 129996.50 + 0.396 * (inval - 464850)
    if filing_status == "married":
        if inval < 9225: return inval * 0.1
        if inval < 37450: return 922.50 + 0.15 * (inval - 9225)
        if inval < 75600: return 5156.25 + 0.25 * (inval - 37450)
        if inval < 115225: return 14693.75 + 0.28 * (inval - 75600)
        if inval < 205750: return 25788.75 + 0.33 * (inval - 115225)
        if inval < 232425: return 55662 + 0.35 * (inval - 205750)
        return 64998.25 + 0.396 * (inval - 232425)
    if filing_status == "head of household":
        if inval < 13150: return inval * 0.1
        if inval < 50200: return 1315 + 0.15 * (inval - 13150)
        if inval < 129600: return 6872.50 + 0.25 * (inval - 50200)
        if inval < 209850: return 26722.50 + 0.28 * (inval - 129600)
        if inval < 411500: return 49192.50 + 0.33 * (inval - 209850)
        if inval < 439000: return 115737 + 0.35 * (inval - 411500)
        return 125362 + 0.396 * (inval - 439000)

def eitc(income, kids):
    #See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    #phase-in rate, plateu start, plateu value, plateu end, phase-out rate, zero point
    data=[[7.65, 6610, 506, 8270, 7.65, 14880],
          [34, 9920, 3373,  18190, 15.98, 39296],
          [40, 13931, 5572, 18190, 21.06, 44648],
          [45, 13930, 6269, 18190, 21.06, 47955]]
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

from math import ceil
def ctc_status(agi):
    ded=0;
    status = fstatus();
    if (status=="head of household" or status=="single"): ded=75000
    elif (status=="married filing jointly"): ded=110000
    elif (status=="married"): ded=55000
    diff = max(agi-ded, 0)
    return ceil(diff/1000.)*1000*0.05
|>)

m4_form(f1040)

Cell(exemptions, 6, Exemptions,exemption_fn(), )
Cell(income_divider, 6.9, >>>>>>>>>>>> Income                                   , 0)
Cell(wages,7,<|Wages, salaries, tips, from form W-2|>,  , u)
Cell(interest, 8,Taxable interest,  , u)
Ce<||>ll(tax_free_interest, 8.5,Tax-exempt interest,  , u)
Cell(dividends, 9,Ordinary dividends,, u)
Cel<||>l(qualified_dividends, 9.5,Qualified dividends,, u)
Cell(taxable_tax_refunds, 10,Taxable state/local income tax refunds/credits/offsets,<|CV(f1040_tax_refund_ws, taxable_refund)|>)
Cell(alimony, 11,Alimony income received,, u)
Cell(sched_c, 12,Schedule C business income (UI),, u)
Cell(cap_gains, 13,Capital gains,, u)
Ce<||>ll(noncap_gains, 14, <|Other gains or (losses), from Form 4797 (UI)|>,,u)
Ce<||>ll(ira_income, 15,IRA distributions,, u)
Cell(taxable_ira_income, 15.5,Taxable IRA distributions,, u)
Ce<||>ll(pension,16,Pensions and annuities,, u over_65  spouse_over_65)
Cell(taxable_pension,16.5,Pensions and annuities,, u over_65 spouse_over_65)
Cell(farm_income, 18,Farm income from Schedule F (UI),, u)
Cell(unemployment, 19,Unemployment compensation,, u)
Ce<||>ll(ss_benefits, 20,Social security benefits,, u over_65 spouse_over_65)
Cell(taxable_ss_benefits, 20.5,Taxable social security benefits,, u over_65 spouse_over_65)
Cell(other_in, 21,Other income.,, u)

Cell(magi_total_in, 0,Total income for MAGI (PI), <|SUM(wages, interest, dividends, taxable_tax_refunds, alimony, sched_c, cap_gains, taxable_ira_income, taxable_pension, farm_income, unemployment, taxable_ss_benefits, other_in)|>)
Cell(total_in, 22,Total income, <|CV(magi_total_in) + CV(f1040_sched_e, rr_income)|>)

Cell(agi_divider,22.9, >>>>>>>>>>>> AGI                                   , 0)

#23 Educator expenses . . . . . . . . . . . 23
#24 Certain business expenses of reservists, performing artists, and
#fee-basis government officials. Attach Form 2106 or 2106-EZ 24
#25 Health savings account deduction. Attach Form 8889 . 25
#26 Moving expenses. Attach Form 3903 . . . . . . 26
#27 Deductible part of self-employment tax. Attach Schedule SE . 27
#28 Self-employed SEP, SIMPLE, and qualified plans . . 28
#29 Self-employed health insurance deduction . . . . 29
#30 Penalty on early withdrawal of savings . . . . . . 30
#31a Alimony paid b Recipient’s SSN ▶ 31a
#32 IRA deduction . . . . . . . . . . . . . 32
Cell(student_loan_interest_ded, 33, Student loan interest deduction , <|CV(student_loan_ws_1040, final_credit)|>, s_loans)
#34 Tuition and fees. Attach Form 8917 . . . . . . . 34
#35 Domestic production activities deduction. Attach Form 8903 35
#36 Add lines 23 through 35 . . . . . . . . . . . . . . . . . . . 36

Ce<||>ll(subtractions_from_income, 36,Sum of subtractions from gross income (UI), 0)

Cell(t_and_i_divider, 36.9,>>>>>>>>>>>> Taxes and income                      , 0)

no student loan deduction in MAGI---otherwise the law has an infinite loop
Cell(MAGI, 0,Modified adjusted gross income, <|CV(magi_total_in)|>, have_rr)
Cell(AGI, 37,Adjusted gross income, <|CV(total_in) - CV(student_loan_interest_ded)|>, critical)

#39 elderly, blind

Cell(std_deduction,39.9,Standard deductions, <|Fswitch((married, 6300), (single, 6300), (married filing jointly, 12600), (head of household, 9250), 0)|>, )
Cell(deductions,40,Deductions, <|max(CV(std_deduction), CV(f1040_sched_a, total_itemized_deductions))|>, critical)
Cell(agi_minus_deductions, 41,AGI minus deductions, <|CV(AGI) - CV(deductions)|>)
Cell(exemption_amount, 42,Exemption amount, <|CV(exemptions)*exemption_multiplier|>)
Cell(taxable_income, 43,Taxable income, <|max(CV(agi_minus_deductions)-CV(exemption_amount), 0)|>, critical)
Cell(tax, 44,Tax, <|tax_calc(CV(taxable_income))|>, critical)
Cell(amt_1040,45, Alternative minimum tax from Form 6251, <|CV(f6251, amt)|>)
Cell(credit_repayment, 46, Excess advance premium tax credit repayment. (UI), 0, u)
Cell(pretotal_tax, 47,Tax + AMT + F8962, <|SUM(tax, amt_1040, credit_repayment)|>)
Cell(ftc,48, Foreign tax credit (UI), 0, have_kids)
#49 Credit for child and dependent care expenses. Attach Form 2441 49
#50 Education credits from Form 8863, line 19 . . . . . 50
#51 Retirement savings contributions credit. Attach Form 8880 51
#52 Child tax credit. Attach Schedule 8812, if required . . . 52
#53 Residential energy credits. Attach Form 5695 . . . . 53
#54 Other credits from Form: a 3800 b 8801 c 54
Cell(total_credits, 55,Total credits, 0)
Cell(tax_minus_credits, 56,Tax minus credits, <|max(CV(pretotal_tax)-CV(total_credits) -CV(ctc_ws_1040, ctc), 0)|>, critical)

#57 Self-employment tax. Attach Schedule SE 
#58 Unreported social security and Medicare tax from Form: a 4137 b 8919
#59 Additional tax on IRAs, other qualified retirement plans, etc. Attach Form 5329 if required
#60 a Household employment taxes from Schedule H
#b First-time homebuyer credit repayment. Attach Form 5405 if required

Cell(obamacare_fee, 61,Health care individual responsibility,, u)

#62 Taxes from: a Form 8959 b Form 8960 c Instructions; enter code(s) 62
Cell(total_tax, 63,Total tax, <|SUM(tax_minus_credits, obamacare_fee)|>)
Cell(federal_tax_withheld, 65,Federal income tax withheld from Forms W-2 and 1099,, u)

Cell(payments_divider, 63.9,>>>>>>>>>>>> Payments                              , 0)
#65 2015 estimated tax payments and amount applied from 2014 return 65
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
Cell(student_loan_interest, 1,Interest you paid in 2015 on qualified student loans,, u s_loans)
Cell(loans_maxed, 1.1, <|Student loan interest, maxed at $2,500|>, <|min(CV(student_loan_interest), 2500)|>, s_loans)
line 3 is a sum of 1040 lines 23--32, all of which are UI
line 4 is therefore == line 2 == 1040 line 22 == Cv(f1040, total_in)

Cell(income_limit, 5, Income phase-out, <|Fswitch((married, 130000), 65000)|>, s_loans)
Cell(diff, 6, total income minus phase-out limit, <|max(CV(f1040, total_in) - CV(income_limit), 0)|>, s_loans)
Cell(diff_divided, 7, <|total income minus phase-out limit/(30,000=married joint or 15,000 otherwise)|>, <|(CV(diff)+0.0)/Fswitch((married, 30000), 15000)|>, s_loans)
Cell(phased_out_loans, 8, phased-out loans, <|CV(loans_maxed)*CV(diff_divided)|>, s_loans)
Cell(final_credit, 9, Student loan interest credit, <|max(CV(loans_maxed) - CV(phased_out_loans), 0)|>, s_loans)

m4_form(ctc_ws_1040)
Cell(a_thousand_per_child, 1, <|$1,000 per child under 17|>, <|thousandkids()|>, have_kids)
Cell(ctc_subtraction, 5, <|5% of the rounded-up difference between AGI and a filing-status dependent number|>, <|ctc_status(CV(f1040, AGI))|>, have_kids)
Cell(credit_remaining, 6, <|$1,000 per child minus the subtraction|>, <|max(CV(a_thousand_per_child) - CV(ctc_subtraction), 0)|>, have_kids)

Line 8: Add the amounts from Form 1040, line 48, Form 1040, line 49, Form 1040, line 51, Form 5695, line 30, Form 1040, line 50, Form 8910, line 15, Form 8936, line 23, and Schedule R, line 22
I just use FTC to stand in for all of that.
Cell(tax_minus_some_credits, 9, Calculated tax minus some credits, <|CV(f1040, pretotal_tax) - CV(f1040, ftc)|>, have_kids)
Cell(ctc, 10, Child tax credit, <|min(CV(tax_minus_some_credits), CV(credit_remaining))|>, have_kids)


m4_form(f1040_tax_refund_ws)
Cell(last_year_refund, 1, <|Enter the income tax refund from Form(s) 1099­G, up to income taxes on 2014 Schedule A|>,, u)
Cell(last_year_itemized_deductions, 1, <|Enter line 29 of your 2014 Schedule A|>,, u)
Cell(almost_std_deduction,3,Last year's standard deduction, <|Fswitch((married, 6200), (single, 6200), (married filing jointly, 12400), (head of household, 9100), 0)|>, )
Cell(srblind,4, Senior or blind exemption,<|(Situation(over_65)+Situation(spouse_over_65))*Fswitch((married, 1200), (single, 1550), (married filing jointly, 1200), (head of household, 1550), 0)|>)
Cell(taxable_refund, 7, Taxable tax refund, <| min(CV(last_year_refund), max(CV(last_year_itemized_deductions) - (CV(almost_std_deduction)+CV(srblind)), 0))|>, )



