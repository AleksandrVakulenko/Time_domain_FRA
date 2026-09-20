
clc

Time_length = .91;
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


[Time_in, Signal_in] = gen_insert(0.6);
Signal_pure = insert(Time, Signal_pure, Time_in, Signal_in, Time_length*0.65);
Signal_pure = insert(Time, Signal_pure, Time_in, Signal_in, Time_length*0.4);

Signal = Signal_pure + Noise + Background + Signal_H2 + Signal_H3;

Result = TDFRA_TDFRA_fit_core.DFT_estimation(Time, Signal, Period);
Result_H2 = TDFRA_TDFRA_fit_core.DFT_estimation(Time, Signal, Period/2);
Result_H3 = TDFRA_TDFRA_fit_core.DFT_estimation(Time, Signal, Period/3);

M_amp = Result.amp;
M_phi = Result.phi;
M_bg = Result.bg;

M_amp_H2 = Result_H2.amp;
M_phi_H2 = Result_H2.phi;

M_amp_H3 = Result_H3.amp;
M_phi_H3 = Result_H3.phi;


Model_signal = M_amp*sin(2*pi*Freq*Time + M_phi/180*pi) + M_bg + ...
               M_amp_H2*sin(2*pi*Freq*2*Time + M_phi_H2/180*pi) + ...
               M_amp_H3*sin(2*pi*Freq*3*Time + M_phi_H3/180*pi);





%

Estimations = TDFRA_TDFRA_fit_core.Estimation_type.empty();

time_conf = 'fine';

% T_arr = Ch_data.time;
% V_arr = Ch_data.voltage;
% Overload = Ch_data.overload;
% Outliers_range = Ch_data.outliers_range;
% Outliers_range = TDFRA_TDFRA_fit_core.uppend_outliers(T_arr, Outliers_range);
% Fs = Ch_data.fs;

Outliers_range = false(size(Signal));
Period_counter = Time_length/Period;
Overload.count = 0;

Time_profile = "common";
Harm_profile = "common";

Ch_data = TDFRA_TDFRA_fit_core.Ch_data_type(Time, Signal, Outliers_range, Overload, ...
    Estimations, [], [], Fs, Freq, Period_counter);


[Result_new, Residuals_new, DEBUG_new] = fit_refit_one_ch(Ch_data, ...
    Freq, [], Time_profile, Harm_profile, 1);


Signal_fitted = TDFRA_fit_viewer.calc_fitted_signal(Result_new, Time, false);


Output = TDFRA_fit_viewer.calc_output(Result_new, []);

Fit_amp = Output.amp
Fit_phi = Output.phi
Output.bg


%

figure
hold on
plot(Time, Signal, '-b', 'LineWidth', 2)
plot(Time, Model_signal, '--r', 'LineWidth', 1.2)
plot(Time, Signal_fitted, '-k', 'LineWidth', 2)
xlabel('t, s')
ylabel('ch1, V')
grid on
grid minor
box on





Fit_amp_err = (Fit_amp/Amp_sig - 1)*100;
Fit_phi_err = Fit_phi - Phase_sig; 

DFT_amp_err = (M_amp/Amp_sig - 1)*100;
DFT_phi_err = M_phi - Phase_sig;


disp('--------------------------------')
disp(['Period_counter = ' num2str(Period_counter, '%0.3f')])
disp(' ')
disp(['Fit_amp_err = ' num2str(Fit_amp_err, '%0.2f') ' %'])
disp(['Fit_phi_err = ' num2str(Fit_phi_err, '%0.2f') ' deg'])
disp(' ')
disp(['DFT_amp_err = ' num2str(DFT_amp_err, '%0.2f') ' %'])
disp(['DFT_phi_err = ' num2str(DFT_phi_err, '%0.2f') ' deg'])
disp(' ')








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



