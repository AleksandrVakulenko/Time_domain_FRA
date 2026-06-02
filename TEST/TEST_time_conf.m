
% FIXME: include Fern::Common

clc

Freq = 0.01;

Period = 1/Freq;



Harm_num = [1 2 3 4 5 6 7];
% Harm_num = [1];

Time_profile = "ultra_fast"; % "ultra_fast", "common", "fine", "most_accurate"
Harm_profile = "common"; % "common", "most_accurate"


[Times_conf, Time_printer] = get_time_config_Aster(Period, Harm_num, ...
    Time_profile, Harm_profile);

Times_conf

Time_printer()


%%



Harm_num = [1 2 3 4 5 6 7 8];

figure
hold on

[Freq_arr, Time_array] = test_calc_times("ultra_fast", Harm_num);
plot(Freq_arr, Time_array, '-r')

[Freq_arr, Time_array] = test_calc_times("common", Harm_num);
plot(Freq_arr, Time_array, '-g')

[Freq_arr, Time_array] = test_calc_times("fine", Harm_num);
plot(Freq_arr, Time_array, '-b')

[Freq_arr, Time_array] = test_calc_times("most_accurate", Harm_num);
plot(Freq_arr, Time_array, '-c')

hold on

plot(Freq_arr, 1./Freq_arr, '--k')
plot(Freq_arr, 2./Freq_arr, '--k')
plot(Freq_arr, 0.5./Freq_arr, '--k')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
xlabel('freq, 1/s')
ylabel('Time to measure, s')


%%






function [Freq_arr, Time_array] = test_calc_times(Time_profile, Harm_num)
Freq_arr = 10.^linspace(log10(1e-4), log10(1000), 100);
Time_array = zeros(size(Freq_arr));
for i = 1:numel(Freq_arr)
    Freq = Freq_arr(i);
    Period = 1/Freq;

    Times_conf = get_time_config_Aster(Period, Harm_num, Time_profile);
    Time_to_measure = Times_conf.min_fop*Period;
    Time_array(i) = Time_to_measure;
end
end
