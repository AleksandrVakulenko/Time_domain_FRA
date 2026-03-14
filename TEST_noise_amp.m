
% NOTE:
% TEST for Noise_amp = noise_amp_calc(freq, Time, Signal, Fs)

clc

Noise_amp = noise_amp_calc(freq, Synth_time, Synth_signal, Fs);
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])






%% NOISE FIND FULL FREQ
clc


% [amp, phi, freq] = fft_plot(Synth_signal, Fs);

[amp, freq, phi, phi_limit] = fft_calc(Synth_signal, Fs);


Freq_list = 10.^linspace(log10(10), log10(2000), 10000);

Amp = zeros(size(Freq_list));
for i = 1:numel(Freq_list)
    Freq = Freq_list(i);
    Amp(i) = DFT_single_freq(Synth_time, Synth_signal, Freq);

end

figure
plot(Freq_list, Amp)

set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')


%% FIND FFT BACKGROUND

clc
freq = 44;

Signal_harms = [1:10]*freq;
Noise_harms = [1:20]*50;
Freq_exclude = [Signal_harms Noise_harms];
Freq_exclude = sort(Freq_exclude);


Time_length = T_arr(end) - T_arr(1);
% Min_freq = 1/Time_length*10;
Min_freq = 50;
Max_freq = Fs/10;

Freq_exclude_log = log10(Freq_exclude);
Freq_list_log = (Freq_exclude_log(1:end-1) + Freq_exclude_log(2:end))/2;

Freq_list = 10.^Freq_list_log;

Freq_list(Freq_list < Min_freq) = [];
Freq_list(Freq_list > Max_freq) = [];

[Bad_num, Freq_list] = exclude_bad_freq(Freq_list, Freq_exclude);

Amp = find_spectrum_amps(Synth_time, Synth_signal, Freq_list);

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);
fitres_bg = fit(Freq_log', Amp_log', 'poly1');

hold on
plot(Freq_list, Amp, 'o', 'markersize', 7, 'MarkerFaceColor', 'g')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')


%% NOISE FIND ON 50 Hz harms 1:20
clc


% [amp, phi, freq] = fft_plot(Synth_signal, Fs);

[amp, freq, phi, phi_limit] = fft_calc(Synth_signal, Fs);


Freq_list = [1:20]*50;

% Freq_list = 10.^linspace(log10(10), log10(2000), 1000);

Amp = find_spectrum_amps(Synth_time, Synth_signal, Freq_list);

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);

spec_bg = 10.^feval(fitres_bg, Freq_log)';

% Amp_log = Amp_log - spec_bg';
% Amp_log(Amp_log < 0) = -Inf;

Amp2 = Amp - spec_bg;
Amp2(Amp2 < 0) = 0;

Noise_amp = sqrt(sum(Amp2.^2));
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])


% figure
hold on
% plot(Freq_list, Amp, 'o', 'markersize', 7, 'MarkerFaceColor', 'r')
plot(Freq_list, Amp2, 'o', 'markersize', 7, 'MarkerFaceColor', 'c')
% plot(Freq_list, 10.^(spec_bg'), '-', 'markersize', 7, 'MarkerFaceColor', 'r')

set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')




























