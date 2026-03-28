
function [Score1, Score2, Best_flag, Max_score] = score_calc(Result_1, Result_2, Target)

[Score1, Max_score] = score_calc_ch(Result_1, Target);
Score2 = score_calc_ch(Result_2, Target);

Best_flag = Score1 == Max_score && Score2 == Max_score;

end




function [Score, max_score] = score_calc_ch(Result, Target)

[A_err_prc, P_err_deg, C_err_prc] = fit_viewer.carrier_error_calc(Result);

Amp_err_target = Target.amp_err_prc;
Phi_err_target = Target.phi_err_deg;

max_score = 23; %  FIXME: magic constant

Score = 0;
if A_err_prc < 0.1*Amp_err_target
    Score = Score + 10;
elseif A_err_prc <= Amp_err_target
    Score = Score + 3;
elseif A_err_prc > 10*Amp_err_target
    Score = Score - 10;
elseif A_err_prc > Amp_err_target
    Score = Score - 3;
end

if P_err_deg < 0.1*Phi_err_target
    Score = Score + 10;
elseif P_err_deg <= Phi_err_target
    Score = Score + 3;
elseif P_err_deg > 10*Phi_err_target
    Score = Score - 10;
elseif P_err_deg > Phi_err_target
    Score = Score - 3;
end

if C_err_prc < 0.1*Amp_err_target
    Score = Score + 3;
elseif C_err_prc <= Amp_err_target
    Score = Score + 0.5;
elseif C_err_prc > 10*Amp_err_target
    Score = Score - 3;
elseif C_err_prc > Amp_err_target
    Score = Score - 0.5;
end

end



