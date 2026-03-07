
function [Signal, Amp_full, Phi_full, BG_full, Amp_err, Phi_err, BG_err] = ...
    calc_fitted_signal(Result, Time)

Amp_full = poly3calc(Result.amp_poly, Time);
Phi_full = poly3calc(Result.phi_poly, Time);
BG_full = poly3calc(Result.bg_poly, Time);

Amp_err = poly3calc(Result.amp_poly_err, Time);
Phi_err = poly3calc(Result.phi_poly_err, Time);
BG_err = poly3calc(Result.bg_poly_err, Time);

D = Result.f_div_ppm;
Freq2 = Result.freq*(1+D/1e6);
Signal = Amp_full.*sin(2*pi*Freq2*Time + Phi_full/180*pi) + BG_full;

end