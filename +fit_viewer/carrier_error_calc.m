
function [A_err_prc, P_err_deg, C_err_prc] = carrier_error_calc(Result_in)
Freq = Result_in.freq;
Period = 1/Freq;

Num_op_points = 10;

pps = Num_op_points/Period;
Output = fit_viewer.calc_output(Result_in, pps);
Amp_out = Output.amp;
% Phi_out = Output.phi;
BG_out = Output.bg;
Amp_err_out = Output.amp_err;
Phi_err_out = Output.phi_err;
BG_err_out = Output.bg_err;


A_err_prc = mean(Amp_err_out./Amp_out)*100;
P_err_deg = mean(Phi_err_out);
C_err_prc = mean(BG_err_out./BG_out)*100;
if mean(abs(BG_out)) < 0.1*mean(abs(Amp_out))
    C_err_prc = mean(BG_err_out./Amp_out)*100;
end

% FIXME: debug
% disp(['A_err = ' num2str(A_err_prc, '%0.4f') ' %'])
% disp(['P_err = ' num2str(P_err_deg, '%0.4f') ' deg'])
% disp(['C_err = ' num2str(C_err_prc, '%0.4f') ' %'])

end