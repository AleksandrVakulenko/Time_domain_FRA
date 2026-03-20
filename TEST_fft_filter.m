
% NOTE: test file for fft_band_rejection function

clc

Fs = 10e3; % [1/s]
Duration = 5; % [s]
Noise_scale = 1;


Time = 0:1/Fs:Duration-1/Fs;



% Signal = zeros(size(Time));
% Signal = 1.0*sin(2*pi*10*Time + 10/180*pi) + ...
%          0.5*sin(2*pi*50*Time + 45/180*pi);
Signal_clear = 0.1*sin(2*pi*10*Time + 10/180*pi)+1;


Noise = test_gen.current_noise_gen(Time)/3e-10*Noise_scale;
% Noise = 0.05*sin(2*pi*50*Time + 10/180*pi);
% Noise = 2*(rand(size(Time))-0.5)*0.1;
Synth_signal = Signal_clear + Noise;


Signal_filt = fft_band_rejection(Synth_signal, Fs, -80, 11, []);

hold on
plot(Time, Synth_signal, '-b')
plot(Time, Signal_filt, '--r')
% plot(Time, Signal, '.g')
plot(Time, Signal_clear, '.g')


% plot(abs((FFT)))

%%

clc

Signal_filt = fft_band_rejection(Synth_signal, Fs, -80, 0.00, 0.04);
Signal_filt = fft_band_rejection(Signal_filt, Fs, -80, 0.08, []);

hold on
plot(Synth_time, Synth_signal, '-b')
plot(Synth_time, Signal_filt, '--r')

DFT_single_freq(Synth_time, Synth_signal, 0.05)
DFT_single_freq(Synth_time, Signal_filt, 0.05)


%%

clc

fft_plot(Synth_signal, Fs);
fft_plot(Signal_filt, Fs);






















