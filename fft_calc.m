
% FIXME: put in Fern module

function [Amp, freq] = fft_calc(x, fs)
L = numel(x);
if mod(L, 2) == 1
    L = L - 1;
    x(end) = [];
end
Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
freq = fs*(0:(L/2))/L;
Amp = P1;
end