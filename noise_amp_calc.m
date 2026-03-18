function [Noise_amp, noise_floor] = noise_amp_calc(freq, Time, Signal, Fs, Min_freq)
arguments
    freq
    Time
    Signal
    Fs
    Min_freq = [];
end

[Time, Signal] = signal_cut_by_n_periods(Time, Signal, freq);

% NOISE FIND FULL FREQ --------------------

[fft_amp, fft_freq, ~, ~] = fft_calc(Signal, Fs);


% FIND FFT BACKGROUND ---------------------

Signal_harms = [1:10]*freq;
Noise_harms = [1:20]*50;
Freq_exclude = [Signal_harms Noise_harms];
Freq_exclude = sort(Freq_exclude);


Time_length = Time(end) - Time(1);
if isempty(Min_freq)
    Min_freq = 1/Time_length;
end
Max_freq = Fs/2;

if freq/Min_freq < 3
    Min_freq = Min_freq*3;
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

[~, Freq_list] = exclude_bad_freq(Freq_list, Freq_exclude);

% get fft amp on Freq_list grid
Amp = 10.^interp1(fft_freq, log10(fft_amp), Freq_list);

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);
fitres_bg = fit(Freq_log', Amp_log', 'poly1');

% NOISE FIND ON 50 Hz harms 1:20 --------------

Freq_list = [1:20]*50;

Amp = 10.^interp1(fft_freq, log10(fft_amp), Freq_list);

Freq_log = log10(Freq_list);

spec_bg = 10.^feval(fitres_bg, Freq_log)';

Amp2 = Amp - spec_bg;
Amp2(Amp2 < 0) = 0;

Noise_amp = sqrt(sum(Amp2.^2));

noise_floor = @(f) 10.^feval(fitres_bg, log10(f))';

end










