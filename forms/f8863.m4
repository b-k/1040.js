m4_form(f8863)

Cell(pt3_divider, 0, >>>>>>>>>>>> Part III first                                   , 0)
Cell(education_expenses_1, 27, <|Education expenses (student 1)|>, , u s_loans)
Cell(scaled_education_expenses_1, 28, <|Limited Education expenses (s1)|>, <|max(0.25*(min(CV(education_expenses_1), 4000)-2000),0)|> , s_loans)
Cell(rescaled_education_expenses_1, 29, <|Relimited Education expenses (s1)|>, <|IF(CV(education_expenses_1)<=2000, CV(education_expenses_1), CV(scaled_education_expenses_1)+2000)|>, s_loans)

Cell(education_expenses_2, 27, <|Education expenses (student 2)|>, , u s_loans)
Cell(scaled_education_expenses_2, 28, <|Limited Education expenses (s2)|>, <|max(0.25*(min(CV(education_expenses_2), 4000)-2000),0)|> , s_loans)
Cell(rescaled_education_expenses_2, 29, <|Relimited Education expenses (s2)|>, <|IF(CV(education_expenses_2)<=2000, CV(education_expenses_2), CV(scaled_education_expenses_2)+2000)|>, s_loans)

Cell(education_expenses_3, 27, <|Education expenses (student 3)|>, , u s_loans)
Cell(scaled_education_expenses_3, 28, <|Limited Education expenses (s3)|>, <|max(0,0.25*(min(CV(education_expenses_3), 4000)-2000),0)|> , s_loans)
Cell(rescaled_education_expenses_3, 29, <|Relimited Education expenses (s3)|>, <|IF(CV(education_expenses_3)<=2000, CV(education_expenses_3), CV(scaled_education_expenses_3)+2000)|>, s_loans)

Cell(adjusted_qualified_expenses, 31, <|Total adjusted qualified expenses, all students|>, , u s_loans)

Cell(pt1_divider, 0, >>>>>>>>>>>> Part I, Refundable                               , 0)

Cell(total_limited_expenses, 1, Total limited expenses, <|SUM(rescaled_education_expenses_1,rescaled_education_expenses_2, rescaled_education_expenses_3)|>, s_loans)
Cell(baseline, 2, 90 or 180k, <|Fswitch((married filing jointly, 180000), 90000)|>,  s_loans)
Cell(ninety_k_minus_agi, 4, Remaining after AGI subtraction, <|max(0, CV(baseline) - CV(f1040, AGI))|>,  s_loans)
Cell(fraction, 6, Fraction allowed, <|max(min(1, CV(ninety_k_minus_agi)/Fswitch((married filing jointly, 20000), 10000)), 0)|>, s_loans)
Cell(unscaled_credit, 7, Unscaled credit, <|CV(total_limited_expenses)*CV(fraction)|>, s_loans)
Cell(under_24, 7.5, <|If you're under 24, 1|>, , u s_loans)
Cell(refundable_credit, 8, Refundable education credit, <|IF(CV(under_24)<0, CV(unscaled_credit)*.4, 0)|>, s_loans)

Cell(pt2_divider, 8.5, >>>>>>>>>>>> Part II, Nonrefundable                           , 0)
Cell(remaining_credit, 9, <|Remaining tentative credit|>, <|CV(unscaled_credit) - CV(refundable_credit)|>, s_loans)
Cell(aqe, 12, <|20% of Adjusted qualified expenses or 1k|>, <|min(1000, CV(adjusted_qualified_expenses)) *.2|>, s_loans)
Cell(baseline2, 13,
        <|67k or 134k|>,
        <|Fswitch((married filing jointly, 180000), 90000)|>,
        s_loans
    )
Cell(fraction2, 17, Fraction allowed, <|max(min(1, (CV(baseline2)-CV(f1040, AGI))/Fswitch((married filing jointly, 20000), 10000)), 0)|>, s_loans)
Cell(frac_allowed, 18, <|Fraction allowed|>, <|CV(fraction2)*CV(aqe)|>, s_loans)
Cell(nonrefundable_credit, 19, <|Nonrefundable credit|>, <|min(CV(f8863ws, diff), CV(f8863ws, credit_sum))|>, s_loans)

m4_form(f8863ws)
    Cell(credit_sum, 3,
        Lines 9 plus 18,
        <|CV(f8863, remaining_credit)+CV(f8863, frac_allowed)|>,
        s_loans
    )
    Cell(tax, 4,
        Tax minus some credits from 1040,
        <|CV(f1040, tax_plus_amt_and_repayment)|>,
        s_loans
    )
    Cell(other_credits, 5,
        FTC plus child care plus elderly credit,
        <|CV(f1040sch3,ftc) + CV(f1040sch3, dependent_care)+ CV(f1040sch3, elderly_disabled_credits)|>,
        s_loans
    )
    Cell(diff, 6,
        Tax minus credits,
        <|max(0, CV(tax)-CV(other_credits))|>,
        s_loans
    )
