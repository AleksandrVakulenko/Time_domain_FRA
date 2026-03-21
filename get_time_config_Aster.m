

function [Times_conf, printer] = get_time_config_Aster(Period, Harm_num, ...
    Time_profile, Harm_profile)
arguments
    Period double
    Harm_num double = 1
    Time_profile string {mustBeMember(Time_profile, ...
        ["ultra_fast", "common", "fine", "most_accurate"])} = "common"
    Harm_profile string {mustBeMember(Harm_profile, ...
        ["common", "most_accurate"])} = "common"
end

if Harm_profile ~= "most_accurate"
    Harm_num = 1;
end

switch Time_profile
    case "ultra_fast"
        Times_conf_basic = get_time_conf_ultra_fast(Period, Harm_num);
    case "common"
        Times_conf_basic = get_time_conf_common(Period, Harm_num);
    case "fine"
        Times_conf_basic = get_time_conf_fine(Period, Harm_num);
    case "most_accurate"
        Times_conf_basic = get_time_conf_most_accurate(Period, Harm_num);
    otherwise
        error("impossible code execution")
end

Min_meas_time = Times_conf_basic.min_meas_time;
Min_fop = Times_conf_basic.min_fop;
Max_fop = Times_conf_basic.max_fop;
Harm_fop = Times_conf_basic.period_for_harm_det;

if Min_fop < Harm_fop
    Min_fop = Harm_fop;
end
if Max_fop < Harm_fop
    Max_fop = Harm_fop;
end

Min_fop = max([Min_meas_time/Period Min_fop]);

if Max_fop < Min_fop
    Max_fop = Min_fop*1.2;
end

Times_conf.min_fop = Min_fop;
Times_conf.max_fop = Max_fop;
Times_conf.period = Period;
Times_conf.time_profile = Time_profile;
Times_conf.harm_profile = Harm_profile;

printer = @() print_time_conf(Times_conf);
end




% FIXME: add accuracy settings
function Times_conf = get_time_conf_ultra_fast(Period, Harm_num)
    Times_conf.period_for_harm_det = 0;
    Times_conf.min_meas_time = 0.5; % [s]
    Times_conf.min_fop = 0.6; % [1]
    Times_conf.max_fop = 0.8; % [1]
end


function Times_conf = get_time_conf_common(Period, Harm_num)
    Harm_num(Harm_num > 3) = [];

    Times_conf.period_for_harm_det = lcms(Harm_num);
    Times_conf.min_meas_time = 1; % [s]
    Times_conf.min_fop = 1.0; % [1]
    Times_conf.max_fop = 2.0; % [1]
end


function Times_conf = get_time_conf_fine(Period, Harm_num)
    Harm_num(Harm_num > 3) = [];

    Times_conf.period_for_harm_det = lcms(Harm_num);
    Times_conf.min_meas_time = 3; % [s]
    Times_conf.min_fop = 1.5; % [1]
    Times_conf.max_fop = 10; % [1]
end


function Times_conf = get_time_conf_most_accurate(Period, Harm_num)
    Harm_num(Harm_num > 5) = [];

    Times_conf.period_for_harm_det = lcms(Harm_num);
    Times_conf.min_meas_time = 5; % [s]
    Times_conf.min_fop = 4;
    Times_conf.max_fop = 20; % [1]
end



function print_time_conf(Times_conf)
Time_profile = Times_conf.time_profile;
Period = Times_conf.period;
Freq = 1/Period;

Min_time = Times_conf.min_fop*Period;
Max_time = Times_conf.max_fop*Period;
disp('------ TIME CONFIG ------')
disp(['Profile: "' char(Time_profile) '"'])
disp(['Freq = ' num2str(Freq) ' Hz'])
disp(['Min time = ' num2str(Min_time), ' s'])
disp(['Max time = ' num2str(Max_time), ' s'])
disp('-------------------------')
end




