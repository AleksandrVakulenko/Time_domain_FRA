

function [Result, Residuals, DEBUG] = fit_channel(T_arr, V_arr, Range, Fs, freq, ...
    Estimations, Properties, Harm_num, Fit_settings)

Time_length = T_arr(end) - T_arr(1);
Period = 1/freq;
Period_counter = Time_length/Period;

if ~isempty(Estimations)

    Harm_est = [];
    if ~isempty(Harm_num)
        try % FIXME: (2) why try-catch?
            Harm_est = TDFRA_fit_core.estimate_harmonics(T_arr, V_arr, Fs, freq, Harm_num);
        catch
            
        end
    end

    Noise_rms = TDFRA_fit_core.noise_rms_calc(V_arr, Fs, freq, Harm_num);

    % NOTE: use range oly if it contains more than 100 points
    Minimum_number_of_points = 100;% FIXME: (3) get from settings
    if numel(find(Range)) > Minimum_number_of_points
        T_arr = T_arr(Range);
        V_arr = V_arr(Range);
    end

    Max_points = Fit_settings.max_points;
    % FIXME: (3) make it single channel
    [T_arr, V_arr, ~, Fs2] = TDFRA_fit_core.make_fs_lower(T_arr, V_arr, V_arr, Fs, ...
        freq, Harm_num, Max_points);

    % NOTE: fit with harmonics estimations
    [Result, Residuals, DEBUG] = TDFRA_fit_core.any_sin_fit(T_arr, V_arr, freq, ...
        Estimations, Properties, Harm_est, Fit_settings);
    
    DEBUG.Fs_new = Fs2;
    DEBUG.T_arr_new = T_arr;

    Refit_flag = false;

    % NOTE: analize residuals here (it is already done below)
    if ~isempty(Harm_num)
        % FIXME: (2) is it better to use full Fs?
        Harm_est_2 = TDFRA_fit_core.estimate_harms_from_res(T_arr, Residuals, freq, ...
            Noise_rms, Harm_num);
    else
        Harm_est_2 = [];
    end
    
    if ~isempty(Harm_est_2) && ~isempty(Result.harm)
        % FIXME: (2) bad legacy code
        Fitted_harm = Result.harm;
        for i = 1:numel(Harm_est_2)
            hn = Harm_est_2(i).n;
            ind = find([Fitted_harm.n] == hn);
            if ~isempty(ind)
                Fitted_harm(ind).amp = Fitted_harm(ind).amp + Harm_est_2(i).amp;
                Fitted_harm(ind).phi = Harm_est_2(i).phi;
            end
        end
        Refit_flag = true;
    end
    
    if Refit_flag
        [Result, Residuals, DEBUG] = TDFRA_fit_core.any_sin_fit(T_arr, V_arr, freq, ...
            Estimations, Properties, Fitted_harm, Fit_settings);
    end

    % NOTE: harm redefine
    if Period_counter > 1
        [Result_harm, RMS_Ratio] = TDFRA_fit_core.Harm_refit(Result, T_arr, V_arr, Fs2);
        Harm_y = TDFRA_fit_viewer.Harm_calc(Result_harm, T_arr);
        if ~isempty(Harm_y)
            V_arr_pure = V_arr - Harm_y;
            Estimations_pure = TDFRA_fit_core.result2estimation(Result_harm);
            [Result, Residuals, DEBUG] = TDFRA_fit_core.any_sin_fit(T_arr, V_arr_pure, freq, ...
                Estimations_pure, Properties, [], Fit_settings);
            Result.harm = Result_harm.harm;
            Result.harm_err = Result_harm.harm_err;
        end
        klog.disp(['        RMS_Ratio = ' num2str(RMS_Ratio, '%0.2f')], "debug_full");
    end
    
else
    klog.warning('NO ESTIMATIONS FOR FIT');
    Result = [];
    Residuals = [];
    DEBUG = [];
end

end