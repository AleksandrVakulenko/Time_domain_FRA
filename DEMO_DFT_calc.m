

% Try DFT

clc

Freq;
Harm = 1;
T_arr;
V_arr;
% V_arr_in = Residuals;

tic
[Amp_DFT, Phi_DFT] = DFT_single_freq(T_arr, V_arr, Harm*Freq);
toc

    Amp_real = mean(Props.amp);
    Phi_real = mean(Props.phi);

disp(['A = ' num2str(Amp_DFT) ' /(R) ' num2str(Amp_real) ' //(-) ' num2str(Amp_DFT-Amp_real)])
disp(['P = ' num2str(Phi_DFT) ' /(R) ' num2str(Phi_real) ' //(-) ' num2str(Phi_DFT-Phi_real)])

Model_sin = Amp_DFT*sin(2*pi*Harm*Freq*T_arr + Phi_DFT/180*pi);

figure
hold on
% plot(T_arr, V_arr, '-b');
plot(T_arr, V_arr - mean(V_arr), '-b');
plot(T_arr, Model_sin, '-r')


%%


fft_plot(V_arr, 10e3);


%%


fft_plot(Residuals, 10e3);













