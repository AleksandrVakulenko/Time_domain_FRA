

function Estimations_1 = estimation_processing(Ch_data_1)

%--------------------------------%--------------------------------%
T_arr_1 = Ch_data_1.time;
V1_arr = Ch_data_1.voltage;
Estimations_1 = Ch_data_1.estimations;
Period = Ch_data_1.time_conf.period;
freq = 1/Period;
%--------------------------------%--------------------------------%

Time_length_1 = T_arr_1(end) - T_arr_1(1);
Periods_counter_1 = Time_length_1/Period;

Estimations_1 = finish_estimations(Estimations_1, T_arr_1, V1_arr, Period);
Estimations_1 = estimation_fix(Estimations_1, Periods_counter_1, freq);

end



function Estimations_all = finish_estimations(Estimations_all, T_arr, V_arr, Period)

Time_passed = T_arr(end)-T_arr(1);
Periods_counter = Time_passed/Period;

legacy_status = [Estimations_all.legacy_status];
est_range = legacy_status == "";
Estimations = Estimations_all(est_range);
Estimations_all(est_range) = [];

if Periods_counter >= 1
    [out_time1, out_sig1] = fit_core.get_one_period(T_arr, V_arr, Period, "first");
    [out_time2, out_sig2] = fit_core.get_one_period(T_arr, V_arr, Period, "last", 1.1);

    Result1 = fit_core.DFT_estimation(out_time1, out_sig1, Period);
    Result1.t_min = 0;
    Result1.t_max = 0;
    Result1.status = 'fixed';

    if ~isnan(Result1.amp)
        Estimations = [Estimations Result1];
    else
        error('err EF2'); % FIXME: undone
    end

    Result2 = fit_core.DFT_estimation(out_time2, out_sig2, Period);
    Result2.t_min = T_arr(end);
    Result2.t_max = T_arr(end);
    Result2.status = 'fixed';

    if ~isnan(Result1.amp)
        Estimations = [Estimations Result2];
    else
        error('err EF4'); % FIXME: undone
    end

else
    % FIXME: do something else
    Estimations(1).t_min = 0;
    Estimations(1).t_max = 0;
    Estimations(1).status = 'fixed';
    Estimations(end).t_min = T_arr(end);
    Estimations(end).t_max = T_arr(end);
    Estimations(end).status = 'fixed';
end

Estimations_all = [Estimations_all Estimations];
end


function Estimations = estimation_fix(Estimations_all, Periods_counter, freq)

Legacy_status = [Estimations_all.legacy_status];

est_range_norm = Legacy_status == "";
est_range_low = Legacy_status == "low";
est_range_extra = Legacy_status == "extra";

Estimations = Estimations_all(est_range_norm);
Estimations_low = Estimations_all(est_range_low);
Estimations_extra = Estimations_all(est_range_extra);

% 
% disp('-----------')
% % FIXME: nyan
% Estimations
% isempty(Estimations)
% [Estimations.legacy_status]
% [Estimations_low.legacy_status]
% [Estimations_extra.legacy_status]
% disp('-----------')

Period = 1/freq;
% NOTE: delete early estimations
Est_time_min = [Estimations.t_max];
Est_time_max = [Estimations.t_max];

Est_status = "";
for i = 1:numel(Estimations)
    Est_status(i) = string(Estimations(i).status);
end
range2 = Est_status == "fixed";

if Periods_counter > 2
    range = Est_time_min < Period & Est_time_max < Period;
else
    range = Est_time_max < Period*0.5;
end

Estimations(range & ~range2) = [];

% NOTE: Replce estimations (is none) by bad estimations
if isempty(Estimations) && isempty(Estimations_low) && ...
        ~isempty(Estimations_extra)
    disp([newline '! YOLO FIT ! („• ֊ •„)' newline])
    Estimations = Estimations_extra;
elseif isempty(Estimations) && ~isempty(Estimations_low)
    disp([newline '! FIT by bad estimations ! ⸜(｡˃ ᵕ ˂ )⸝♡' newline])
    Estimations = Estimations_low;
else
    disp([newline '! OK, we have something ! (˶ᵔ ᵕ ᵔ˶) ‹𝟹' newline])
end

end