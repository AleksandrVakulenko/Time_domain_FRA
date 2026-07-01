function [Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
    Used_ranges, Last_used_range] = measure(Resources, Aster_addr, ...
    Settings, Fig, Zest, Fixed_range)
arguments
    Resources
    Aster_addr
    Settings
    Fig = []
    Zest = []
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
MAX_CH2_LIMIT = 5; % FIXME: maybe 6?

if ~isempty(Fixed_range) && any(Fixed_range == [1 2 3 4 5 6]) % FIXME: ranges list
    Underrange_force_2 = true;
    Overrange_tolerance = 100; % [%]
    Auto_range = false;
else
    Auto_range = true;
    Possible_ranges = Aster_FRA.get_possible_ranges(Freq);
    if isempty(Possible_ranges)
        error(['No Range is avilable for f = ' num2str(Freq), ' Hz'])
    end
end

[Times_conf, Time_printer, ~, Profile] = fit_core.get_time_config(Period, ...
    Time_profile, Harm_profile);
Time_printer(); % FIXME: disp

%--------------------------------
Time_to_underrange = 0.1*Period; % [s] / FIXME: why?

% FIXME: debug
if Time_to_underrange < 0.3
    Time_to_underrange = 0.3; % FIXME: magic constant
end
%--------------------------------

Last_used_range = [];
Gen_type = "Aster_dev";
Gen_addr = [];
[Aster, Gen] = Aster_FRA.connect_to_devices(Aster_addr, Gen_type, Gen_addr);

ERR = [];
try
    Gen_initiate(Gen, Gen_Voltage_level, Gen_freq, Gen_Offset_level);

    [Fs_new, Filter_wait] = Aster_FRA.ADC_init(Aster, Gen_freq, Harm_num, Times_conf);

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

    if Auto_range
        [Range_num_forecast, ~] = Aster_FRA.range_forecaster(Aster, Zest, ...
            Gen_Voltage_level, Gen_freq); % FIXME: use DC bias here too

        if ~isempty(Range_num_forecast)
            Range_init_num = Range_num_forecast;
        else
            Range_init_num = 1;
        end
        if ~any(Range_init_num == Possible_ranges)
            Range_init_num = max(Possible_ranges);
            Channel_settings_2.underrange_force = true;
        end
    else
        Range_init_num = Fixed_range;
    end

    Aster.set_connection_mode("I2V");
    Aster.ADC_1_direction("internal");
    Aster.Gen_direction("Internal");
    Aster.initiate();

    [~, R_Scale, Aster_Range] = Aster_FRA.set_range(Aster, Range_init_num);
    % NOTE: update time and accuracy profiles
    Time_profile_new = Aster_FRA.max_time_profile(Time_profile, Aster_Range);
    [~, ~, ~, Profile] = fit_core.get_time_config(Period, Time_profile_new, ...
        Harm_profile);
    
    adev_utils.Wait(Filter_wait, 'Apply filter'); % FIXME: disp
    Used_ranges = Aster_Range;
    Last_used_range = Aster_Range;

    Try_num = 0;
    stop = false;
    while ~stop
        Try_num = Try_num + 1;
        disp(['Try num = ' num2str(Try_num)]) % FIXME: disp

        Aster.CMD_data_stream(1);

        [Exit_flag, Ch_data_1, Ch_data_2] = data_gathering_loop(Resources, ...
            Aster, Freq, Harm_num, Profile, Channel_settings_1, Channel_settings_2, Fig);

        Aster.CMD_data_stream(0);

        warning(['Exit flag: ' num2str(Exit_flag)])

        if Exit_flag == 40
            break;
        end

        if Auto_range
            need_to_switch_range = false;
            switch_range_force = false;
            if Exit_flag == 0 || Exit_flag == 30
                stop = true;
            elseif Exit_flag == 102
                Aster_Range = Aster_Range + 1;
                if ~any(Aster_Range == Possible_ranges)
                    Channel_settings_2.underrange_force = true;
                else
                    need_to_switch_range = true;
                end
            elseif Exit_flag == 202
                Aster_Range = Aster_Range - 1;
                need_to_switch_range = true;
                switch_range_force = true;
                Channel_settings_2.underrange_force = true;
                disp('Underrange force on CH2 is active') % FIXME: debug
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
                    [flag, R_Scale, Aster_Range] = Aster_FRA.set_range(Aster, Aster_Range);
                    % NOTE: update time and accuracy profiles
                    Time_profile_new = Aster_FRA.max_time_profile(Time_profile, Aster_Range);
                    [~, ~, ~, Profile] = fit_core.get_time_config(Period, ...
                        Time_profile_new, Harm_profile);

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
    Aster_FRA.disconnest_devices(Aster, Gen)
    disp('ERR finish // devices closed') % FIXME: disp
    rethrow(ERR)
end


Aster_FRA.disconnest_devices(Aster, Gen)
Accuracy_conf = Profile.accuracy_conf;

Full_main_time = toc(Full_main_time_counter);
disp([newline '-----------------------------------------' newline ...
    '             Main fit finish' newline ...
    '-----------------------------------------' newline ...
    'Time: ' num2str(Full_main_time) ' s' newline ...
    '-----------------------------------------' newline]) % FIXME: disp

end
