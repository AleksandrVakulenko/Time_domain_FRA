function [Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
    Used_ranges, Last_used_range] = Aster_FRA_measure(Aster_addr, Settings, ...
    Fig, Cap_exp, Fixed_range)
arguments
    Aster_addr
    Settings
    Fig = []
    Cap_exp = []
    Fixed_range = []
end

Gen_Voltage_level = Settings.amp;
Gen_freq = Settings.freq;
Gen_Offset_level = Settings.dc; % FIXME: unused
Harm_num = Settings.harm_num;
Time_profile = Settings.time_profile;
Harm_profile = Settings.harm_profile;

Full_main_time_counter = tic; % FIXME: debug
Freq = Gen_freq;
Period = 1/Freq;
Underrange_force_1 = true; % NOTE: for low input voltage level
Underrange_force_2 = false;
Overrange_tolerance = 0.2; % [%] // FIXME: debug value
MAX_CH1_LIMIT = 10;
MAX_CH2_LIMIT = 5;

if ~isempty(Fixed_range) && any(Fixed_range == [1 2 3 4 5 6])
    Underrange_force_2 = true;
    Overrange_tolerance = 100; % [%]
    Auto_range = false;
else
    Auto_range = true;
end

[Times_conf, Time_printer, Accuracy_conf] = get_time_config_Aster(Period, Harm_num, ...
    Time_profile, Harm_profile);
Time_printer(); % FIXME: debug

Profile.times_conf = Times_conf;
Profile.accuracy_conf = Accuracy_conf;
%--------------------------------

%--------------------------------
Time_to_underrange = 0.1*Period; % [s]

% FIXME: debug
if Time_to_underrange < 0.3
    Time_to_underrange = 0.3; % FIXME: magic constant
end
%--------------------------------

Last_used_range = [];
Gen_type = "Aster_dev";
Gen_addr = [];
[Aster, Gen] = Connect_to_devices(Aster_addr, Gen_type, Gen_addr);

ERR = [];
try
    Gen_initiate(Gen, Gen_Voltage_level, Gen_freq);

    [Fs_new, Filter_wait] = Aster_ADC_init(Aster, Gen_freq, Harm_num, Times_conf);

    disp(['>>>>>>  Fs = ' num2str(Fs_new, "%0.3f") ' Hz <<<<<<']) % FIXME: disp

    Channel_settings_1.underrange_force = Underrange_force_1;
    Channel_settings_1.max_ch1_limit = MAX_CH1_LIMIT;
    Channel_settings_1.time_to_underrange = Time_to_underrange;
    Channel_settings_1.overrange_tolerance = Overrange_tolerance;
    Channel_settings_1.fs = Fs_new;

    Channel_settings_2.underrange_force = Underrange_force_2;
    Channel_settings_2.max_ch1_limit = MAX_CH2_LIMIT;
    Channel_settings_2.time_to_underrange = Time_to_underrange;
    Channel_settings_2.overrange_tolerance = Overrange_tolerance;
    Channel_settings_2.fs = Fs_new;

    % FIXME: add more options
    if Auto_range
        [Range_num_forecast, ~] = Range_forecaster(Aster, Cap_exp, ...
            Gen_Voltage_level, Gen_freq);

        if ~isempty(Range_num_forecast)
            Range_init_num = Range_num_forecast;
        else
            Range_init_num = 1;
        end
    else
        Range_init_num = Fixed_range;
    end

    Aster.set_connection_mode("I2V");
    Aster.ADC_1_direction("internal");
    Aster.Gen_direction("Internal");
    Aster.initiate();

    [flag, R_Scale, Aster_Range] = Aster_set_range(Aster, Range_init_num);
    adev_utils.Wait(Filter_wait, 'Apply filter'); % FIXME: disp
    Used_ranges = Aster_Range; % FIXME: nyan
    Last_used_range = Aster_Range;

    Try_num = 0;
    stop = false;
    while ~stop
        Try_num = Try_num + 1;
        disp(['Try num = ' num2str(Try_num)]) % FIXME: disp

        Aster.CMD_data_stream(1);

        [Exit_flag, Ch_data_1, Ch_data_2] = data_gathering_loop(Aster, ...
            Freq, Harm_num, Profile, Channel_settings_1, Channel_settings_2, Fig);

        Aster.CMD_data_stream(0);

        warning(['Exit flag: ' num2str(Exit_flag)])

        if Auto_range
            need_to_switch_range = false;
            switch_range_force = false;
            if Exit_flag == 0 || Exit_flag == 30
                stop = true;
            elseif Exit_flag == 102
                Aster_Range = Aster_Range + 1;
                need_to_switch_range = true;
            elseif Exit_flag == 202
                Aster_Range = Aster_Range - 1;
                need_to_switch_range = true;
                switch_range_force = true;
            elseif Exit_flag == 101 || Exit_flag == 201
                stop = true;
            else
                warning(['Unknown exit flag: ' num2str(Exit_flag)]) % FIXME: disp
                stop = true;
            end

            if need_to_switch_range
                if any(Aster_Range == Used_ranges) && ~switch_range_force
                    stop = true;
                else
                    [flag, R_Scale, Aster_Range] = Aster_set_range(Aster, Aster_Range);
                    adev_utils.Wait(Filter_wait, 'Apply filter'); % FIXME: disp
                    if ~flag
                        stop = true;
                    else
                        Used_ranges = unique([Used_ranges Aster_Range]);
                        Last_used_range = Aster_Range;
                    end
                end
            end
        else
            stop = true;
        end
    end
catch ERR
    Disconnest_devices(Aster, Gen)
    disp('ERR finish // devices closed') % FIXME: disp
    rethrow(ERR)
end

if isempty(ERR)
    Disconnest_devices(Aster, Gen)
    disp('OK finish') % FIXME: disp
end



Full_main_time = toc(Full_main_time_counter);
disp([newline '-----------------------------------------' newline ...
    '             Main fit finish' newline ...
    '-----------------------------------------' newline ...
    'Time: ' num2str(Full_main_time) ' s' newline ...
    '-----------------------------------------' newline]) % FIXME: disp

end
