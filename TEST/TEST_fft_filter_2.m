

clc

Fs = 10e3; % [1/s]
Duration = 1; % [s]
Noise_scale = 1;


Time = 0:1/Fs:Duration-1/Fs;



% Signal = zeros(size(Time));
% Signal = 1.0*sin(2*pi*10*Time + 10/180*pi) + ...
%          0.5*sin(2*pi*50*Time + 45/180*pi);
Signal_clear = 1*sin(2*pi*10*Time + 10/180*pi);


Noise = test_gen.current_noise_gen(Time)/3e-10*Noise_scale;
% Noise = 0.05*sin(2*pi*50*Time + 10/180*pi);
% Noise = 2*(rand(size(Time))-0.5)*0.1;
Synth_signal = Signal_clear + Noise;
% Synth_signal = Signal_clear;

% Poly = @(x) 1*x + 0.002*x.^2 + 0.005*x.^3 - 0.01*x.^4 + 0.05*x.^5;
Poly = @(x) 1*x + 0.002*x.^2 - 0.01*x.^4 + 0.05*x.^6;

Synth_signal_2 = Poly(Synth_signal);

Signal_filt = fft_band_rejection(Synth_signal, Fs, -80, 11, []);

figure
hold on
plot(Time, Synth_signal, '-b')
plot(Time, Synth_signal_2, '-r')
plot(Time, Signal_filt, '--r')
plot(Time, Signal_clear, '.g')


%%

fft_plot([Synth_signal; Synth_signal_2]', Fs, 1e-6);

fft_plot(Signal_filt, Fs);