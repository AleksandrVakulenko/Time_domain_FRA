

% Try DFT

clc

Freq;
Harm = 1;
T_arr;
V_arr_in = V_arr;
% V_arr_in = Residuals;

tic
Sin = sin(2*pi*Harm*Freq*T_arr);
Cos = cos(2*pi*Harm*Freq*T_arr);

Sin = V_arr_in.*Sin;
Cos = V_arr_in.*Cos;

% hold on
% plot(T_arr, Sin)
% plot(T_arr, Cos)

Sin_sum = mean(Sin);
Cos_sum = mean(Cos);

Cplx = 1i*Cos_sum + 1*Sin_sum;

Amp_DFT = abs(Cplx)*2;
Phi_DFT = angle(Cplx)/pi*180;

Amp_real = mean(Props.amp);
Phi_real = mean(Props.phi);
toc

disp(['A = ' num2str(Amp_DFT) ' /(R) ' num2str(Amp_real) ' //(-) ' num2str(Amp_DFT-Amp_real)])
disp(['P = ' num2str(Phi_DFT) ' /(R) ' num2str(Phi_real) ' //(-) ' num2str(Phi_DFT-Phi_real)])

Model_sin = Amp_DFT*sin(2*pi*Harm*Freq*T_arr + Phi_DFT);

figure
hold on
% plot(T_arr, V_arr, '-b');
plot(T_arr, V_arr_in - mean(V_arr_in), '-b');
plot(T_arr, Model_sin, '-r')


%%


fft_plot(V_arr, 10e3);


%%


fft_plot(Residuals, 10e3);













