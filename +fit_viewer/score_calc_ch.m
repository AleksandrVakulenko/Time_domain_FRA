
% FIXME: This whole function is one big magic constant.

function [Score, max_score] = score_calc_ch(Result, Target)

max_score = 23; % FIXME: magic constant

if isempty(Result)
    Score = -inf;
    return;
end

[A_err_prc, P_err_deg, C_err_prc] = fit_viewer.carrier_error_calc(Result);

Amp_err_target = Target.amp_err_prc;
Phi_err_target = Target.phi_err_deg;

% FIXME: debug version of function
Ratio = get_amp_to_range_ratio(Result);

if Ratio < 0.01
    Score_add = 6;
elseif Ratio < 0.02
    Score_add = 3;
elseif Ratio < 0.05
    Score_add = 1;
else
    Score_add = 0;
end
% ------------------------------------

Score = 0;
if A_err_prc < 0.2*Amp_err_target
    Score = Score + 10;
elseif A_err_prc < 0.5*Amp_err_target
    Score = Score + 5;
elseif A_err_prc <= Amp_err_target
    Score = Score + 3;
elseif A_err_prc > 10*Amp_err_target
    Score = Score - 10;
elseif A_err_prc > 2*Amp_err_target
    Score = Score - 3;  
elseif A_err_prc > Amp_err_target
    Score = Score - 1;
end


if P_err_deg < 0.2*Phi_err_target
    Score = Score + 10;
elseif P_err_deg < 0.5*Phi_err_target
    Score = Score + 5;
elseif P_err_deg <= Phi_err_target
    Score = Score + 3;
elseif P_err_deg > 10*Phi_err_target
    Score = Score - 10;
elseif P_err_deg > 2*Phi_err_target
    Score = Score - 3;  
elseif P_err_deg > Phi_err_target
    Score = Score - 1;
end


if C_err_prc < 0.5*Amp_err_target
    Score = Score + 3;
elseif C_err_prc <= Amp_err_target
    Score = Score + 0.5;
elseif C_err_prc > 10*Amp_err_target
    Score = Score - 5;
elseif C_err_prc > 2*Amp_err_target
    Score = Score - 3;
elseif C_err_prc > Amp_err_target
    Score = Score - 0.5;
end

Score = Score + Score_add;

end



function Ratio = get_amp_to_range_ratio(Result)
    % FIXME: get it from results
    MAX_VOLTAGE = 10;

    T_start = Result.amp_poly.x(1);
    T_end = Result.amp_poly.x(3);

    N = 10;
    T_arr = linspace(T_start, T_end, N);
    Amp = fit_viewer.poly3calc(Result.amp_poly, T_arr);
    Amp = mean(Amp);

    Ratio = Amp / MAX_VOLTAGE;
end




