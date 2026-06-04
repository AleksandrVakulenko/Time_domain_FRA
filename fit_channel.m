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

    if numel(find(Range)) > 10 % FIXME: magic constant
        T_arr = T_arr(Range);
        V_arr = V_arr(Range);
    end

    Max_points = Fit_settings.max_points;
    % FIXME: upgrade function make_fs_lower
    % FIXME: make it single channel
    [T_arr, V_arr, ~, Fs2] = fit_core.make_fs_lower(T_arr, V_arr, V_arr, Fs, ...
        freq, Harm_num, Max_points);

    if Fs2 ~= Fs % FIXME: debug print
        disp(' ') % FIXME: disp
        warning(['Sampling freq reduced: ' num2str(Fs) ' -> ' num2str(Fs2)]) % FIXME: disp
        disp(' ') % FIXME: disp
    end

    % NOTE: fit with harmonics estimations
    [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
        Estimations, Properties, Harm_est, Fit_settings);
    
    DEBUG.Fs_new = Fs2;
    DEBUG.T_arr_new = T_arr;

    Refit_flag = false;

    % NOTE: analize residuals here
    if ~isempty(Harm_num)
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
                disp([num2str(i) ' : ' num2str(ind)]) % FIXME: disp
                Fitted_harm(ind).amp = Fitted_harm(ind).amp + Harm_est_2(i).amp;
                Fitted_harm(ind).phi = Harm_est_2(i).phi;
            end
        end
        Refit_flag = true;
    end
    
    % NOTE: fit residuals here to find lost harms
    if Refit_flag
        [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
            Estimations, Properties, Fitted_harm, Fit_settings);
    end
    
else
    Result = [];
    Residuals = [];
    DEBUG = [];
end

end