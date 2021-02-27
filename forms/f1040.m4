jsversion(<|
//2018 tax rate schedules
//Could be inlined, but not going to bother.
// https://www.irs.gov/pub/irs-prior/f1040es--2020.pdf

var tax_table = function (inval){
    var filing_status = fstatus();
    if (filing_status == "single") {
        cuts=[0, 9875, 40125, 85525, 163300, 207350, 518400, 1e20]
    } else if (filing_status == "married filing jointly") {
        cuts=[0, 19750, 80250, 171050, 326600, 414700, 622050, 1e20]
    } else if (filing_status == "married") {
        cuts=[0, 9875, 40125, 85525, 163300, 207350, 311025, 1e20]
    } else if (filing_status == "head of household") {
        cuts=[0, 14100, 53700, 85500, 163300, 207350, 518400 ,1e20]
    }
    rate=[0.1, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37]
    i=0
    total=0
    while (inval>=cuts[i]){
        total += (min(inval,cuts[i+1]) - cuts[i])*rate[i];
        i++;
    }
    return total;
}

//The tax tables break income into $50 ranges, then uses the midpoint.
var tax_calc = function (inval){
    if (inval==0) return 0;
    if (inval >=100000) return tax_table(inval)
    return tax_table(Math.round(inval/50)*50 + 25)
}


//capital gains tax rate
var cgrate = function(income){
    var filing_status = fstatus();
    if (filing_status == "single") {
        if (income < 38600) return    0;
        if (income < 425800) return   .15;
    } else if (filing_status == "married filing jointly") {
        if (income < 77200) return    0;
        if (income < 479000) return   .15;
    } else if (filing_status == "married") {
        if (income < 38600) return    0;
        if (income < 239500) return   .15;
    } else if (filing_status == "head of household") {
        if (income < 51700) return    0;
        if (income < 452400) return   .15;
    }
    return .2;
}

var eitc = function(income, k){
    if (fstatus()=="married") return 0
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    //See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    //Or, search the internet for the phrase "For taxable years beginning in 20xx, the following
    // amounts are used to determine the earned income credit under § 32(b)."
    //For 2019: https://www.irs.gov/irb/2018-49_IRB
    //For 2020: https://www.irs.gov/irb/2019-47_IRB
    //For 2022: https://www.irs.gov/pub/irs-drop/rp-19-44.pdf
    //plateu start, plateu value, plateu end, zero point, end for married joint, zero for mj
    data=[[7030, 538, 8790, 15820, 14680, 21710],
          [10540, 3584, 19330, 41756, 25220, 47646],
          [14800, 5920, 19330, 47440, 25220, 53330],
          [14800, 6660, 19330, 50954, 25220, 56844]]
     row = Math.min(kids,3);

    plateu_start=0
    plateu_value=1

    if (fstatus()=="married filing jointly"){
        phaseout_start=4;
        phaseout_end=5;
    } else {
        phaseout_start=2;
        phaseout_end=3;
    }
    
    if (income >= data[row][phaseout_end]) return 0;
    if (income >= data[row][phaseout_start])
        return Math.round(100*data[row][plateu_value]*(1-(income-data[row][phaseout_start])
                                            /(data[row][phaseout_end]-data[row][phaseout_start])))/100
    if (income <= data[row][plateu_start])
        return Math.round(income*data[row][plateu_value]/data[row][plateu_start])/100;
    return data[row][plateu_value];
}

var actc = function(limited_unused, scaled_income, ss_med, eitc){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;

    if (kids >=3){
        if (scaled_income==0) return 0;
        else return min(limited_unused, scaled_income);
    }

    //Did you have a lot of soc sec/Medicare withheld, and EITC still isn't covering it?
    //We'll up the credit to cover that if it's more than your scaled income.
    if (limited_unused <= scaled_income)
        return min(limited_unused, scaled_income);
    else
        return min(max(ss_med-eitc, scaled_income), limited_unused);
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
    var deps = parseFloat(document.getElementById("nonkid_dependents").value)
    if (isNaN(deps)) deps = 0;
    return kids*2000 + deps*500
}

var fourteenkids = function(){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    return kids*1400
}

var ctc_status = function(agi){
    var ded=0;
    var status = fstatus();
    if (status=="married filing jointly") ded=400000;
    else ded=200000;
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
        cuts=[0, 9875, 40125, 85525, 163300, 207350, 518400, 1e20]
    if filing_status == "married filing jointly":
        cuts=[0, 19750, 80250, 171050, 326600, 414700, 622050, 1e20]
    if filing_status == "married":
        cuts=[0, 9875, 40125, 85525, 163300, 207350, 311025, 1e20]
    if filing_status == "head of household":
        cuts=[0, 14100, 53700, 85500, 163300, 207350, 518400 ,1e20]

    rate=[0.1, 0.12, 0.22 , 0.24 ,0.32, 0.35, 0.37]
    i=0
    total=0
    while inval>=cuts[i]:
        total = total + (min(inval,cuts[i+1]) - cuts[i])*rate[i]
        i = i+1
    return total

# The tax tables break income into $50 ranges, then uses the midpoint.
def tax_calc(inval):
    if inval == 0: return 0
    if inval >=100000: return tax_table(inval)
    return tax_table(round(inval/50)*50 + 25)

# capital gains tax rate
def cgrate(income):
    filing_status = fstatus()
    if (filing_status == "single"):
        if (income < 38600): return  0
        if (income < 425800): return .15
    if (filing_status == "married filing jointly"):
        if (income < 77200): return    0
        if (income < 479000): return   .15
    if (filing_status == "married"):
        if (income < 38600): return    0
        if (income < 239500): return   .15
    if (filing_status == "head of household"):
        if (income < 51700): return    0
        if (income < 452400): return   .15
    return .2;


def eitc(income, kids):
    #See http://www.taxpolicycenter.org/taxfacts/displayafact.cfm?Docid=36
    #and irs.gov/irb/2018-10_IRB#RP-2018-18
    #plateu start, plateu value, plateu end, zero point, end for married joint, zero for mj
    data=[[6780, 519, 8490, 15270, 14170, 20950],
          [10180, 3461,  18660, 40320, 24350, 46010],
          [14290, 5716, 18660, 45802, 24350, 51492],
          [14290, 6431, 18660, 49194, 24350, 54884]]
    row=kids if kids <=3 else 3

    plateu_start=0
    plateu_value=1

    if status=="married": return 0
    if status=="married filing jointly":
        phaseout_start=4
        phaseout_end=5
    else:
        phaseout_start=2
        phaseout_end=3

    if income < 0: print("Negative income! (%s) Please fix." % (income,))
    if income >= data[row][phaseout_end]: return 0
    if income >= data[row][phaseout_start]:
        return round(100*data[row][plateu_value]*(1-(income-data[row][phaseout_start])
                                            /(data[row][phaseout_end]-data[row][phaseout_start])))/100
    if income <= data[row][plateu_start]:
        return round(income*data[row][plateu_value]/data[row][plateu_start])/100;
    return data[row][plateu_value]

def actc(limited_unused, scaled_income, ss_med, eitc):
    if kids >=3:
        if scaled_income==0:
            return 0
        else:
            return min(limited_unused, scaled_income)

    #Did you have a lot of soc sec/Medicare withheld, and EITC still isn't covering it?
    #We'll up the credit to cover that if it's more than your scaled income.
    if limited_unused <= scaled_income:
        return min(limited_unused, scaled_income)
    else:
        return min(max(ss_med-eitc, scaled_income), limited_unused)


def exemption_fn():
    status = fstatus()
    spouse = 1 if (status=="married" or status == "married filing jointly") else 0
    return 1 + kids + dependents + spouse

# CTC
def thousandkids():
    return kids*2000 + dependents*500

def fourteenkids():
    return kids*1400

def Floor(x):
    return int(x)

from math import ceil
def Ceil(x):
    return ceil(x)

def ctc_status(agi):
    ded=0;
    status = fstatus();
    if (status=="married filing jointly"): ded=400000
    else: ded=200000
    diff = max(agi-ded, 0)
    return ceil(diff/1000.)*1000*0.05
|>)

m4_form(f1040sch1)
    Cell(alimony, 2.1,Alimony income received,, u)
    Cell(sched_c, 3,Schedule C business income,, u)
    Cell(sale_of_biz, 4, <|Sale of business property (f4797)|>,,u)
    Cell(rr_income,5, Rents and royalties from Schedule E,<|CV(f1040_sched_e,rr_income)|>,have_rr)
    Cell(farm_income, 6, Farm income from Schedule F,, u)
    Cell(unemployment, 7, Unemployment compensation,, u)
    Cell(other_in, 8,Other income,, u)
    Cell(sch1_magi_subtotal, 22, Schedule 1 subtotal w/o Rents/Royalties, <|CV(f1040_tax_refund_ws, taxable_refund) + SUM(alimony, sched_c, sale_of_biz, farm_income, unemployment, other_in)|>)

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
Cell(ira_deduction, 19, IRA deduction, ,u)
Cell(student_loan_interest_ded, 20, Student loan interest deduction , <|CV(student_loan_ws_1040, final_credit)|>, s_loans)
Cell(tuition_subtraction, 21, Tuition and fees from f8917, , u)

Cell(subtractions_from_income, 36,Sum of subtractions from gross income (PI), <|SUM(ira_deduction, student_loan_interest_ded, tuition_subtraction)|>)

m4_form(f1040)

Cell(wages,1,<|Wages, salaries, tips, from form W-2|>,  , u)
Cell(interest, 2.5,Taxable interest,  , u)
Cell(qualified_dividends, 3.4,Dividends qualifying for the long-term cap gains rate,, u cap_gains)
Cell(dividends, 3.5, all dividends,, u)
Cell(iras_pensions, 4.5,Taxable IRA distributions,, u)
Cell(taxable_ss_benefits, 5.5,Taxable social security benefits,, u over_65 spouse_over_65)
Cell(capital_gains, 6, <|Capital gains from Schedule D|>,, u cap_gains)

Cell(MAGI, 0,Total income for MAGI (PI), <|CV(f1040sch1, sch1_magi_subtotal) + SUM(wages, interest, dividends, iras_pensions, taxable_ss_benefits,capital_gains)|>)
Cell(total_in, 7,Total income, <|CV(MAGI) + CV(f1040sch1, rr_income)|>)

Cell(AGI, 8,Adjusted gross income, <|max(CV(total_in) - CV(f1040sch1, subtractions_from_income),0)|>, critical)

Cell(std_deduction,9,Standard deductions, <|Fswitch((married filing jointly, 24800), (head of household, 18650), 12400)|>, )
Cell(deductions,9,Deductions, <|max(CV(std_deduction), CV(f1040_sched_a, total_itemized_deductions))|>, critical)

Cell(qbi, 10, 20% discount on qualified business income (f8995), , u)
Cell(taxable_income, 11, Taxable income, <|max(CV(AGI) - CV(deductions) - CV(qbi), 0)|>, critical)

Cell(tax, 12.1,Tax, <|min(tax_calc(CV(taxable_income)), CV(qualified_dividends_ws, total_tax))|>, critical)
Cell(other_taxes, 12.3,<|Sched 2, AMT + F8962|>, <|CV(f1040sch2, amt) + CV(f1040sch2, credit_repayment)|>)
Cell(pretotal_tax, 12.4,<|Tax + Sched 2, AMT + F8962|>, <|CV(tax) + CV(other_taxes)|>)
    
Cell(credits, 13,<|CTC and Schedule 3, other credits|>, <|CV(f1040sch3, nonrefundable_total) + CV(ctc_ws_1040, ctc)|>, critical)

Cell(tax_minus_credits, 14, Tax minus credits, <|max(CV(pretotal_tax)-CV(credits), 0)|>, critical)

Cell(postcredit_taxes, 15, <|Other taxes, incl. self-employment|>, , u)

#62 Taxes from: a Form 8959 b Form 8960 c Instructions; enter code(s) 62
Cell(total_tax, 15, Total tax, <|CV(tax_minus_credits)+CV(postcredit_taxes)|>)

Cell(federal_tax_withheld, 17,Federal income tax withheld from Forms W-2 and 1099,, u)
Cell(eitc, 18.1,Earned income credit (EIC), <|eitc(CV(AGI), kids)|>)
Cell(actc, 18.2, Refundable child tax credit, <|CV(ctc_sch8812, refundable_ctc)|>, kids)
Cell(ed_tc, 18.3, Refundable education credits, <|CV(f8863, refundable_credit)|>, s_loans)
Cell(other_tc, 18.4, <|Other asst credits from Sch 3|>, ,u)

Cell(total_payments, 18,Total payments, <|SUM(federal_tax_withheld, eitc, actc, ed_tc, other_tc)|>)
Cell(refund, 19, Refund, <|max(CV(total_payments)-CV(total_tax), 0)|>, critical)
Cell(tax_owed, 20,Tax owed, <|max(CV(total_tax)-CV(total_payments), 0)|>, critical)

m4_form(f1040sch2)
Cell(amt, 1, Alternative minimum tax, <|CV(f6251,amt)|>, itemizing)
Cell(credit_repayment, 46, Excess advance premium tax credit repayment, , u)

m4_form(f1040sch3)
Cell(ftc, 1, Foreign tax credit, , u)
Cell(dependent_care, 2, Dependent care expenses, , u)
Cell(ed_credits, 3, Education credits via f8863, <|CV(f8863, nonrefundable_credit)|>, s_loans)
Cell(nonrefundable_total, 7, Total nonrefundable credits, <|CV(ftc)+CV(dependent_care)+CV(ed_credits)|>)

m4_form(student_loan_ws_1040)
Cell(student_loan_interest, 1,Interest you paid in 2018 on qualified student loans,, u s_loans)

Then the complicated phase-out calculation
lines 2-4 are modified AGI before this point on the forms. With lines 23-32 unimplemented here,
line 4 is therefore == line 2 == 1040 line 22 == Cv(f1040, total_in)
Cell(loans_maxed, 1.1, <|Student loan interest, maxed at $2,500|>, <|min(CV(student_loan_interest), 2500)|>, s_loans)

Cell(phase_out_pct, 6, total income minus phase-out limit, <|min(1, max(CV(f1040, total_in) - Fswitch((married, 140000), 70000), 0)/Fswitch((married, 30000), 15000))|>, s_loans)

Cell(phased_out_loans, 8, phased-out loans, <|CV(loans_maxed)*CV(phase_out_pct)|>, s_loans)
Cell(final_credit, 9, Student loan interest credit, <|max(CV(loans_maxed) - CV(phased_out_loans), 0)|>, s_loans)

m4_form(ctc_ws_1040)
Cell(two_thousand_per_child, 1, <|$2,000 per child under 17|>, <|thousandkids()|>, kids)
Cell(ctc_subtraction, 5, <|5% of AGI minus a filing-status dependent number|>, <|ctc_status(CV(f1040, AGI))|>, kids)
Cell(credit_remaining, 6, <|$2,000 per child minus the subtraction|>, <|max(CV(two_thousand_per_child) - CV(ctc_subtraction), 0)|>, kids)
Cell(tax_minus_some_credits, 9, Calculated tax minus some credits, <|CV(f1040, tax) - CV(f1040sch3, ed_credits)- CV(f1040sch3, ftc)|>, kids)
Cell(ctc, 10, Child tax credit, <|min(CV(tax_minus_some_credits), CV(credit_remaining))|>, kids)

m4_form(ctc_sch8812)
Cell(unused_ctc, 3, CTC not used, <|max(0, CV(ctc_ws_1040,credit_remaining) - CV(ctc_ws_1040, ctc))|>, kids)
Cell(fourteen_kids, 4, <|$1,400 per kid|>, <|fourteenkids()|>, kids)
Cell(limited_unused, 5, Limited unused CTC, <|min(CV(unused_ctc),CV(fourteen_kids))|>, kids)
Cell(scaled_earned_income, 8, <|15 percent of earned income-2500|>, <|max(0, .15*(CV(f1040, wages)-2500))|>, kids)
Cell(ss_and_medicare_withheld, 11, <|Social security and medicare withheld on W-2 lines 4 and 6|>, , u kids)
Cell(refundable_ctc, 15, Refundable child tax credit, <|actc(CV(limited_unused), CV(scaled_earned_income), CV(ss_and_medicare_withheld), CV(f1040, eitc))|>, kids)


m4_form(f1040_tax_refund_ws)
Cell(last_year_refund, 1, <|Enter the income tax refund from Form(s) 1099­G, up to income taxes on last year's Schedule A|>,, u ly_refund)
Cell(last_year_5d, 1, <|Enter line 29 of your 2017 Schedule A|>,, u ly_refund)
Cell(last_year_limited_deductions, 1.3, <|Enter line 5e of your 2017 Schedule A|>,, u ly_refund)
Cell(last_year_reduced, 2, <|Last year's deductions, maybe reduced|>,<|max(CV(last_year_5d)-CV(last_year_limited_deductions), 0)|>, ly_refund)
Cell(last_year_post_limit, 3, <|Last year's tax deducted, limited|>,<|max(CV(last_year_refund)-CV(last_year_reduced), 0)|>, ly_refund)
Cell(last_year_total_deductions, 4, <|Last year's itemized deductions|>, , u ly_refund)
Cell(almost_std_deduction,5,<|Last year's standard deduction (under your current status)|>, <|Fswitch((married filing jointly, 24400), (head of household, 18350), 12200)|>, ly_refund)
Cell(srblind,6, <|Senior or blind exemption (blind UI; mfj PI)|>,<|((Situation(over_65)==1)+(Situation(spouse_over_65)==1))* Fswitch((married, 1300), (married filing jointly, 1300), 1650)|>, ly_refund)
Cell(itemized_over_std, 6.5, Itemized deduction minus standard for last year, <|max(CV(last_year_total_deductions) - CV(almost_std_deduction) - CV(srblind), 0)|>, ly_refund)
Cell(taxable_refund, 7, Taxable tax refund, <| min(CV(itemized_over_std), CV(last_year_post_limit))|>, ly_refund)



m4_form(qualified_dividends_ws)

Cell(qualified_dividends_and_gains, 4, <|Qualified dividends plus cap gains|>, <|CV(f1040,qualified_dividends)+CV(f1040, capital_gains)|>, cap_gains)
Cell(income_minus_gains, 5, <|Income minus gains|>, <|CV(f1040,taxable_income)-CV(qualified_dividends_and_gains)|>, cap_gains)
Cell(limitation, 6, <|Limitation|>, <|Fswitch((head of household, 53600), (married filing jointly, 80000), 40000)|>, cap_gains)
Cell(limited_income, 7, <|Limited income|>, <|min(CV(f1040,taxable_income), CV(limitation))|>, cap_gains)
Cell(alt_limited_income, 8, <|Limited income again|>, <|min(CV(limited_income), CV(income_minus_gains))|>, cap_gains)
Cell(untaxed, 9, <|Untaxed portion|>, <|CV(limited_income) - CV(alt_limited_income)|>, cap_gains)
Cell(min_ded_or_gains_minus_zero, 12, <|Remove untaxed from income|>, <|min(CV(f1040,taxable_income), CV(income_minus_gains)) - CV(untaxed)|>, cap_gains)
Cell(relimited_qualified, 13, <|qualified gains re-limited|>, <| min(CV(min_ded_or_gains_minus_zero), max( min(Fswitch((single, 441450), (married, 248300), (married filing jointly, 496600), 469050), CV(f1040,taxable_income)) - (CV(income_minus_gains) + CV(untaxed)) , 0))|>, cap_gains)
Cell(fifteen_pct_tax, 18, <|15% tax on qualified gains|>, <|CV(relimited_qualified)*0.15|>, cap_gains)

Cell(income_minus_fifteen, 20, <|Gains minus 15% taxed part|>, <|min(CV(f1040,taxable_income), CV(qualified_dividends_and_gains)) - (CV(untaxed) + CV(relimited_qualified))|>, cap_gains)
Cell(twenty_pct_tax, 21, <|20% tax on dividends and gains|>, <|CV(income_minus_fifteen)*0.20|>, cap_gains)
Cell(nongains_tax, 22, <|Tax on income without qualified gains|>, <|tax_calc(CV(income_minus_gains))|>, cap_gains)
Cell(total_tax, 23, <|Total tax including qualified gains discounts|>, <|SUM(fifteen_pct_tax, twenty_pct_tax, nongains_tax)|>,cap_gains)
