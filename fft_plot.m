
% FIXME: put in Fern module

function [amp, freq] = fft_plot(sig, fs, phi_limit)
arguments
    sig
    fs
    phi_limit = []
%     fig = []
end
% [amp, freq] = fft_calc(sig, fs);
[amp, freq, phi, phi_limit] = fft_calc(sig, fs, phi_limit);

figure('position', [522 281 631 666])
% if isempty(fig)
%     figure('position', [522 281 631 666])
% else
%     figure(fig)
% end

subplot(2, 1, 1)
plot(freq, amp)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xlabel('f, Hz')
ylabel('amp')
if ~isempty(phi_limit)
    yline(phi_limit)
end

subplot(2, 1, 2)
plot(freq, phi)
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
xlabel('f, Hz')
ylabel('phi, [deg]')
end

