jsversion(<|
//tax rate schedules
//Could be inlined, but not going to bother.
//Buried in i1040gi.pdf, or use https://www.irs.gov/pub/irs-prior/f1040es--2022.pdf

var tax_table = function (inval){
    var filing_status = fstatus();
    if (filing_status == "single") {
        cuts=[0, 10275, 41775, 89075, 170050, 215950, 539900, 1e20]
    } else if (filing_status == "married") {
        cuts=[0, 10275, 41775, 89075, 170050, 215950, 323925, 1e20]
    } else if (filing_status == "married filing jointly") {
        cuts=[0, 20550, 83550, 178150, 340100, 431900, 647850, 1e20]
    } else if (filing_status == "head of household") {
        cuts=[0, 14650, 55900, 89050, 170050, 215950, 539900 ,1e20]
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

var std_ded_fn = function(){
    var over65ct = situations[".over_65"] + situations[".spouse_over_65"];
    if (fstatus() == "single"){
         if (over65ct==0)      return 12950;
         else if (over65ct==1) return 14700;
         else                  return 16450;
    }
    if (fstatus() == "married filing jointly"){
         if (over65ct==0)      return 25900;
         else if (over65ct==1) return 27300;
         else if (over65ct==2) return 28700;
         else if (over65ct==3) return 30100;
         else                  return 31500;
    }
    if (fstatus() == "married"){
         if (over65ct==0)      return 12950;
         else if (over65ct==1) return 14350;
         else if (over65ct==2) return 15750;
         else if (over65ct==3) return 17150;
         else                  return 18550;
    }
    if (fstatus() == "head of household"){
         if (over65ct==0)      return 19400;
         else if (over65ct==1) return 21150;
         else                  return 22900;
    }
}

var eitc = function(income, k){
    if (fstatus()=="married") return 0
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    //Or, search the internet for the phrase "For taxable years beginning in 20xx, the following
    // amounts are used to determine the earned income credit under § 32(b)."
    //For 2019: https://www.irs.gov/irb/2018-49_IRB
    //For 2020: https://www.irs.gov/irb/2019-47_IRB
    //For 2021: https://www.irs.gov/pub/irs-drop/rp-19-44.pdf
    //For 2022: https://www.taxpolicycenter.org/statistics/eitc-parameters
    //plateu start, plateu value, plateu end, zero point, end for married joint, zero for mj
    mfj_add=6130 //See TPC footnote.
    data=[[7320, 560, 9160, 16480,    9160+mfj_add,  16480+mfj_add],
          [10980, 3733, 20130, 43492, 20130+mfj_add, 43492+mfj_add],
          [15410, 6164, 20130, 49399, 20130+mfj_add, 49399+mfj_add],
          [15410, 6935, 20130, 53057, 20130+mfj_add, 53057+mfj_add]]
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

var actc = function(limited_unused, scaled_income, ss_med, eitc){ //ss_med now also include self-employment tax
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

var fifteenkids = function(){
    var kids = parseFloat(document.getElementById("kids").value)
    if (isNaN(kids)) kids = 0;
    return kids*1500
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
        cuts=[0, 10275, 41775, 89075, 170050, 215950, 539900, 1e20]
    if filing_status == "married":
        cuts=[0, 10275, 41775, 89075, 170050, 215950, 323925, 1e20]
    if filing_status == "married filing jointly":
        cuts=[0, 20550, 83550, 178150, 340100, 431900, 647850, 1e20]
    if filing_status == "head of household":
        cuts=[0, 14650, 55900, 89050, 170050, 215950, 539900 ,1e20]

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

def std_ded_fn():
    over65ct = Situation(over_65) + Situation(spouse_over_65)
    if fstatus() == "single":
         if (over65ct==0): return 12950;
         if (over65ct==1): return 14700;
         return 16450;


    if fstatus() == "married filing jointly":
         if (over65ct==0): return 25900
         if (over65ct==1): return 27300
         if (over65ct==2): return 28700
         if (over65ct==3): return 30100
         return 31500

    if fstatus() == "married":
         if (over65ct==0): return 12950
         if (over65ct==1): return 14350
         if (over65ct==2): return 15750
         if (over65ct==3): return 17150
         return 18550

    if fstatus() == "head of household":
         if (over65ct==0): return 19400
         if (over65ct==1): return 21150
         return 22900

def eitc(income, kids):
    #See https://www.taxpolicycenter.org/statistics/eitc-parameters
    #plateu start, plateu value, plateu end, zero point, end for married joint, zero for mj
    mfj_add=6130
    data=[[7320, 560, 9160, 16480,    9160+mfj_add,  16480+mfj_add],
          [10980, 3733, 20130, 43492, 20130+mfj_add, 43492+mfj_add],
          [15410, 6164, 20130, 49399, 20130+mfj_add, 49399+mfj_add],
          [15410, 6935, 20130, 53057, 20130+mfj_add, 53057+mfj_add]]
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

def fifteenkids():
    return kids*1500

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
    Cell(state_tax_refunds, 1,
        Taxable state refunds,, u
    )
    Cell(alimony, 2.1,
        alimony income received,, u
    )
    Cell(sched_c, 3,
        Schedule C business income,, u
    )
    Cell(sale_of_biz, 4,
        <|Sale of business property (f4797)|>,,u
    )
    Cell(rr_income,5,
        Rents and royalties from Schedule E,
        <|CV(f1040_sched_e,rr_income)|>,
        have_rr
    )
    Cell(farm_income, 6,
        Farm income from Schedule F,, u
    )
    Cell(unemployment, 7,
        Unemployment compensation,, u
    )
    Cell(other_in, 8,
        other income (see Sch 1 for the list), , u
    )
    Cell(sch1_magi_subtotal, 9,
        Schedule 1 subtotal w/o Rents/Royalties,
        <|CV(f1040_tax_refund_ws, taxable_refund) +
          SUM(state_tax_refunds, alimony, sched_c, sale_of_biz,
              farm_income, unemployment, other_in)|>
    )

    Cell(subtractions_divider, 22.9, >>>>>>>>>>>> Subtractions                                   , 0)
    #23 Educator expenses . . . . . . . . . . . 23
    #24 Certain business expenses of reservists, performing artists, and fee-basis government officials. Attach Form 2106 or 2106-EZ 24
    #26 Moving expenses, Form 3903 . . . . . . 26
    #28 Self-employed SEP, SIMPLE, and qualified plans . . 28
    #29 Self-employed health insurance deduction . . . . 29
    #30 Penalty on early withdrawal of savings . . . . . . 30
    #31a Alimony paid
    Cell(hsa_deduction, 13,
        Health Savings Account deduction, , u
    )
    Cell(self_employment_deductible, 15,
        <|Deductible part of self-employment tax (Sch SE)|>, , u
    )
    Cell(ira_deduction, 20,
        IRA deduction, , u
    )
    Cell(student_loan_interest_ded, 21,
        Student loan interest deduction,
        <|CV(student_loan_ws_1040, final_credit)|>,
        s_loans
    )
    Cell(other_adjustments, 25,
        All other adjustments anywhere on Sch2 part II, , u
    )
    Cell(subtractions_from_income_wo_student_loans, 26.1,
        Adjustments excluding student loans,
        <|SUM(hsa_deduction, self_employment_deductible, ira_deduction, other_adjustments)|>
    )
    Cell(subtractions_from_income, 26,
        Sum of adjustments to income,
        <|SUM(hsa_deduction, ira_deduction, student_loan_interest_ded, other_adjustments)|>
    )

m4_form(f1040)

Cell(wages, 1, <|Wages, salaries, tips, etc. primarily from form W-2|>,  , u)
Cell(interest, 2.5, Taxable interest,  , u)
Cell(qualified_dividends, 3.4,Dividends qualifying for the long-term cap gains rate,, u cap_gains)
Cell(dividends, 3.5, all dividends,, u)
Cell(iras, 4.5, Taxable IRA distributions,, u)
Cell(pensions, 5.5, Taxable pension distributions,, u)
Cell(taxable_ss_benefits, 6.5,Taxable social security benefits,, u over_65 spouse_over_65)
Cell(capital_gains, 7, <|Capital gains from Schedule D|>,, u cap_gains)

Cell(MAGI, 0, Total income for MAGI (PI), <|CV(f1040sch1, sch1_magi_subtotal) + SUM(wages, interest, dividends, iras, pensions, taxable_ss_benefits,capital_gains)|>)
Cell(total_in, 9, Total income, <|CV(MAGI) + CV(f1040sch1, rr_income)|>)

    Cell(AGI, 11,
        Adjusted gross income,
        <|max(CV(total_in) - CV(f1040sch1, subtractions_from_income),0)|>,
        critical
    )
    Cell(std_deduction, 12,
        Standard deductions,
        <|std_ded_fn()|>,
        critical
    )
Cell(deductions, 12, Deductions, <|max(CV(std_deduction), CV(f1040_sched_a, total_itemized_deductions))|>, critical)

Cell(qbi, 13, 20% discount on qualified business income (f8995), , u)
Cell(taxable_income, 15, Taxable income, <|max(CV(AGI) - CV(deductions) - CV(qbi), 0)|>, critical)

Cell(tax, 16.1, Tax, <|min(tax_calc(CV(taxable_income)), CV(qualified_dividends_ws, total_tax))|>, critical)
Cell(other_taxes, 16.3, <|Sched 2, AMT + F8962|>, <|CV(f1040sch2, amt) + CV(f1040sch2, credit_repayment)|>)
Cell(pretotal_tax, 16.4, <|Tax + Sched 2, AMT + F8962|>, <|CV(tax) + CV(other_taxes)|>)
    
    Cell(tax_plus_amt_and_repayment, 18,
        <|Tax plus Sch2|>,
        <|CV(pretotal_tax)+CV(f1040sch2, sch2_total)|>
    )
    Cell(credits, 19,
        <|CTC and Schedule 3, other credits|>,
        <|CV(f1040sch3, nonrefundable_total) + CV(ctc_sch8812_I, ctc)|>,
        critical
    )
    Cell(tax_minus_credits, 22,
        Tax minus credits,
        <|max(CV(tax_plus_amt_and_repayment)-CV(credits), 0)|>,
        critical
    )

Cell(postcredit_taxes, 23, <|Other taxes, incl. self-employment|>, , u)

#62 Taxes from: a Form 8959 b Form 8960 c Instructions; enter code(s) 62
Cell(total_tax, 24, Total tax, <|CV(tax_minus_credits)+CV(postcredit_taxes)|>)

Cell(federal_tax_withheld, 25, Federal income tax withheld from Forms W-2 and 1099,, u)
Cell(eitc, 27, Earned income credit (EIC), <|eitc(CV(AGI), kids)|>)
Cell(actc, 28, Refundable child tax credit, <|CV(ctc_sch8812_IIA, refundable_ctc)|>, kids)
Cell(ed_tc, 29, Refundable education credits, <|CV(f8863, refundable_credit)|>, s_loans)
Cell(other_tc, 31, <|Other asst credits from Sch 3|>, ,u)

Cell(total_payments, 33, Total payments, <|SUM(federal_tax_withheld, eitc, actc, ed_tc, other_tc)|>)
Cell(refund, 34, Refund, <|max(CV(total_payments)-CV(total_tax), 0)|>, critical)
Cell(tax_owed, 37, Tax owed, <|max(CV(total_tax)-CV(total_payments), 0)|>, critical)

m4_form(f1040sch2)
    Cell(amt, 1,
        Alternative minimum tax,
        <|CV(f6251,amt)|>,
        itemizing
    )
    Cell(credit_repayment, 2,
        Excess advance premium tax credit repayment, , u
    )
    Cell(sch2_total, 2,
        <|CV(amt)+CV(credit_repayment)|>,
        itemizing
    )

m4_form(f1040sch3)
    Cell(ftc, 1,
        Foreign tax credit, , u
    )
    Cell(dependent_care, 2, Dependent care expenses,
        , u
    )
    Cell(ed_credits, 3,
        Education credits via f8863,
        <|CV(f8863, nonrefundable_credit)|>,
        s_loans
    )
    Cell(retirement_savings, 4, Retirement savings contribution credits,
        , u
    )
    Cell(elderly_disabled_credits, 6.4,
        Elderly or disabled credit from Schedule R, , u
    )
    Cell(alt_motor_vehicle, 6.5,
        Alternative motor vehicle credit, , u
    )
    Cell(plug_in_motor_vehicle, 6.6,
        Qualified plug-in motor vehicle credit, , u
    )
    Cell(nonrefundable_total, 8,
        Total nonrefundable credits,
        <|CV(ftc)+CV(dependent_care)+CV(elderly_disabled_credits)+CV(ed_credits)|>
    )

m4_form(student_loan_ws_1040)
    Cell(student_loan_interest, 1,
        Interest you paid in 2021 on qualified student loans,
        , u s_loans
    )
    Cell(loans_maxed, 1.1,
        <|Student loan interest, maxed at $2,500|>,
        <|min(CV(student_loan_interest), 2500)|>,
        s_loans
    )
    Cell(phase_out_pct, 6,
        total income minus phase-out limit,
        <|min(1, m4_dnl
            max(CV(f1040, total_in) - CV(f1040sch1, subtractions_from_income_wo_student_loans) m4_dnl
                - Fswitch((married filing jointly, 145000), 70000), 0)/Fswitch((married filing jointly, 30000), 15000))|>,
        s_loans
    )
    Cell(phased_out_loans, 8,
        phased-out loans,
        <|CV(loans_maxed)*CV(phase_out_pct)/15000.|>,
        s_loans
    )
    Cell(final_credit, 9,
        Student loan interest credit,
        <|max(CV(loans_maxed) - CV(phased_out_loans), 0)|>,
        s_loans
    )

m4_form(ctc_sch8812_I)
Cell(two_thousand_per_child, 5,
        <|$2,000 per child under 17 w/an SSN ($500 for other children unimplemented)|>,
        <|thousandkids()|>,
        kids
    )
Cell(ctc_subtraction, 11,
        <|5% of AGI minus a filing-status dependent number|>,
        <|ctc_status(CV(f1040, AGI))|>,
        kids
    )
Cell(credit_remaining, 12,
        <|$2,000 per child minus the subtraction|>,
        <|max(CV(two_thousand_per_child) - CV(ctc_subtraction), 0)|>,
        kids
    )
Cell(tax_minus_some_credits, 13.1,
        m4_dnl From credit limit ws A.
        m4_dnl Not quite a limit; more like converting nonrefundable CTC into refundable.
        Calculated tax minus some credits,
        <|CV(f1040, tax)
          - CV(f1040sch3, ftc) - CV(f1040sch3, dependent_care)- CV(f1040sch3, ed_credits)
          - CV(f1040sch3, retirement_savings) - CV(f1040sch3, elderly_disabled_credits)
          - CV(f1040sch3, alt_motor_vehicle)  - CV(f1040sch3, plug_in_motor_vehicle)|>,
        kids
    )
Cell(ctc, 10, Nonrefundable child tax credit,
        <|min(CV(tax_minus_some_credits), CV(credit_remaining))|>,
        kids
    )

m4_form(ctc_sch8812_IIA)  m4_dnl II-A: additional (refundable) credit
Cell(unused_ctc, 16,
         CTC not used,
         <|max(0, CV(ctc_sch8812_I, credit_remaining) - CV(ctc_sch8812_I, ctc))|>,
         kids
     )
Cell(fifteen_kids, 16.1,
        <|$1,500 per kid|>,
        <|fifteenkids()|>,
        kids
    )
Cell(limited_unused, 17,
        Limited unused CTC,
        <|min(CV(unused_ctc), CV(fifteen_kids))|>,
        kids
    )
Cell(scaled_earned_income, 8,
        <|15 percent of earned income-2500|>,
        <|max(0, 0.15*(CV(f1040, wages)-2500))|>,
        kids
    )
Cell(ss_and_medicare_withheld, 11,
        <|Social security and medicare withheld on W-2 lines 4 and 6|>, , u kids
    )
     
Cell(refundable_ctc, 15,
        Refundable child tax credit,
        <|actc(CV(limited_unused), CV(scaled_earned_income),CV(f1040sch1, self_employment_deductible) + CV(ss_and_medicare_withheld), CV(f1040, eitc))|>,
        kids
    )

m4_form(f1040_tax_refund_ws)
    Cell(last_year_refund, 1,
        <|Enter the income tax refund from Form(s) 1099G, up to income taxes on last year's Schedule A|>,,
        u ly_refund
    )
    Cell(last_year_5d, 1,
        <|Enter line 29 of your 2020 Schedule A|>,,
        u ly_refund
    )
    Cell(last_year_limited_deductions, 1.3,
        <|Enter line 5e of your 2020 Schedule A|>,,
        u ly_refund
    )
    Cell(last_year_reduced, 2,
        <|Last year's deductions, maybe reduced|>,
        <|max(CV(last_year_5d)-CV(last_year_limited_deductions), 0)|>,
        ly_refund
    )
    Cell(last_year_post_limit, 3,
        <|Last year's tax deducted, limited|>,
        <|max(CV(last_year_refund)-CV(last_year_reduced), 0)|>,
        ly_refund
    )
    Cell(last_year_total_deductions, 4,
        <|Last year's itemized deductions|>,,
        u ly_refund
    )
    Cell(almost_std_deduction, 5,
        <|Last year's standard deduction (under your current status)|>,
        <|Fswitch((married filing jointly, 25100), (head of household, 18800), 12550)|>,
        ly_refund
    )
    Cell(srblind, 6,
        <|Senior or blind exemption (blind UI; mfj PI)|>,
        <|((Situation(over_65)==1)+(Situation(spouse_over_65)==1))*         m4_dnl
          Fswitch((married, 1350), (married filing jointly, 1350), 1700)|>,
        ly_refund
    )
    Cell(itemized_over_std, 6.5,
        Itemized deduction minus standard for last year,
        <|max(CV(last_year_total_deductions) - CV(almost_std_deduction) - CV(srblind), 0)|>,
        ly_refund
    )
    Cell(taxable_refund, 7,
        Taxable tax refund,
        <|min(CV(itemized_over_std), CV(last_year_post_limit))|>,
        ly_refund
    )


m4_form(qualified_dividends_ws)
    Cell(qualified_dividends_and_gains, 4,
        <|Qualified dividends plus cap gains|>,
        <|CV(f1040,qualified_dividends)+CV(f1040, capital_gains)|>,
        cap_gains
    )
    Cell(income_minus_gains, 5,
        <|Income minus gains|>,
        <|CV(f1040,taxable_income)-CV(qualified_dividends_and_gains)|>,
        cap_gains
    )
    Cell(limitation, 6,
        <|Limitation|>,
        <|Fswitch((head of household, 55800), (married filing jointly, 83350), 41675)|>,
        cap_gains
    )
    Cell(limited_income, 7,
        <|Limited income|>,
        <|min(CV(f1040,taxable_income), CV(limitation))|>,
        cap_gains
    )
    Cell(alt_limited_income, 8,
        <|Limited income again|>,
        <|min(CV(limited_income), CV(income_minus_gains))|>,
        cap_gains
    )
    Cell(untaxed, 9,
        <|Untaxed portion|>,
        <|CV(limited_income) - CV(alt_limited_income)|>,
        cap_gains
    )
    Cell(min_ded_or_gains_minus_zero, 12,
        <|Remove untaxed from income|>,
        <|min(CV(f1040,taxable_income), CV(income_minus_gains)) - CV(untaxed)|>,
        cap_gains
    )
    Cell(relimited_qualified, 13,
        <|qualified gains re-limited|>,
        <| min(CV(min_ded_or_gains_minus_zero),            m4_dnl
            max( min(Fswitch((single, 459750), (married, 258600), (married filing jointly, 517200), 488500), m4_dnl
                CV(f1040,taxable_income)) - (CV(income_minus_gains) + CV(untaxed)) , 0))|>,
        cap_gains
    )
    Cell(fifteen_pct_tax, 18,
        <|15% tax on qualified gains|>,
        <|CV(relimited_qualified)*0.15|>,
        cap_gains
    )
    Cell(income_minus_fifteen, 20,
        <|Gains minus 15% taxed part|>,
        <|min(CV(f1040,taxable_income), CV(qualified_dividends_and_gains)) - (CV(untaxed) + CV(relimited_qualified))|>,
        cap_gains
    )
    Cell(twenty_pct_tax, 21,
        <|20% tax on dividends and gains|>,
        <|CV(income_minus_fifteen)*0.20|>,
        cap_gains
    )
    Cell(nongains_tax, 22,
        <|Tax on income without qualified gains|>,
        <|tax_calc(CV(income_minus_gains))|>,
        cap_gains
    )
    Cell(total_tax, 23,
        <|Total tax including qualified gains discounts|>,
        <|SUM(fifteen_pct_tax, twenty_pct_tax, nongains_tax)|>,
        cap_gains
    )
