
function [Score1, Score2, Best_flag, Max_score] = score_calc(Result_1, Result_2, Target)

[Score1, Max_score] = fit_viewer.score_calc_ch(Result_1, Target);
Score2 = fit_viewer.score_calc_ch(Result_2, Target);

Best_flag = Score1 == Max_score && Score2 == Max_score;

end








