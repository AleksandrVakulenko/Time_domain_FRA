function [C_ser, R_ser] = RC_calc_series(Z, Freq)
% FIXME: add errors
R_ser = real(Z);
C_ser = -1/(2*pi*Freq*imag(Z));
end