

%% Measure by LCR

Aster = Aster_dev(3);

err = [];
try
    Aster.set_connection_mode("LCR");
catch err
    delete(Aster);
    rethrow(err)
end

if isempty(err)
    delete(Aster);
end



%% Get data from Aster
% FIXME: [in Aster_dev:] read_data forces dev to measure single point

Voltage_level = 0.5; % [V]
Offset_level = 0; % [V]
freq = 4; % [Hz]
Meas_duration = 12; % [s]
Cap_pred = 100e-9; % [F]


Res_pred = 1/(2*pi*freq*Cap_pred); % [Ohm]
Current_pred = Voltage_level/Res_pred; % [A]

Current_pred = Voltage_level/1.25e3;

clc
Gen = AFG1022_dev();
Gen.set_func("sin");
Gen.set_amp(Voltage_level, "amp");
Gen.set_freq(freq);
Gen.set_offset(Offset_level);

Aster = Aster_dev(3);
Aster.set_connection_mode("I2V");
Sense = Aster.set_sensitivity(Current_pred);
disp('Range: ');
fit_viewer.print_res(5/Sense);

Gen.initiate();
Aster.initiate();
if Sense < 1e-11
    adev_utils.Wait(10, 'Init pause ...');
else
    pause(0.2);
end

Aster.CMD_data_stream(1);

adev_utils.Wait(Meas_duration, 'Wait for data gathering ...');


pause(0.05);


% [Time_arr, V1_arr, V2_arr] = Aster.get_CV();
[Time_arrA, V1_arrA, V2_arrA, R_Scale] = Aster.get_VV();
Aster.CMD_data_stream(0);

Aster.terminate();
Gen.terminate();
delete(Aster);
delete(Gen);

% V1_arr = V1_arr - mean(V1_arr);
% Time_arrA = Time_arrA - Time_arrA(1);
V2_arrA = -V2_arrA;

%

figure('position', [303 235 768 797])

subplot(2, 1, 1)
hold on
plot(Time_arrA, V1_arrA, '-b')


subplot(2, 1, 2)
hold on
plot(Time_arrA, V2_arrA, '-b')

%% Load data to FRA_dummy_dev

Save_data_flag = false;
% freq = 3.131;
Fs = 10e3;
Synth_time = Time_arrA;
Synth_signal_1 = V1_arrA;
Synth_signal_2 = V2_arrA;


FRA_dev = test_gen.FRA_dummy_dev(Synth_time, Synth_signal_1, Synth_signal_2);


%% Show fit result


show_result_debug(Result_1, Result_2, freq,  R_Scale)


















function Result = show_result_debug(Result_1, Result_2, freq, R_Scale)

Output = fit_viewer.calc_output(Result_1, []);
Volt1 = Output.amp;
Volt1_err = Output.amp_err;
P1 = Output.phi;
P1e = Output.phi_err;

Output = fit_viewer.calc_output(Result_2, []);
Volt2 = Output.amp;
Volt2_err = Output.amp_err;
P2 = Output.phi;
P2e = Output.phi_err;


% clc

Cur = Volt2*R_Scale;
Cur_err = Volt2_err*R_Scale;
Res = Volt1/Cur;
Res_err = sqrt(((1/Cur)*Volt1_err)^2 + ((-Volt1/Cur^2)*Cur_err)^2);
Phase_diff = (P1) - (P2);
Phase_diff_error = sqrt(P1e^2 + P2e^2);

if Phase_diff > 180
    Phase_diff = Phase_diff - 360;
end
if Phase_diff < -180
    Phase_diff = Phase_diff + 360;
end

% Res_cplx = Res*cos(Phase_diff/180*pi) + Res*1i*sin(Phase_diff/180*pi);
% Res
% Res_r = real(Res_cplx)
% Res_i = -imag(Res_cplx)


% Cap = 1/(6.28*freq*Res_i);
% Cap_2 = 1/(6.28*freq*(Res+Res_err))
% Cap_3 = 1/(6.28*freq*(Res-Res_err))
% Cap_err = 1/(6.28*freq*Res_i^2)*Res_err;

Zfull = Res*cos(Phase_diff/180*pi) + Res*1i*sin(Phase_diff/180*pi);


[C_par, R_par] = fit_viewer.RC_calc_parallel(Zfull, freq);
[C_ser, R_ser] = fit_viewer.RC_calc_series(Zfull, freq);



fit_viewer.print_f_dev(Result_1.f_dev_ppm, Result_1.f_dev_ppm_err);
fit_viewer.print_f_dev(Result_2.f_dev_ppm, Result_2.f_dev_ppm_err);

disp(' ')

fit_viewer.print_res(Res, Res_err)
% Cap = 1/(6.28*freq*Res);
% Cap_err = 1/(6.28*freq*Res^2)*Res_err;
% print_cap(Cap, Cap_err)
fit_viewer.print_phi(Phase_diff, Phase_diff_error)

disp(' ')

disp('Parallel:')
fit_viewer.print_cap(C_par)
fit_viewer.print_res(R_par)

disp(' ')

disp('Series:')
fit_viewer.print_cap(C_ser)
fit_viewer.print_res(R_ser)

disp(' ')

warning('|R| may be calculated incorrectly!')


Result.res_abs = Res;
Result.res_abs_err = Res_err;

Result.phi = Phase_diff;
Result.phi_err = Phase_diff_error;

Result.cap_par = C_par;
Result.r_scale = R_Scale;
Result.current = Cur;
Result.current_error = Cur_err;
Result.voltage = Volt1;
Result.voltage_error = Volt1_err;


end








