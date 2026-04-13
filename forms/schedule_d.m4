m4_form(f1040_sched_d)

adiv1=cell('>>>>>>>>>>>> Capital gains/losses                     ', 0.9, '0'),

Cell(st_cap_gains, 5, <|Short-term capital gains/losses from all sources|>,, u cap_gains)
Cell(st_cap_gains_carried, 6, <|Short-term capital losses carryover from last year (enter as negative)|>,, u cap_gains)

Cell(lt_cap_gains, 5, <|Long-term capital gains/losses from all sources|>,, u cap_gains)
Cell(lt_cap_gains_carried, 6, <|Long-term capital losses carryover from last year (enter as negative)|>,, u cap_gains)

Cell(total_cap_gains, 16,
        <|Total capital gains, all types|>,
        <|SUM(st_cap_gains, st_cap_gains_carried, lt_cap_gains, lt_cap_gains_carried)|>,
        cap_gains
    )

m4_form(qualified_dividends_ws)
    Cell(qualified_dividends_and_gains, 4,
        <|Qualified dividends plus cap gains|>,
        <|CV(f1040,qualified_dividends)
          + min(CV(f1040_sched_d, total_cap_gains),
                (CV(f1040_sched_d, lt_cap_gains)+CV(f1040_sched_d, lt_cap_gains_carried)))|>,
        cap_gains
    )
    Cell(income_minus_gains, 5,
        <|Income minus gains|>,
        <|max(0, (CV(f1040,taxable_income)-CV(qualified_dividends_and_gains)))|>,
        cap_gains
    )
    Cell(limitation, 6,
        <|Limitation|>,
        <|Fswitch((head of household, 64750), (married filing jointly, 96700), 48350)|>,
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
        <|max(0, (CV(limited_income) - CV(alt_limited_income)))|>,
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
            max( min(Fswitch((single, 533400), (married filing separately, 300000), (married filing jointly, 600050), 566700), m4_dnl
                CV(f1040,taxable_income)) - (CV(income_minus_gains) + CV(untaxed)) , 0))|>,
        cap_gains
    )
    Cell(income_minus_fifteen, 20,
        <|Gains minus 15% taxed part|>,
        <|min(CV(f1040,taxable_income), CV(qualified_dividends_and_gains)) - (CV(untaxed) + CV(relimited_qualified))|>,
        cap_gains
    )
    Cell(nongains_tax, 22,
        <|Tax on income without qualified gains|>,
        <|tax_calc(CV(income_minus_gains))|>,
        cap_gains
    )
    Cell(total_tax, 23,
        <|Total tax including qualified gains discounts|>,
        <|CV(relimited_qualified)*0.15 +CV(income_minus_fifteen)*0.20 + CV(nongains_tax)|>,
        cap_gains
    )
