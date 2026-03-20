
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



%% Get data from Sater
% FIXME: [in Aster_dev:] read_data forces dev to measure single point

Voltage_level = 1; % [V]
freq = 0.1; % [Hz]
Cap_pred = 10e-12; % [F]

Res_pred = 1/(2*pi*freq*Cap_pred); % [Ohm]
Current_pred = Voltage_level/Res_pred; % [A]


clc
Aster = Aster_dev(3);

Aster.set_connection_mode("I2V");
Sense = Aster.set_sensitivity(Current_pred);
disp('Range: ');
res_print(5/Sense);

Aster.initiate();
if Sense < 1e-11
    adev_utils.Wait(10, 'Init pause ...');
else
    pause(0.2);
end

Aster.CMD_data_stream(1);

adev_utils.Wait(10*3, 'Wait for data gathering ...');


pause(0.05);


% [Time_arr, V1_arr, V2_arr] = Aster.get_CV();
[Time_arr, V1_arr, V2_arr, Scale] = Aster.get_VV();
Aster.CMD_data_stream(0);

Aster.terminate();
delete(Aster);

% V1_arr = V1_arr - mean(V1_arr);
Time_arr = Time_arr - Time_arr(1);
V2_arr = -V2_arr;

%

figure('position', [303 235 768 797])

subplot(2, 1, 1)
hold on
plot(Time_arr, V1_arr, '.-b')


subplot(2, 1, 2)
hold on
plot(Time_arr, V2_arr, '.-b')

%% Load data to FRA_dummy_dev

Save_data_flag = false;
% freq = 10;
Fs = 10e3;
Synth_time = Time_arr;
Synth_signal_1 = V1_arr;
Synth_signal_2 = V2_arr;


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

Cur = Volt2*Scale;
Cur_err = Volt2_err*Scale;
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

Cap = 1/(6.28*freq*Res);
Cap_err = 1/(6.28*freq*Res^2)*Res_err;


res_print(Res, Res_err)
cap_print(Cap, Cap_err)
phi_print(Phase_diff, Phase_diff_error)




function res_print(Res, Res_err)
arguments
    Res
    Res_err = []
end
    if Res > 1e12
        unit = 'TOhm';
        scale = 1e-12;
    elseif Res > 1e9
        unit = 'GOhm';
        scale = 1e-9;
    elseif Res > 1e6
        unit = 'MOhm';
        scale = 1e-6;
    elseif Res > 1e3
        unit = 'kOhm';
        scale = 1e-3;
    else
        unit = 'Ohm';
        scale = 1;
    end
    
    if ~isempty(Res_err)
        disp(['|R| = ' num2str(Res*scale, '%0.3f') ' ± ' ...
            num2str(Res_err*scale, '%0.3f') ' ' unit])
    else
        disp(['|R| = ' num2str(Res*scale, '%0.3f') ' ' unit])
    end
end

function cap_print(Cap, Cap_err)
arguments
    Cap
    Cap_err = []
end
    if Cap < 1e-9
        unit = 'pF';
        scale = 1e12;
    elseif Cap < 1e-6
        unit = 'nF';
        scale = 1e9;
    else
        unit = 'uF';
        scale = 1e6;
    end

    if ~isempty(Cap_err)
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ± ' ...
        num2str(Cap_err*scale, '%0.3f') ' ' unit])
    else
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ' unit])
    end
end


function phi_print(Phi, Phi_err)
arguments
    Phi
    Phi_err = []
end
    if ~isempty(Phi_err)
        disp(['P = ' num2str(Phi, '%0.2f') ' ± ' ...
            num2str(Phi_err, '%0.2f') ' deg'])
    else
        disp(['P = ' num2str(Phi, '%0.2f') ' deg'])
    end
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

