

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


fit_viewer.show_result_debug(Result_1, Result_2, freq,  R_Scale)

























