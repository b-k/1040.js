m4_form(f1040_sched_c)

adiv1=cell('>>>>>>>>>>>> P/L                                      ', 0.9, '0'),

Cell(gross_rcpts, 1, Gross Receipts,, u self_emp)
Cell(returns_and_allowances, 2, Returns and allowances, , u self_emp)
Cell(cogs, 4, Cost of goods sold, , u self_emp)
Cell(other_income, 6, <|Other income, including some federal credits|>, , u self_emp)

Cell(gross_income, 7,
        Gross profits,
        <|CV(gross_rcpts) - CV(returns_and_allowances) - CV(cogs) + CV(other_income)|>,
        self_emp
    )

Cell(expenses, 8, Sum of all expenses (lines 8–27), , u self_emp)
Cell(home_expenses, 30, Expense for business use of home, , u self_emp)

Cell(net_pl, 31,
        Net Profit/loss,
        <|CV(gross_income) - CV(expenses) - CV(home_expenses)|>,
        self_emp
    )

m4_form(sched_se)

adiv2=cell('>>>>>>>>>>>> Shedule SE                               ', 0.9, '0'),

Cell(in_from_sch_c, 3,
    Schedule C business income,
    <|CV(f1040_sched_c, net_pl)|>,
    self_emp
    )
Cell(net_pl_reduced, 4,
    P/L slightly reduced,
    <|IF(CV(in_from_sch_c)>0, CV(in_from_sch_c)*0.9235, CV(in_from_sch_c))|>,
    self_emp
    )

Cell(ss_wages, 8, <|Social Security wages and tips (W-2 boxes 3 plus 7)|>, , u self_emp)

Cell(distance_to_max, 9, 
        <|Distance to cap|>,
        <|max(0, 160200 - CV(ss_wages))|>,
        self_emp
    )

Cell(twelve_pct, 10,
        <|12.4% of self-employment income, limited|>,
        <|min(CV(distance_to_max), CV(net_pl_reduced))*0.124|>,
        self_emp
    )

Cell(two_pct, 11,
        <|2.9% of self-employment income|>,
        <|0.029 * CV(net_pl_reduced)|>,
        self_emp
    )

Cell(se_tax, 12,
        <|Self-employment tax|>,
        <|CV(twelve_pct) + CV(two_pct)|>,
        self_emp
    )
