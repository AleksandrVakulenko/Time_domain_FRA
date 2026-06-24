
clc

% fit_core : Harm_refit : Harm_to_find
Settings_struct.max_haromic_to_find = 9; 

% fit_core : estimate_harmonics : HNR_min_dB
Settings_struct.harm_to_noise_value_dB = 10; 

% fit_core : fft_filter_dbl_ch : Min_Ratio
Settings_struct.min_period_number_ref_to_old_in_filter = 0.8; 

% fit_core : find_outliers : Sigma_scale
Settings_struct.sigma_scale_to_find_outlier = 3;

% fit_core : get_time_config : Absolute_max_FOP
Settings_struct.absolute_max_number_of_gatherd_periods = 50;

% fit_core : noise_amp_calc : exclude_bad_freq : Freq_max_dev
Settings_struct.max_freq_deviation_in_fft = 0.03;

% fit_core : fit_channel : Minimum_number_of_points
Settings_struct.min_number_of_points_to_fit = 100;

% Main2 : Max_points
Settings_struct.max_points_to_fit = 50e3;

% data_gathering_loop : Prefit_max_points
Settings_struct.max_points_to_pre_fit = 10e3;



%%

Filename = "Settings.json";

JSON_text = jsonencode(Settings_struct, "PrettyPrint", true);

fit_settings.write_json_file(Filename, JSON_text);

disp(JSON_text)

Data = fit_settings.read_json_file(Filename);

disp(Data)

%% READ


Value = fit_settings.get_value("max_haromic_to_find")



%%







