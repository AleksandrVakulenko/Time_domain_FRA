

function Results_arr_PRE = pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr)

% NOTE: bad version
% FIXME: it is bad to estimate on single point

Noisy_env = true;
Self_cal = false;

    Harm_num = [1 2 3];
    Gen_freq = [1 70];
    DC_bias = 0;
    Time_profile = 'ultra_fast';
    Zest = struct('type', 'res', 'value', 50e3); % FIXME: magic constant
    Fit_Result_1 = Aster_FRA.single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq(1), Gen_Voltage_level, DC_bias, Harm_num, Zest, ...
        Time_profile, Ax_arr, [], Self_cal, Noisy_env);

    Fit_Result_2 = Aster_FRA.single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq(2), Gen_Voltage_level, DC_bias, Harm_num, Zest, ...
        Time_profile, Ax_arr, [], Self_cal, Noisy_env);
    
    Results_arr_PRE = [Fit_Result_1 Fit_Result_2];
    
    
    % --- FXIME: debug section ---
%     Res = Fit_Result.res_abs;
%     Cap = 1/(2*pi*Res*Gen_freq);
%     Zest = struct('type', 'cap', 'value', Cap);
    % --- NOTE: end of debug section ---

%     Zest = struct('type', 'res', 'value', Fit_Result.res_abs);
end