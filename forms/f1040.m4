jsversion(<|
var exemption_multiplier=4000  //changes annually
var status="single"

//#2014 tax rate schedules
var tax_calc = function (inval){
    if (inval < 9075) return .1*907.50;
    if (inval < 36900) return 907.50  + .15*(inval-9075);
    if (inval < 89350) return 5081.25 + .25*(inval-36900);
    if (inval < 186350) return 18193.75 + .28*(inval-89350);
    if (inval < 405100) return 45353.75 + .33*(inval-186350);
}

var eitc = function(income, kids){
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

var max = function(a,b) { return Math.max(a,b)}

var deductions = function(){
    var ded=0;
    if (status=="married" || status=="single") ded=6300;
    else if (status=="married filing jointly") ded=12600;
    else if (status=="head of household") ded=9250;
    if (itemizing) ded=max(ded, CV(total_itemized_deductions));
    return ded
}
|>)

pyversion(<|
exemption_multiplier=4000  #changes annually

#2014 tax rate schedules
def tax_calc(inval):
    if inval < 9075: return .1*907.50
    if inval < 36900: return 907.50  + .15*(inval-9075)
    if inval < 89350: return 5081.25 + .25*(inval-36900)
    if inval < 186350: return 18193.75 + .28*(inval-89350)
    if inval < 405100: return 45353.75 + .33*(inval-186350)

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


def deductions():
    ded=0
    if status=="married" or status=="single":
        ded=6300
    elif status=="married filing jointly":
        ded=12600
    elif status=="head of household":
        ded=9250
    if itemizing:
        ded=max(ded, CV('total_itemized_deductions'))
    return ded
|>)

m4_form(1040)

Cell(exemptions, 6, "Exemptions", u, u)
Cell(income_divider, 6.9, >>>>>>>>>>>> Income                                   , '0')
Cell(wages,7,<|"Wages, salaries, tips, from form W-2"|>,  , u)
Cell(interest, 8,"Taxable interest",  , u)
Ce<||>ll(tax_free_interest, 8.5,"Tax-exempt interest",  , u)
Cell(dividends, 9,"Ordinary dividends", u, u)
Cel<||>l(qualified_dividends, 9.5,"Qualified dividends",u, u)
Cell(taxable_tax_refunds, 10,"Taxable state/local income tax refunds/credits/offsets",u, u)
Cell(alimony, 11,'Alimony received', u, u)
Cell(sched_c, 12,'Schedule C business income (UI)', u, u)
Cell(cap_gains, 13,"Capital gains", u, u)
Ce<||>ll(noncap_gains, 14, <|"Other gains or (losses), from Form 4797 (UI)"|>, u,u)
Ce<||>ll(ira_income, 15,"IRA distributions", u, u)
Cell(taxable_ira_income, 15.5,"Taxable IRA distributions", u, u)
Ce<||>ll(pension,16,"Pensions and annuities", u, u over_65  spouse_over_65)
Cell(taxable_pension,16.5,"Pensions and annuities",u, u over_65 spouse_over_65)
Cell(rr_income, 17,"Rents and royalties placeholder", 0, u)
Cell(rents_and_royalties, 17,"Rents and royalties (&c) from Schedule E", <|if (have_rr) CV(rr_income); else 0;|>)
Cell(farm_income, 18,"Farm income from Schedule F (UI)", 0, u)
Cell(unemployment, 19,"Unemployment compensation", u, u)
Ce<||>ll(ss_benefits, 20,"Social security benefits", u, 'u over_65 spouse_over_65')
Cell(taxable_ss_benefits, 20.5,"Taxable social security benefits", u, u over_65 spouse_over_65)
Cell(other_in, 21,"Other income.", u, u)

Cell(magi_total_in, 0,"Total income for MAGI (PI)", <|SUM(wages, interest, dividends, taxable_tax_refunds, alimony, sched_c, cap_gains, taxable_ira_income, taxable_pension, farm_income, unemployment, taxable_ss_benefits, other_in)|>)
Cell(total_in, 22,"Total income", <|SUM(magi_total_in, rents_and_royalties)|>)

agi_divider=cell('>>>>>>>>>>>> AGI                                   ', 22.9, '0'),

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
#33 Student loan interest deduction . . . . . . . . 33
#34 Tuition and fees. Attach Form 8917 . . . . . . . 34
#35 Domestic production activities deduction. Attach Form 8903 35
#36 Add lines 23 through 35 . . . . . . . . . . . . . . . . . . . 36

Cell(subtractions_from_income, 36,"Sum of subtractions from gross income (UI)", 0)

Cell(t_and_i_divider, 36.9,'>>>>>>>>>>>> Taxes and income                      ', 0)
Cell(MAGI, 0,"Modified adjusted gross income", <|CV(magi_total_in) - CV(subtractions_from_income)|>),
Cell(AGI, 37,"Adjusted gross income", <|CV(total_in) - CV(subtractions_from_income)|>)
Cell(agi_again, 38,<|"Adjusted gross income, again"|>, <|CV(AGI)|>)

#39 elderly, blind

Cell(deductions,40,"Deductions", <|deductions() + 0*CV(total_itemized_deductions)|>)
Cell(agi_minus_deductions, 41,"AGI minus deductions", <|CV(agi_again) - CV(deductions)|>)
Cell(exemption_amount, 42,"Exemption amount", <|CV(exemptions)*exemption_multiplier|>)
Cell(taxable_income, 43,"Taxable income", <|max(CV(agi_minus_deductions)-CV(exemption_amount), 0)|>)
Cell(tax, 44,"Tax", <|tax_calc(CV(taxable_income))|>)
Cell(amt_6251,45, "Alternative minimum tax from Form 6251 (UI)", <|0|>) //placeholder until I add f6251
Cell(amt_1040,45, "Alternative minimum tax from Form 6251", <|CV(amt_6251)|>)
Cell(credit_repayment, 46, "Excess advance premium tax credit repayment. (UI)", 0, u)
Cell(pretotal_tax, 47,"Tax + AMT + F8962", <|SUM(tax, amt_1040, credit_repayment)|>)
Ce<||>ll(ftc,48, "Foreign tax credit (UI)", 0)
#49 Credit for child and dependent care expenses. Attach Form 2441 49
#50 Education credits from Form 8863, line 19 . . . . . 50
#51 Retirement savings contributions credit. Attach Form 8880 51
#52 Child tax credit. Attach Schedule 8812, if required . . . 52
#53 Residential energy credits. Attach Form 5695 . . . . 53
#54 Other credits from Form: a 3800 b 8801 c 54
Cell(total_credits, 55,"Total credits", 0)
Cell(tax_minus_credits, 56,"Tax minus credits", <|max(CV(pretotal_tax)-CV(total_credits), 0)|>)

#57 Self-employment tax. Attach Schedule SE 
#58 Unreported social security and Medicare tax from Form: a 4137 b 8919
#59 Additional tax on IRAs, other qualified retirement plans, etc. Attach Form 5329 if required
#60 a Household employment taxes from Schedule H
#b First-time homebuyer credit repayment. Attach Form 5405 if required

Cell(obamacare_fee, 61,"Health care individual responsibility", 0, u)

#62 Taxes from: a Form 8959 b Form 8960 c Instructions; enter code(s) 62
Cell(total_tax, 63,"Total tax", <|SUM(tax_minus_credits, obamacare_fee)|>)
Cell(federal_tax_withheld, 65,"Federal income tax withheld from Forms W-2 and 1099", u, u)

Cell(payments_divider, 63.9,'>>>>>>>>>>>> Payments                              ', '0')
#65 2015 estimated tax payments and amount applied from 2014 return 65
Cell(eitc, 66.5,"Earned income credit (EIC)", <|eitc(CV(agi_again), kids)|>)
#b Nontaxable combat pay election 66b
#67 Additional child tax credit. Attach Schedule 8812 . . . . . 67
#68 American opportunity credit from Form 8863, line 8 . . . 68
#69 Net premium tax credit. Attach Form 8962 . . . . . . 69
#70 Amount paid with request for extension to file . . . . . 70
#71 Excess social security and tier 1 RRTA tax withheld . . . . 71
#72 Credit for federal tax on fuels. Attach Form 4136 . . . . 72
#73 Credits from Form: a 2439 b Reserved c 8885 d 73
Cell(total_payments, 74,"Total payments", <|SUM(federal_tax_withheld, eitc)|>)
Cell(refund, 75,"Refund!", <|max(CV(total_payments)-CV(total_tax), 0)|>)
Cell(tax_owed, 78,"Tax owed", <|max(CV(total_tax)-CV(total_payments), 0)|>)
