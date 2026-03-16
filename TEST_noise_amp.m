
% NOTE:
% TEST for Noise_amp = noise_amp_calc(freq, Time, Signal, Fs)

clc

Time = Synth_time;
Signal = Synth_signal;

[Time, Signal] = signal_cut_by_n_periods(Time, Signal, freq);

[Noise_amp, noise_floor] = noise_amp_calc(freq, Time, Signal, Fs);
disp(['Noise amp = ' num2str(Noise_amp*1e3, '%0.2f') ' mV'])


[fft_amp, fft_freq, ~, ~] = fft_calc(Signal, Fs);

F_list = [0.2 0.5 1 2 5 10 20 50 100 200 500 1000];
NF = noise_floor(F_list);
hold on
plot(fft_freq, fft_amp, '-b')
plot(F_list, NF, '--xr', 'LineWidth', 1)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

%% NOISE FIND FULL FREQ
clc


% [amp, phi, freq] = fft_plot(Synth_signal, Fs);

[fft_amp, fft_freq, fft_phi, fft_phi_limit] = fft_calc(Synth_signal, Fs);

% % FIXME: freq range???
% Time_length = Synth_time(end) - Synth_time(1);
% Freq_min = 1./Time_length;
% Freq_max = Fs/2;
% Freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), 10000);
% 
% Amp = zeros(size(Freq_list));
% for i = 1:numel(Freq_list)
%     Freq = Freq_list(i);
%     Amp(i) = DFT_single_freq(Synth_time, Synth_signal, Freq);
% end

figure
% plot(Freq_list, Amp)
plot(fft_freq, fft_amp)

set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')


%% FIND FFT BACKGROUND

clc
% freq = 44;

T_arr = Synth_time;


Signal_harms = [1:10]*freq;
Noise_harms = [1:20]*50;
Freq_exclude = [Signal_harms Noise_harms];
Freq_exclude = sort(Freq_exclude);


Time_length = T_arr(end) - T_arr(1);
Min_freq = 1/Time_length;
Max_freq = Fs/4;

if freq/Min_freq < 3
    Min_freq = Min_freq*3;
    xline(Min_freq)
end

Freq_exclude_log = log10(Freq_exclude);
Freq_list_log = (Freq_exclude_log(1:end-1) + Freq_exclude_log(2:end))/2;

if Min_freq*2 < freq
    Freq_list_prev = 10.^linspace(log10(Min_freq*2), log10(freq*0.8), 10);
    Freq_list_log_prev = log10(Freq_list_prev);
    Freq_list_log = [Freq_list_log_prev Freq_list_log];
end

Freq_list = 10.^Freq_list_log;

Freq_list(Freq_list < Min_freq) = [];
Freq_list(Freq_list > Max_freq) = [];

[Bad_num, Freq_list] = exclude_bad_freq(Freq_list, Freq_exclude);

% get fft amp on Freq_list grid
Amp = 10.^interp1(fft_freq, log10(fft_amp), Freq_list);
% freq_ext = 10.^linspace(log10(0.1), log10(10), 100);
% Amp_ext = 10.^interp1(fft_freq, log10(fft_amp), freq_ext);
% -----------------------------

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);
fitres_bg = fit(Freq_log', Amp_log', 'poly1');

hold on
plot(Freq_list, Amp, 'o', 'markersize', 7, 'MarkerFaceColor', 'g')
plot(fft_freq, fft_amp, '-b')
% plot(freq_ext, Amp_ext, '.-r')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')


%% NOISE FIND ON 50 Hz harms 1:20
clc


% [amp, phi, freq] = fft_plot(Synth_signal, Fs);

% [amp, freq, phi, phi_limit] = fft_calc(Synth_signal, Fs);


Freq_list = [1:20]*50;


% FIXME: use fft here (as above)?
% Amp = find_spectrum_amps(Synth_time, Synth_signal, Freq_list);
Amp = 10.^interp1(fft_freq, log10(fft_amp), Freq_list);

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);

spec_bg = 10.^feval(fitres_bg, Freq_log)';

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



%%


noise_floor = @(f) 10.^feval(fitres_bg, log10(f))';

F_list = [0.2 0.5 1 2 5 10 20 50 100 200 500 1000];
NF = noise_floor(F_list);

hold on
plot(F_list, NF, '-xr', 'LineWidth', 2)












%%


function Amp = find_spectrum_amps(Time, Signal, Freq_list)
    Amp = zeros(size(Freq_list));
    for i = 1:numel(Freq_list)
        F = Freq_list(i);
        Scale = 1.02; % FIXME: magic constant
        LB = F/Scale;
        HB = F*Scale;
        Freq_list_part = 10.^linspace(log10(LB), log10(HB), 20);
    
        Amp_part = zeros(size(Freq_list_part));
        for k = 1:numel(Freq_list_part)
            Freq = Freq_list_part(k);
            Amp_part(k) = DFT_single_freq(Time, Signal, Freq);
        end
        Amp(i) = max(Amp_part);
    end
end
