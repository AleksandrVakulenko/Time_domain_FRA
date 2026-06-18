
function [Score1, Score2, Best_flag, Max_score] = score_calc(Result_1, Result_2, Target)

if isempty(Result_1)
    Score1 = -inf;
    Max_score_1 = 0;
else
    [Score1, Max_score_1] = fit_viewer.score_calc_ch(Result_1, Target);
end

if isempty(Result_2)
    Score2 = -inf;
    Max_score_2 = 0;
else
    [Score2, Max_score_2] = fit_viewer.score_calc_ch(Result_2, Target);
end

if Max_score_1 ~= Max_score_2
    Max_score = min([Max_score_1 Max_score_2]); % FIXME: why?
else
    Max_score = Max_score_1;
end


Best_flag = Score1 == Max_score_1 && Score2 == Max_score_2;

end








