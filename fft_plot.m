
% FIXME: put in Fern module

function [amp, freq] = fft_plot(sig, fs)
[amp, freq] = fft_calc(sig, fs);
plot(freq, amp)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
end

