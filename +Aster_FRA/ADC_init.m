function [Fs_new, Filter_wait] = ADC_init(Aster, Gen_freq, ...
    Harm_num, Times_conf)

% NOTE: try to avoid zones without data transmission;
% + Aster limit is 10e3
LIMIT_FS_MIN = 500; % [Hz]
LIMIT_FS_MAX = 10e3; % [Hz]

switch Times_conf.time_profile
    case "ultra_fast"
        Number_of_periods = 2;
        Min_filter_freq = 1; % [Hz]
        Sampling_freq = 5000*Gen_freq;
    case  "common"
        Number_of_periods = 4;
        Min_filter_freq = 0.75; % [Hz]
        Sampling_freq = 2500*Gen_freq;
    case  "fine"
        Number_of_periods = 4;
        Min_filter_freq = 0.5; % [Hz]
        Sampling_freq = 2000*Gen_freq;
    case  "most_accurate"
        Number_of_periods = 5;
        Min_filter_freq = 0.25; % [Hz]
        Sampling_freq = 2000*Gen_freq;
    otherwise
        error('unreachable code in ADC_init()')
end

% Min_filter_freq = 100; % FIXME: debug !!!!!

% Fs = 10e3; % FIXME: get from device!


if Sampling_freq < LIMIT_FS_MIN
    Sampling_freq = LIMIT_FS_MIN;
end

if Sampling_freq > LIMIT_FS_MAX
    Sampling_freq = LIMIT_FS_MAX;
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
% disp('------------------------')
% disp(num2str(ADC_filter_Fc)) % FIXME: debug!!!!!!
% disp('------------------------')
Aster.ADC_filter(ADC_filter_Fc);
% Aster.set_ADC_2_range(12); % FIXME: check it

end