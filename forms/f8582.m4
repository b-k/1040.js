m4_form(f8582)

def what_is_allowed(L5, L9):
    out=min(L5, L9)
    if (out < L5):
        print("%s in real estate losses are disallowed. Carry them over to next year." % (L5-out,))
    return out

Cell(ws1_8582_net_gain, 0.1,Net income, <|max(CV(f1040_sched_e, rents_received), 0)|>, have_rr)
Cell(ws1_8582_net_loss, 0.2,Net loss, <|min(CV(f1040_sched_e, rents_received), 0)|>, have_rr)
Cell(ws1_8582_prior_loss, 0.3,Prior year carryover real estate loss,, u have_rr)

Cell(div_85821, 0.9,">>>>Part I        ", have_rr)
Cell(div_85822, 4.9,">>>>Part II       ", have_rr)
Cell(f8582_net_in, 1.0, Net income, <|CV(ws1_8582_net_gain)|>, have_rr)
Cell(f8582_net_loss, 1.2, Net loss, <|CV(ws1_8582_net_loss)|>, have_rr)
Cell(f8582_carryover, 1.4, Prior year carryover, <|CV(ws1_8582_prior_loss)|>, have_rr)
Cell(f8582_total_real_in, 1.6, Sum, <|SUM(f8582_net_in, f8582_net_loss, f8582_carryover)|>, have_rr)

Cell(f8582_commercial_revitalization, 2, Commercial revitalization deductions (UI), '0', have_rr)
Cell(f8582_passive_activities, 3, Passive activity income (UI), '0', have_rr)
Cell(f8582_total_in, 4, Total in,  <|SUM(f8582_total_real_in, f8582_commercial_revitalization, f8582_passive_activities)|>, have_rr)

Cell(f8582_min, 5, the smaller of the loss on line 1d or the loss on line 4, <|max(min(CV(f8582_total_real_in),0), min(CV(f8582_total_in),0))|>, have_rr)

Cell(f8582_half, 9, <|Half of line 8, up to 25k|>, <|min(25000, max(150000 - max(CV(f1040, MAGI), 0), 0)/2.)|>, have_rr)
Cell(allowed_real_losses, 10, Allowed real estate losses, <|min(CV(f8582_min), CV(f8582_half))|>, have_rr)
Cell(carryover_to_next_year, 10, Carry this over to next year, <|max(CV(f8582_min) - CV(f8582_half), 0)|>, have_rr)

Ce<||>ll(div_8582, >>>>Total , 14.9, have_rr)
Cell(total_gains_8582, 15, Total (UI), '0', have_rr)
Cell(total_losses_8582, 16, Total loss, <|min(-CV(allowed_real_losses)+CV(total_gains_8582), 0)|>, have_rr)
