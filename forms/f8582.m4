m4_form(f8582)
    Cell(ws1_8582_net_gain, 0.1,
        Net income,
        <|max(CV(f1040_sched_e, rents_received) - CV(f1040_sched_e, total_rental_expenses), 0)|>,
        have_rr
    )
    Cell(ws1_8582_net_loss, 0.2,
        Net loss,
        <|min(CV(f1040_sched_e, rents_received) - CV(f1040_sched_e, total_rental_expenses), 0)|>,
        have_rr
    )
    Cell(ws1_8582_prior_loss, 0.3,
        Prior year carryover real estate loss, ,
        u have_rr
)
    Cell(ws1_8582_d, 0.3,
        Unedited total gain or loss,
        <|SUM(ws1_8582_net_gain,ws1_8582_net_loss,ws1_8582_prior_loss)|>,
        have_rr
    )
    Cell(div_85821, 0.9,>>>>Part I        , have_rr)
    Cell(div_85822, 4.9,>>>>Part II       , have_rr)
    Cell(f8582_net_in, 1.0,
        Net income,
        <|CV(ws1_8582_net_gain)|>,
        have_rr
    )
    Cell(f8582_net_loss, 1.2,
        Net loss,
        <|CV(ws1_8582_net_loss)|>,
        have_rr
    )
    Cell(f8582_carryover, 1.4,
        Prior year carryover,
        <|IF(CV(ws1_8582_prior_loss) < 0, CV(ws1_8582_prior_loss), -CV(ws1_8582_prior_loss))|>,
        have_rr
    )
    Cell(f8582_total_real_in, 1.6,
        Sum,
        <|SUM(f8582_net_in, f8582_net_loss, f8582_carryover)|>,
        have_rr
    )
    Cell(f8582_commercial_revitalization, 2,
        Commercial revitalization deductions (UI), 0, have_rr
    )
    Cell(f8582_passive_activities, 3,
        Active plus Passive activity income (UI),
        <|CV(f8582_total_real_in)|>,
        have_rr
    )
    Cell(f8582_total_in, 4,
        Total in,
        <|SUM(f8582_total_real_in, f8582_commercial_revitalization, f8582_passive_activities)|>,
        have_rr
    )
    Cell(f8582_min, 5,
        the smaller of the loss on line 1d or the loss on line 4,
        <|max(min(CV(f8582_total_real_in),0), min(CV(f8582_total_in),0))|>,
        have_rr
    )
    Cell(f8582_half, 9,
        <|Half of line 8, up to 25k|>,
        <|-min(25000, max(150000 - max(CV(f1040, MAGI), 0), 0)/2.0)|>,
        have_rr
    )
    Cell(allowed_extra_real_losses, 10,
        Allowed above-passive real estate losses,
        <|max(CV(f8582_min), CV(f8582_half))|>,
        have_rr
    )
    Cell(allowed_real_losses, 10,
        Total allowed real estate losses,
        <|CV(allowed_extra_real_losses)- CV(f8582_net_in)|>,
        have_rr
    )
    Cell(carryover_to_next_year, 10,
        Carry this over to next year,
        <|max(0,CV(ws1_8582_prior_loss) + CV(total_losses_8582))|>,
        have_rr
    )
    Cell(total_losses_8582, 16,
        Total loss,
        <|IF(CV(f8582_total_real_in)>0, CV(f8582_net_loss) - CV(ws1_8582_prior_loss),  min(CV(allowed_real_losses), 0))|>,
        have_rr
    )
