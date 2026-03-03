
function [Peak_freq, Peak_amp] = fft_noise_peak_find(fft_amp, fft_freq)


[Max_peak, Max_peak_loc] = max(fft_amp);

Peak_tr = 0.005*Max_peak;

[pks, locs] = findpeaks(fft_amp, 'MinPeakHeight', Peak_tr);
locs(locs<Max_peak_loc) = [];

Pk_ratios = fft_freq(locs)/fft_freq(Max_peak_loc);

Div_from_num = (Pk_ratios - round(Pk_ratios))./round(Pk_ratios);

range = abs(Div_from_num)*100 > 0.1; % [%]

locs(range) = [];

% plot(Div_from_num*100, '.')

Peak_freq = fft_freq(locs);
Peak_amp = fft_amp(locs);

end