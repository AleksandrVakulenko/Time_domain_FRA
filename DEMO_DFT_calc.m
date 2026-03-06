

% Try DFT

clc

Freq;
T_arr;
V_arr;


Sin = sin(2*pi*Freq*T_arr);
Cos = cos(2*pi*Freq*T_arr);

Sin = V_arr.*Sin;
Cos = V_arr.*Cos;

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


disp(['A = ' num2str(Amp_DFT) ' // ' num2str(Amp_real) ' // ' num2str(Amp_DFT-Amp_real)])
disp(['P = ' num2str(Phi_DFT) ' // ' num2str(Phi_real) ' // ' num2str(Phi_DFT-Phi_real)])

Model_sin = Amp_DFT*sin(2*pi*Freq*T_arr + Phi_DFT);

figure
hold on
% plot(T_arr, V_arr, '-b');
plot(T_arr, V_arr - mean(V_arr), '-b');
plot(T_arr, Model_sin, '-r')





