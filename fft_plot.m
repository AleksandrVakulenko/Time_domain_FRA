
% FIXME: put in Fern module

function [amp, freq] = fft_plot(sig, fs, fig)
arguments
    sig
    fs
    fig = []
end
% [amp, freq] = fft_calc(sig, fs);
[amp, freq, phi, Limit] = fft_calc(sig, fs);

if isempty(fig)
    figure('position', [522 281 631 666])
else
    figure(fig)
end

subplot(2, 1, 1)
plot(freq, amp)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xlabel('f, Hz')
ylabel('amp')
yline(Limit)

subplot(2, 1, 2)
plot(freq, phi)
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
xlabel('f, Hz')
ylabel('phi, [deg]')
end

