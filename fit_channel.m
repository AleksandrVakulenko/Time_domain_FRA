function [Result, Residuals, DEBUG] = fit_channel(T_arr, V_arr, Range, Fs, freq, ...
    Estimations, Properties, Harm_num, Fit_settings)

if ~isempty(Estimations)

    if ~isempty(Harm_num)
        try % FIXME: debug
            Harm_est = fit_core.estimate_harmonics(T_arr, V_arr, Fs, freq, Harm_num);
        catch
            Harm_est = [];
        end
    else
        Harm_est = [];
    end

    Noise_rms = fit_core.noise_rms_calc(V_arr, Fs, freq, Harm_num);

    % NOTE: use range oly if it contains more than 100 points
    if numel(find(Range)) > 100 % FIXME: magic constant
        T_arr = T_arr(Range);
        V_arr = V_arr(Range);
    end

    Max_points = Fit_settings.max_points;
    % FIXME: make it single channel
    [T_arr, V_arr, ~, Fs2] = fit_core.make_fs_lower(T_arr, V_arr, V_arr, Fs, ...
        freq, Harm_num, Max_points);

    if Fs2 ~= Fs
        % FIXME: disp
        warning(['Sampling freq reduced: ' num2str(Fs) ' -> ' num2str(Fs2)])
    end

    % NOTE: fit with harmonics estimations
    [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
        Estimations, Properties, Harm_est, Fit_settings);
    
    DEBUG.Fs_new = Fs2;
    DEBUG.T_arr_new = T_arr;

    Refit_flag = false;

    % NOTE: analize residuals here
    if ~isempty(Harm_num)
        % FIXME: is it better to use full Fs?
        Harm_est_2 = fit_core.estimate_harms_from_res(T_arr, Residuals, freq, ...
            Noise_rms, Harm_num);
    else
        Harm_est_2 = [];
    end
    
    if ~isempty(Harm_est_2) && ~isempty(Result.harm)
        Fitted_harm = Result.harm;
        for i = 1:numel(Harm_est_2)
            hn = Harm_est_2(i).n;
            ind = find([Fitted_harm.n] == hn);
            if ~isempty(ind)
                disp(['Harm ' num2str(ind)]) % FIXME: disp
                Fitted_harm(ind).amp = Fitted_harm(ind).amp + Harm_est_2(i).amp;
                Fitted_harm(ind).phi = Harm_est_2(i).phi;
            end
        end
        Refit_flag = true;
    end
    
    % FIXME: fit residuals here to find lost harms
    if Refit_flag
        [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
            Estimations, Properties, Fitted_harm, Fit_settings);
    end
    
else
    disp('NO ESTIMATIONS FOR FIT'); % FIXME: disp
    Result = [];
    Residuals = [];
    DEBUG = [];
end

end