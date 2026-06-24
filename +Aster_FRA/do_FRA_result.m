

% FIXME: R_Scale could be calculated from Range_N
% FIXME: freq is inside Result struct

function Result = do_FRA_result(Result_1, Result_2, freq, Range_N, R_Scale)
arguments
    Result_1
    Result_2
    freq
    Range_N
    R_Scale = []
end

if isempty(R_Scale)
    R_Scale = Aster_r_scale(Range_N);
end

Output = fit_viewer.calc_output(Result_1, []);
Volt1 = Output.amp;
Volt1_err = Output.amp_err;
CH_1_P = Output.phi;
CH_1_Pe = Output.phi_err;

Output = fit_viewer.calc_output(Result_2, []);
Volt2 = Output.amp;
Volt2_err = Output.amp_err;
CH_2_P = Output.phi;
CH_2_Pe = Output.phi_err;

% CALC fundamental Res and Phi with errors
[Res, Res_err, Phase_diff, Phase_diff_error] = calc_res_phi(Volt1, ...
    Volt1_err, Volt2, Volt2_err, R_Scale, CH_1_P, CH_1_Pe, CH_2_P, CH_2_Pe);


% CALIBRATION SECTION
[Res, Phase_diff, Amp_cal_err, Phi_cal_err] = ...
    Aster_FRA.apply_calibration(Range_N, freq, Res, Phase_diff);

[Amp_err_rel, Phi_err_abs] = Aster_FRA.get_instr_errors(Range_N);

% update fundamental's errors
Res_abs_err = Res*Amp_err_rel;
Res_err = sqrt(Res_err^2 + Amp_cal_err^2 + Res_abs_err^2);
Phase_diff_error = sqrt(Phase_diff_error^2 + Phi_cal_err^2 + Phi_err_abs^2);


% NOTE: CH1 harmonics should not be converted to resistance
% FIXME: find a way to use voltage harmonics
% Harm_1_out_arr = Harm_calc_and_corr(Result_1, freq, Volt1, ...
%     Volt1_err, P1, P1e, R_Scale, Range_N);

% get harmonics info
Harm_2_out_arr = Harm_calc_and_corr(Result_2, freq, Volt1, ...
    Volt1_err, CH_1_P, CH_1_Pe, R_Scale, Range_N);






% Res_cplx = Res*cos(Phase_diff/180*pi) + Res*1i*sin(Phase_diff/180*pi);
% Res
% Res_r = real(Res_cplx)
% Res_i = -imag(Res_cplx)


% Cap = 1/(6.28*freq*Res_i);
% Cap_2 = 1/(6.28*freq*(Res+Res_err))
% Cap_3 = 1/(6.28*freq*(Res-Res_err))
% Cap_err = 1/(6.28*freq*Res_i^2)*Res_err;

Zfull = Res*cos(Phase_diff/180*pi) + Res*1i*sin(Phase_diff/180*pi);


[C_par, R_par] = fit_viewer.RC_calc_parallel(Zfull, freq);
[C_ser, R_ser] = fit_viewer.RC_calc_series(Zfull, freq);



fit_viewer.print_f_dev(Result_1.f_dev_ppm, Result_1.f_dev_ppm_err);
fit_viewer.print_f_dev(Result_2.f_dev_ppm, Result_2.f_dev_ppm_err);

disp(' ')

fit_viewer.print_res(Res, Res_err)
% Cap = 1/(6.28*freq*Res);
% Cap_err = 1/(6.28*freq*Res^2)*Res_err;
% print_cap(Cap, Cap_err)
fit_viewer.print_phi(Phase_diff, Phase_diff_error)

disp(' ')

disp('Parallel:')
fit_viewer.print_cap(C_par)
fit_viewer.print_res(R_par)

disp(' ')

disp('Series:')
fit_viewer.print_cap(C_ser)
fit_viewer.print_res(R_ser)

disp(' ')

warning('|R| may be calculated incorrectly!')

% FIXME: use Aster_FRA.LCR_result_type here
Result.res_abs = Res;
Result.res_abs_err = Res_err;

Result.phi = Phase_diff;
Result.phi_err = Phase_diff_error;

Result.harm2 = Harm_2_out_arr;

Result.cap_par = C_par;
Result.r_scale = R_Scale;
Result.current = []; % FIXME: debug; previously: Cur;
Result.current_error = []; % FIXME: debug; previously: Cur_err;
Result.voltage = []; % FIXME: debug; previously: Volt1;
Result.voltage_error = [];% FIXME: debug; previously: Volt1_err;

Result.range_n = Range_N;
Result.freq = freq;

end




function Phase_diff = Phase_calc(V_phase, I_Phase)
Phase_diff = -(I_Phase - V_phase);
end


function R_Scale = Aster_r_scale(Range_N)
    Res_list = [200 10e3 1e6 100e6 10e9 1e12];
    R_Scale = 1/Res_list(Range_N);
end


function [Res, Res_err, Phase_diff, Phase_diff_error] = calc_res_phi(Volt1, ...
    Volt1_err, Volt2, Volt2_err, R_Scale, P1, P1e, P2, P2e)

% R_Scale = Aster_r_scale(Range_N);

Cur = Volt2*R_Scale;
Cur_err = Volt2_err*R_Scale;
Res = Volt1/Cur;
Res_err = sqrt(((1/Cur)*Volt1_err)^2 + ((-Volt1/Cur^2)*Cur_err)^2);
Phase_diff = Phase_calc(P1, P2);
Phase_diff_error = sqrt(P1e^2 + P2e^2);

if Phase_diff > 180
    Phase_diff = Phase_diff - 360;
end
if Phase_diff < -180
    Phase_diff = Phase_diff + 360;
end

end


function Harm_out_arr = Harm_calc_and_corr(Result, freq, Volt1, ...
    Volt1_err, P1, P1e, R_Scale, Range_N)

Harms_arr = Result.harm;
Harms_err_arr = Result.harm_err;

[Amp_err_rel, Phi_err_abs] = Aster_FRA.get_instr_errors(Range_N);

Harm_out_arr = [];
for i = 1:numel(Harms_arr)
    Harm = Harms_arr(i);
    Harm_err = Harms_err_arr(i);

    Hn = Harm.n;
    H_freq = freq*Hn;
    Harm_amp = Harm.amp;
    Harm_amp_err = Harm_err.amp;
    Harm_phi = Harm.phi;
    Harm_phi_err = Harm_err.phi;

    [Harm_res, Harm_res_err, Harm_phase, Harm_res_phi_err] = ...
        calc_res_phi(Volt1, Volt1_err, Harm_amp, Harm_amp_err, R_Scale, ...
        P1, P1e, Harm_phi, Harm_phi_err);

    % FIXME: add force flag to calibration to preserve harmonics
    [Harm_res, Harm_phase, Harm_amp_cal_err, Harm_phi_cal_err] = ...
        Aster_FRA.apply_calibration(Range_N, H_freq, Harm_res, Harm_phase);

    Harm_res_abs_err = Harm_res*Amp_err_rel;

    Harm_res_err = sqrt(Harm_res_err^2 + Harm_amp_cal_err^2 + Harm_res_abs_err^2);
    Harm_res_phi_err = sqrt(Harm_res_phi_err^2 + Harm_phi_cal_err^2 + Phi_err_abs^2);

    Harm_out.n = Hn;
    Harm_out.res = Harm_res;
    Harm_out.res_err = Harm_res_err;
    Harm_out.phi = Harm_phase;
    Harm_out.phi_err = Harm_res_phi_err;
    
    Harm_out_arr = [Harm_out_arr Harm_out];
end


end







