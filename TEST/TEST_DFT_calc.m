

% Try DFT

clc

Fs = 10e3;
Time = 0:1/Fs:10;

Noise = 2*(rand(size(Time))-0.5)*0.02;

Signal = 1.0*sin(2*pi*1*Time + 20/180*pi) + ...
         0.5*sin(2*pi*50*Time + 45/180*pi) + ...
         0.02*sin(2*pi*10*Time + 125/180*pi) + ...
         Noise;
% V_arr_in = Residuals;

tic
[Amp_DFT, Phi_DFT] = DFT_single_freq(Time, Signal, 1);
disp(['A = ' num2str(Amp_DFT) ' V  |  P = ' num2str(Phi_DFT) ' deg'])
[Amp_DFT, Phi_DFT] = DFT_single_freq(Time, Signal, 50);
disp(['A = ' num2str(Amp_DFT) ' V  |  P = ' num2str(Phi_DFT) ' deg'])
[Amp_DFT, Phi_DFT] = DFT_single_freq(Time, Signal, 10);
disp(['A = ' num2str(Amp_DFT) ' V  |  P = ' num2str(Phi_DFT) ' deg'])
toc



fft_plot(Signal, Fs, 0.001);














