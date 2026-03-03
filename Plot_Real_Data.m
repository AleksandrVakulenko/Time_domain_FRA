
addpath('..\')

load('..\..\..\Results\test_results_2026_01_22_03\0001.mat')

load('Filter_LF_FIR_2_30.mat')

% plot(Time_data, Current)

Time_data = Time_data - Time_data(1);

Scale = max(Current);

Signal = Current/Scale;


[A, P, C, D, fitresult, gof] = sin_fit_f(Time_data, Signal, freq);

Sig_model = feval(fitresult, Time_data)';

Noise_sig = Signal - Sig_model;
Noise_sig = Noise_sig*Scale;


Noise_sig_f = filter(Hd, Noise_sig);


Noise_gen = current_noise_gen(Time_data);

figure
hold on
% plot(Time_data, Noise_sig*1e12)
% plot(Time_data, Noise_sig_f*1e12)
% plot(Time_data, Sig_model)
% plot(Time_data, Signal)
plot(Time_data, Sig_model*Scale + Noise_gen)
plot(Time_data, Current)


%%


[fft_amp_f, ~] = fft_calc(Noise_sig_f, 10e3);
[fft_amp, fft_freq] = fft_calc(Noise_sig, 10e3);
figure
hold on
plot(fft_freq, fft_amp)
plot(fft_freq, fft_amp_f)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')


[Peak_freq, Peak_amp] = fft_noise_peak_find(fft_amp, fft_freq);

plot(Peak_freq, Peak_amp, 'rx')



%%



Signal_Noise = current_noise_gen(Time_data);

figure
hold on
plot(Time_data, Signal_Noise)
plot(Time_data, Noise_sig)
% 200 10e3 1e6 100e6 10e9 1e12



% [fft_amp_2, ~] = fft_calc(Signal_Noise, 10e3);
% [fft_amp, fft_freq] = fft_calc(Noise_sig, 10e3);
figure
hold on
fft_plot(Signal_Noise, 10e3);
fft_plot(Noise_sig, 10e3);



% end













