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