
% FIXME: do we need this test file here?

% NOTE: use for future experiments

% NOTE:
% Nuttall window Freq limit finder:

%% Number of points by freq limit (For Nuttall window)
F_lim = 1; % [Hz]
Fs = 10e3; % [1/s]
pn = round(10.^(0.765 - log10(F_lim/Fs))) % [points]
Dur = pn/Fs % [s]

%% Freq limit by number of points (For Nuttall window)

Fs = 10e3; % [1/s]
F_lim = Fs*(10.^(-1*log10(pn) + 0.765));


%% Main part

Window = nuttallwin(numel(Synth_signal)); % Nuttall
Time = Synth_time;

figure('position', [459 154 677 847])
subplot(3, 1, 1)
plot(Synth_time, Window)

Win_scale = 2.7521;
Signal_w = Synth_signal.*Window'*Win_scale;

subplot(3, 1, 2)
plot(Time, Signal_w)

subplot(3, 1, 3)
plot(Time, Synth_signal)


Freq_limit_1 = 6.86e-5*Fs; % [Hz]
Freq_limit_2 = 1/(Time(end)-Time(1)); % [Hz]
Freq_limit_1
Freq_limit_2
%% Signal * Window
clc

Time = Synth_time;
Signal = Signal_w;

[Time, Signal] = fit_core.signal_cut_by_n_periods(Time, Signal, freq);

% For Nuttall window
Fs = 10e3; % [1/s]
F_lim = Fs*(10.^(-1*log10(numel(Signal)) + 0.765));
%

[Noise_amp, noise_floor] = noise_amp_calc(freq, Time, Signal, Fs, F_lim);
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])


[fft_amp, fft_freq, fft_phi, ~] = fft_calc(Signal, Fs, 5e-6);

F_list = [0.2 0.5 1 2 5 10 20 50 100 200 500 1000];
NF = noise_floor(F_list);

figure
hold on
plot(fft_freq, fft_amp, '-b')
plot(F_list, NF, '--xr', 'LineWidth', 1)
ylabel('amp, V')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xline(F_lim)

% figure
% hold on
% plot(fft_freq, fft_phi, '-b')
% ylabel('phi, deg')
% set(gca, 'xscale', 'log')
% % set(gca, 'yscale', 'log')
% xline(F_lim)
%% Signal only
clc

Time = Synth_time;
% Signal = Synth_signal + pinknoise(size(Synth_signal));
Signal = Synth_signal;

[Time, Signal] = fit_core.signal_cut_by_n_periods(Time, Signal, freq);

[Noise_amp, noise_floor] = noise_amp_calc(freq, Time, Signal, Fs);
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])


[fft_amp, fft_freq, ~, ~] = fft_calc(Signal, Fs);

F_list = [0.2 0.5 1 2 5 10 20 50 100 200 500 1000];
NF = noise_floor(F_list);

figure
hold on
plot(fft_freq, fft_amp, '-b')
% plot(fft_freq, fft_amp./noise_floor(fft_freq), '-c')
plot(F_list, NF, '--xr', 'LineWidth', 1)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xline(Freq_limit_1)


%% Window only
clc

Time = Synth_time;
Signal = Win;

[Time, Signal] = fit_core.signal_cut_by_n_periods(Time, Signal, freq);
[fft_amp, fft_freq, ~, ~] = fft_calc(Signal, Fs);



figure
hold on
plot(fft_freq, fft_amp, '-b')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xline(Freq_limit_1)




