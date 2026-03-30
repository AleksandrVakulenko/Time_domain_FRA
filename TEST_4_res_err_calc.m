
clc

[A_err_prc, P_err_deg, C_err_prc] = fit_viewer.carrier_error_calc(Result_1);

disp(['A_err = ' num2str(A_err_prc, '%0.4f') ' %'])
disp(['P_err = ' num2str(P_err_deg, '%0.4f') ' deg'])
disp(['C_err = ' num2str(C_err_prc, '%0.4f') ' %'])

disp(' ')

[A_err_prc, P_err_deg, C_err_prc] = fit_viewer.carrier_error_calc(Result_2);

disp(['A_err = ' num2str(A_err_prc, '%0.4f') ' %'])
disp(['P_err = ' num2str(P_err_deg, '%0.4f') ' deg'])
disp(['C_err = ' num2str(C_err_prc, '%0.4f') ' %'])


%%
clc

Target.amp_err_prc = 0.05; % [%]
Target.phi_err_deg = 0.1; % [deg]

[Score1, Score2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Target);


%%
Harm = Result_in.harm;
Harm_err = Result_in.harm_err;
N = numel(Harm);

H_amp_dBc = zeros(1, N);
H_amp_err_prc = zeros(1, N);
H_phi_err_deg = zeros(1, N);
for i = 1:N
    Amp = Harm(i).amp;
    Phi = Harm(i).phi;

    Amp_err = Harm_err(i).amp;
    Phi_err = Harm_err(i).phi;

    H_amp_dBc(i) = 20*log10(Amp/mean(Amp_out));
    H_amp_err_prc(i) = Amp_err/Amp * 100;
    H_phi_err_deg(i) = Phi_err;
end


%%
