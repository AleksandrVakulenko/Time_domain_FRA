function [Fs_new, Filter_wait] = Aster_ADC_init(Aster, Gen_freq, ...
    Harm_num, Times_conf)



if Times_conf.time_profile == "ultra_fast"
    Number_of_periods = 2; % FIXME: magic constant
    Min_filter_freq = 10; % [Hz]
elseif Times_conf.time_profile == "common"
    Number_of_periods = 5; % FIXME: magic constant
    Min_filter_freq = 2; % [Hz]
else
    Number_of_periods = 5; % FIXME: magic constant
    Min_filter_freq = 0.5; % [Hz[
end

% Fs = 10e3; % FIXME: get from device!

if Times_conf.time_profile == "ultra_fast"
    Sampling_freq = 5000*Gen_freq; % FIXME: magic constant
elseif Times_conf.time_profile == "common"
    Sampling_freq = 2500*Gen_freq;
elseif Times_conf.time_profile == "fine"
    Sampling_freq = 2000*Gen_freq;
elseif Times_conf.time_profile == "most_accurate"
    Sampling_freq = 2000*Gen_freq;
else
    Sampling_freq = 1000*Gen_freq;
end

if Sampling_freq < 200
    Sampling_freq = 200; % FIXME: magic constant
end


if ~isempty(Harm_num)
    Max_harm = max(Harm_num);
else
    Max_harm = 1;
end

if Max_harm <= 2
    Max_harm = 2;
end

ADC_filter_Fc = Max_harm*Gen_freq;
if ADC_filter_Fc < Min_filter_freq
    ADC_filter_Fc = Min_filter_freq;
end
Filter_wait = Number_of_periods/ADC_filter_Fc;

Fs_new = Aster.ADC_send_freq(Sampling_freq);
Aster.ADC_filter(ADC_filter_Fc);


end