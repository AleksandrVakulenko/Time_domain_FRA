function [Result, Residuals, DEBUG] = fit_channel(T_arr, V_arr, Range, Fs, freq, ...
    Estimations, Properties, Harm_num, Fit_settings)

Time_length = T_arr(end) - T_arr(1);
Period = 1/freq;
Period_counter = Time_length/Period;

if ~isempty(Estimations)

    if freq > 5 % FIXME: magic constant
        % NOTE: add 50 Hz rejection
        % FIXME: add ability to switch on 60 Hz
        Rej_freq = 50;
        Rej_BW = 2; % FIXME: magic constant
        Rej_freq_low = Rej_freq-Rej_BW/2;
        Rej_freq_high = Rej_freq+Rej_BW/2;
        V_arr = fft_band_rejection(V_arr, Fs, -60, Rej_freq_low, Rej_freq_high);
    end

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
    Minimum_number_of_points = 100;% FIXME: get from settings
    if numel(find(Range)) > Minimum_number_of_points
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

    % NOTE: analize residuals here (it is already done below)
    if ~isempty(Harm_num)
        % FIXME: is it better to use full Fs?
        Harm_est_2 = fit_core.estimate_harms_from_res(T_arr, Residuals, freq, ...
            Noise_rms, Harm_num);
    else
        Harm_est_2 = [];
    end
    
    if ~isempty(Harm_est_2) && ~isempty(Result.harm)
        % FIXME: bad legacy code
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
        [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
            Estimations, Properties, Fitted_harm, Fit_settings);
    end

    % NOTE: harm redefine
    if Period_counter > 1
        [Result_harm, RMS_Ratio] = fit_core.Harm_refit(Result, T_arr, V_arr, Fs2);
        Harm_y = fit_viewer.Harm_calc(Result_harm, T_arr);
        if ~isempty(Harm_y)
            V_arr_pure = V_arr - Harm_y;
            Estimations_pure = fit_core.result2estimation(Result_harm);
            [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr_pure, freq, ...
                Estimations_pure, Properties, [], Fit_settings);
            Result.harm = Result_harm.harm;
            Result.harm_err = Result_harm.harm_err;
        end
        disp(['        RMS_Ratio = ' num2str(RMS_Ratio, '%0.2f')]); % FIXME: disp
    end
    
else
    disp('NO ESTIMATIONS FOR FIT'); % FIXME: disp; do something with it
    Result = [];
    Residuals = [];
    DEBUG = [];
end

end