
%% Run once

Fern.load('aDevice')
Fern.load('Common') 

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

Voltage_level = 2; % [V]
Offset_level = 0; % [V]
freq = 200; % [Hz]
Meas_duration = 0.34; % [s]
Cap_pred = 100e-9; % [F]


Res_pred = 1/(2*pi*freq*Cap_pred); % [Ohm]
Current_pred = Voltage_level/Res_pred; % [A]

Current_pred = 2/2e3;

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
print_res(5/Sense);

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



Output = calc_output(Result_1, []);
Volt1 = Output.amp;
Volt1_err = Output.amp_err;
P1 = Output.phi;
P1e = Output.phi_err;

Output = calc_output(Result_2, []);
Volt2 = Output.amp;
Volt2_err = Output.amp_err;
P2 = Output.phi;
P2e = Output.phi_err;


clc

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
[C_par, R_par] = RC_calc_parallel(Zfull, freq);
[C_ser, R_ser] = RC_calc_series(Zfull, freq);



print_f_dev(Result_1.f_dev_ppm, Result_1.f_dev_ppm_err);
print_f_dev(Result_2.f_dev_ppm, Result_2.f_dev_ppm_err);

disp(' ')

print_res(Res, Res_err)
% Cap = 1/(6.28*freq*Res);
% Cap_err = 1/(6.28*freq*Res^2)*Res_err;
% print_cap(Cap, Cap_err)
print_phi(Phase_diff, Phase_diff_error)

disp(' ')

disp('Parallel:')
print_cap(C_par)
print_res(R_par)

disp(' ')

disp('Series:')
print_cap(C_ser)
print_res(R_ser)

disp(' ')

warning('|R| may be calculated incorrectly!')






function [C_par, R_par] = RC_calc_parallel(Z, Freq)
% FIXME: add errors
Abs_sq = real(Z)^2 + imag(Z)^2;
R_par = Abs_sq/real(Z);
C_par = -imag(Z)/(2*pi*Freq * Abs_sq);
end

function [C_ser, R_ser] = RC_calc_series(Z, Freq)
% FIXME: add errors
R_ser = real(Z);
C_ser = -1/(2*pi*Freq*imag(Z));
end



function print_res(Res, Res_err)
arguments
    Res
    Res_err = []
end
    if abs(Res) >= 1e12
        unit = 'TOhm';
        scale = 1e-12;
    elseif abs(Res) >= 1e9
        unit = 'GOhm';
        scale = 1e-9;
    elseif abs(Res) >= 1e6
        unit = 'MOhm';
        scale = 1e-6;
    elseif abs(Res) >= 1e3
        unit = 'kOhm';
        scale = 1e-3;
    else
        unit = 'Ohm';
        scale = 1;
    end
    
    if ~isempty(Res_err)
        disp(['|R| = ' num2str(Res*scale, '%0.4f') ' ± ' ...
            num2str(Res_err*scale, '%0.4f') ' ' unit])
    else
        disp(['|R| = ' num2str(Res*scale, '%0.4f') ' ' unit])
    end
end

function print_cap(Cap, Cap_err)
arguments
    Cap
    Cap_err = []
end
    if abs(Cap) < 1e-9
        unit = 'pF';
        scale = 1e12;
    elseif abs(Cap) < 1e-6
        unit = 'nF';
        scale = 1e9;
    elseif abs(Cap) < 1e-3
        unit = 'uF';
        scale = 1e6;
    elseif abs(Cap) < 1
        unit = 'mF';
        scale = 1e3;
    else
        unit = 'F';
        scale = 1;
    end

    if ~isempty(Cap_err)
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ± ' ...
        num2str(Cap_err*scale, '%0.3f') ' ' unit])
    else
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ' unit])
    end
end


function print_phi(Phi, Phi_err)
arguments
    Phi
    Phi_err = []
end
    if ~isempty(Phi_err)
        disp(['Phi = ' num2str(Phi, '%0.3f') ' ± ' ...
            num2str(Phi_err, '%0.3f') ' deg'])
    else
        disp(['Phi = ' num2str(Phi, '%0.3f') ' deg'])
    end
end

function print_f_dev(f_dev, f_dev_err)
    disp(['Δf = ' num2str(f_dev, '%0.1f') ' ± ' ...
        num2str(f_dev_err, '%0.1f') ' ppm'])
end







%% -------------------------------------------------------------


% FIXME: shared with TEST_look_at_res2.m and TEST_look_at_results.m
function Output = calc_output(Result_in, pps)
arguments
    Result_in
    pps = []
end
    T_start = Result_in.amp_poly.x(1);
    T_end = Result_in.amp_poly.x(3);
    Length = T_end - T_start;  % [s]

    flag = false;
    if isempty(pps)
        pps = 5;
        flag = true;
    else

    end

    N = round(Length * pps);
    if N < 1
        N = 5;
        flag = true;
    end
    T_arr = linspace(T_start, T_end, N);
    
    Amp = fit_viewer.poly3calc(Result_in.amp_poly, T_arr);
    Phi = fit_viewer.poly3calc(Result_in.phi_poly, T_arr);
    BG = fit_viewer.poly3calc(Result_in.bg_poly, T_arr);
    Amp_err = fit_viewer.poly3calc(Result_in.amp_poly_err, T_arr);
    Phi_err = fit_viewer.poly3calc(Result_in.phi_poly_err, T_arr);
    BG_err = fit_viewer.poly3calc(Result_in.bg_poly_err, T_arr);

    if flag
        Amp_err = sqrt(std(Amp)^2 + mean(Amp_err).^2);
        Phi_err = sqrt(std(Phi)^2 + mean(Phi_err).^2);
        BG_err = sqrt(std(BG)^2 + mean(BG_err).^2);

        Amp = mean(Amp);
        Phi = mean(Phi);
        BG = mean(BG);

        T_arr = mean(T_arr);
    end

    Output.amp = Amp;
    Output.amp_err = Amp_err;
    Output.phi = Phi;
    Output.phi_err = Phi_err;
    Output.bg = BG;
    Output.bg_err = BG_err;
    Output.time = T_arr;
    Output.freq = Result_in.freq;
    Output.debug_result = Result_in;
    Output.single_flag = flag;
end

