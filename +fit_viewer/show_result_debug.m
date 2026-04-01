function show_result_debug(Result_1, Result_2, freq, R_Scale)

Output = fit_viewer.calc_output(Result_1, []);
Volt1 = Output.amp;
Volt1_err = Output.amp_err;
P1 = Output.phi;
P1e = Output.phi_err;

Output = fit_viewer.calc_output(Result_2, []);
Volt2 = Output.amp;
Volt2_err = Output.amp_err;
P2 = Output.phi;
P2e = Output.phi_err;


% clc

Cur = Volt2*R_Scale;
Cur_err = Volt2_err*R_Scale;
Res = Volt1/Cur;
Res_err = sqrt(((1/Cur)*Volt1_err)^2 + ((-Volt1/Cur^2)*Cur_err)^2);
Phase_diff = (P1) - (P2);
Phase_diff_error = sqrt(P1e^2 + P2e^2);

if Phase_diff > 180
    Phase_diff = Phase_diff - 360;
end
if Phase_diff < -180
    Phase_diff = Phase_diff + 360;
end

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


end

