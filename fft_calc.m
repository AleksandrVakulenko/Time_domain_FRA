
% FIXME: put in Fern module

function [Amp, freq, Phi, Limit] = fft_calc(x, fs)
L = numel(x);
if mod(L, 2) == 1
    L = L - 1;
    x(end) = [];
end
Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:L/2+1); % FIXME: round?
P1(2:end-1) = 2*P1(2:end-1);
freq = fs*(0:(L/2))/L;
Amp = P1;

Limit = 90e-6; % FIXME: magic constant
range = abs(Amp) < Limit;
Y(range) = 0;
Phi = angle((Y*1i))/pi*180;
Phi = Phi(1:L/2+1);
end