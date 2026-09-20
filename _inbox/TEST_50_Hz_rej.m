
clc

Time_length = 0.91;
Fs = 1000;

Amp_sig = 1;
Freq = 2;
Phase_sig = 35;
Noise_amp = 0.02;

Amp_H2 = 0.1;
Phase_H2 = 70;

Amp_H3 = 0.05;
Phase_H3 = 11;

Period = 1/Freq;
Time = 0 : 1/Fs : Time_length - 1/Fs;

% Amp_modulation = ones(size(Time));
Amp_modulation = 1-exp(-Time/0.05)*0.2;

Signal_pure = Amp_modulation.*Amp_sig.*sin(2*pi*Freq*Time + Phase_sig/180*pi);
Signal_H2 = Amp_modulation.*Amp_H2.*sin(2*pi*Freq*2*Time + Phase_H2/180*pi);
Signal_H3 = Amp_modulation.*Amp_H3.*sin(2*pi*Freq*3*Time + Phase_H3/180*pi);

Background = (Time/Time_length).^2*0.5;

Noise = normrnd(0, Noise_amp, size(Time));

Noise_50Hz = 0.2*sin(2*pi*50*Time);

[Time_in, Signal_in] = gen_insert(0.6);
% Signal_pure = insert(Time, Signal_pure, Time_in, Signal_in, Time_length*0.65);
% Signal_pure = insert(Time, Signal_pure, Time_in, Signal_in, Time_length*0.4);

% Signal = Signal_pure + Noise + Background + Signal_H2 + Signal_H3 + Noise_50Hz;
Signal = Signal_pure + Noise_50Hz;

Signal_filt = fft_band_rejection(Signal, Fs, -60, 49, 51);


figure
hold on
plot(Time, Signal, '-b', 'LineWidth', 0.1)
plot(Time, Signal_filt, '-r', 'LineWidth', 1)
% plot(Time, Signal_fitted, '-k', 'LineWidth', 2)
xlabel('t, s')
ylabel('ch1, V')
grid on
grid minor
box on











%%


function [Time, Signal] = gen_insert(Amp)

Freq = 60;

Time_length = 6/Freq;
Fs = 1000;

% Amp = 0.1;
Noise_amp = 0.00;

Time = 0 : 1/Fs : Time_length - 1/Fs;

Signal = Amp*exp(-Time/(0.05*Time_length)).*sin(2*pi*Freq*Time);

Noise = normrnd(0, Noise_amp, size(Time));

Signal = Signal + Noise;


end



function S_basic = insert(T_basic, S_basic, T_in, S_in, Time_moment)

range = T_basic > Time_moment;

ind = find(range);
ind = ind(1);

N = numel(T_in);

S_basic(ind:ind+N-1) = S_basic(ind:ind+N-1) + S_in;

end



