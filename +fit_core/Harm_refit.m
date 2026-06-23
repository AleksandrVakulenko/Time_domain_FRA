function [Result, RMS_Ratio, Residuals, Residuals_harm] = ...
    Harm_refit(Result, T_arr, V_arr, Fs)

f_dev_ppm = Result.f_dev_ppm;
Freq = Result.freq;

% Fs = Ch_data.fs;
% Harm_2_arr = Result.harm;

% T_arr = Ch_data.time;
% V_arr = Ch_data.voltage;

ym = fit_viewer.calc_fitted_signal(Result, T_arr, true);

Residuals = V_arr - ym;

Harm_to_find = [2 3 4 5 6 7 8 9]; % FIXME: magic constant

Harm_est = fit_core.estimate_harmonics(T_arr, Residuals, Fs, Freq, Harm_to_find, true);

if ~isempty(Harm_est)
    [Result_harm, Residuals_harm, ~] = ...
        fit_core.any_harm_fit(T_arr, Residuals, Freq, Harm_est, f_dev_ppm);

    RMS_old = std(Residuals);
    RMS_new = std(Residuals_harm);

    RMS_Ratio = RMS_old/RMS_new;

    if RMS_Ratio > 5 % FIXME: magic constant
        Result.harm = Result_harm.harm;
        Result.harm_err = Result_harm.harm_err;
    end

else
    RMS_Ratio = 0;
    Residuals_harm = Residuals;
end




end