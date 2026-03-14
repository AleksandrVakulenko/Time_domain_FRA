function Noise_amp = noise_amp_calc(freq, Time, Signal, Fs)

Signal_harms = [1:10]*freq;
Noise_harms = [1:20]*50;
Freq_exclude = [Signal_harms Noise_harms];
Freq_exclude = sort(Freq_exclude);


Time_length = Time(end) - Time(1); % NOTE: used on line below
% Min_freq = 1/Time_length*10; % FIXME: this OR line below
Min_freq = 50; % FIXME: this OR line above
Max_freq = Fs/10;

Freq_exclude_log = log10(Freq_exclude);
Freq_list_log = (Freq_exclude_log(1:end-1) + Freq_exclude_log(2:end))/2;

Freq_list = 10.^Freq_list_log;

Freq_list(Freq_list < Min_freq) = [];
Freq_list(Freq_list > Max_freq) = [];

[~, Freq_list] = exclude_bad_freq(Freq_list, Freq_exclude);

Amp = find_spectrum_amps(Time, Signal, Freq_list);

Amp_log = log10(Amp);
Freq_log = log10(Freq_list);
fitres_bg = fit(Freq_log', Amp_log', 'poly1');



% NOISE FIND ON 50 Hz harms 1:20

Freq_list = [1:20]*50;

Amp = find_spectrum_amps(Time, Signal, Freq_list);
Freq_log = log10(Freq_list);

spec_bg = 10.^feval(fitres_bg, Freq_log)';

Amp2 = Amp - spec_bg;
Amp2(Amp2 < 0) = 0;

Noise_amp = sqrt(sum(Amp2.^2));

end