
% NOTE: test on Simulator

%%


% FIXME: delete file !

% NOTE: could be outdated


% ------------------------------------------------------------------------------

clc

Save_data_flag = false;
freq = 0.2;
Freq_dev = 0;
Duration = 10;
Fs = 10e3;
Profile_1 = 'weak';
Profile_2 = 'weak';
% Traits = ["nobg", "zerophi", 'nonoise', "lownoise", "constphi"];
Traits_1 = ["lownoise", "nobg", "lowharm"];
Traits_2 = ["", "", ""];
Seed = ''; % QDNRSE

% LLGUHH (small signal)
% IOTSCV (Phase test)
% VHJLJS (O_O)
% HDNPYV
% QDQFFM
% CUSAIQ ???
% AQIOEZ overload test
% YYSRCS
% BTSISX window demo / f = 1, D = 11, weak weak, use S2

[Synth_time, Synth_signal_1, Props_1, Noise_1] = test_gen.gen_synth_sig(freq, ...
    Freq_dev, Duration, Profile_1, Traits_1, Seed, Fs, 10);

Seed_2 = [char(Props_1.seed) 'A'];

[~, Synth_signal_2, Props_2, Noise_2] = test_gen.gen_synth_sig(freq, ...
    Freq_dev, Duration, Profile_2, Traits_2, Seed_2, Fs);

disp(['Seed: ' char(Props_1.seed)]);

Synth_signal_1 = test_gen.signal_digitizer(Synth_signal_1, 10, 18-1);
Synth_signal_2 = test_gen.signal_digitizer(Synth_signal_2, 6, 18-1);

FRA_dev = test_gen.FRA_dummy_dev(Synth_time, Synth_signal_1, Synth_signal_2);

test_gen.plot_test_signals(Synth_time, Synth_signal_1, Synth_signal_2);


%

[~, printer, ~, Profile] = TDFRA_fit_core.get_time_config(1/freq, "common", "common");
printer()

%
Period = 1/freq;

Use_power_line_filter = false;
Underrange_force_1 = false;
Underrange_force_2 = false;
MAX_CH1_LIMIT = 10; % FIXME: (2) maybe 6? Where it is selected?
MAX_CH2_LIMIT = 5; % FIXME: (2) maybe 6? Where it is selected?
Time_to_underrange = 0.1*Period;
Time_to_overrange = Time_to_underrange;
Overrange_tolerance = 0.2; % [%] // FIXME: (3) debug value
Fs_new = Fs; % FIXME: add control of Fs to FRA_dummy_dev


Channel_settings_1.underrange_force = Underrange_force_1;
Channel_settings_1.max_ch1_limit = MAX_CH1_LIMIT;
Channel_settings_1.time_to_underrange = Time_to_underrange;
Channel_settings_1.time_to_overrange = Time_to_overrange;
Channel_settings_1.overrange_tolerance = Overrange_tolerance;
Channel_settings_1.fs = Fs_new;

Channel_settings_2.underrange_force = Underrange_force_2;
Channel_settings_2.max_ch1_limit = MAX_CH2_LIMIT;
Channel_settings_2.time_to_underrange = Time_to_underrange;
Channel_settings_2.time_to_overrange = Time_to_overrange;
Channel_settings_2.overrange_tolerance = Overrange_tolerance;
Channel_settings_2.fs = Fs_new;

Settings.use_power_line_filter = Use_power_line_filter;
Settings.channel_settings_1 = Channel_settings_1;
Settings.channel_settings_2 = Channel_settings_2;

%

% Fig = figure;
% Gui_Fig = TDFRA_fit_gui.init_gather_axes(Fig);

Fig = TDFRA_fit_gui.init_Aster_FRA_gui();
Ax_arr = [Fig.UserData.axes_top Fig.UserData.axes_bot];
Stop_button = Fig.UserData.stop_button;
Resources.stop_button = Stop_button;
Resources.underrange_ind = Fig.UserData.underrange_ind;
Resources.range_ind = Fig.UserData.range_ind;
%


Harm_num = 1;


FRA_dev.run();

[Exit_flag, Ch_data_1, Ch_data_2] = ...
    TDFRA_fit_core.data_gathering_loop(Resources, FRA_dev, freq, Harm_num, ...
    Profile, Settings, Ax_arr);

Exit_flag

FRA_dev.stop();



%% BUG REPORT

% 1) debug print problem then no figure is passed:
%    [Exit_flag, Ch_data_1, Ch_data_2] = ...
%     TDFRA_fit_core.data_gathering_loop(Resources, FRA_dev, freq, Harm_num, ...
%     Profile, Settings, []);





