

L = numel(Synth_signal);
% Window = hamming(L, "periodic");
Window = Win; % Nuttall


figure('position', [459 154 677 847])
subplot(3, 1, 1)
plot(Synth_time, Window)


Signal_w = Synth_signal.*Window';

subplot(3, 1, 2)
plot(Time, Signal_w)

subplot(3, 1, 3)
plot(Time, Synth_signal)




%%
clc

Time = Synth_time;
Signal = Signal_w;

[Time, Signal] = signal_cut_by_n_periods(Time, Signal, freq);

[Noise_amp, noise_floor] = noise_amp_calc(freq, Time, Signal, Fs);
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])


[fft_amp, fft_freq, ~, ~] = fft_calc(Signal, Fs);

F_list = [0.2 0.5 1 2 5 10 20 50 100 200 500 1000];
NF = noise_floor(F_list);
hold on
plot(fft_freq, fft_amp, '-b')
% plot(F_list, NF, '--xr', 'LineWidth', 1)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')



%%
clc

Time = Synth_time;
% Signal = Synth_signal + pinknoise(size(Synth_signal));
Signal = Synth_signal;

[Time, Signal] = signal_cut_by_n_periods(Time, Signal, freq);

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



