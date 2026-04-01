function [C_par, R_par] = RC_calc_parallel(Z, Freq)
% FIXME: add errors
Abs_sq = real(Z)^2 + imag(Z)^2;
R_par = Abs_sq/real(Z);
C_par = -imag(Z)/(2*pi*Freq * Abs_sq);
end