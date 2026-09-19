
% FIXME: (2) may be unused

function [Res_to_noise, Residuals_rms, Noise_rms] = ...
    calc_res_to_noise(Ch_data, Result, Harm_num)

Freq = Result.freq;
Fs = Ch_data.fs;
Ch_1_time = Ch_data.time;
Ch_1_V = Ch_data.voltage;
Outliers = Ch_data.outliers_range;

Ch_1_time = Ch_1_time(~Outliers);
Ch_1_V = Ch_1_V(~Outliers);

Noise_rms = TDFRA_fit_core.noise_rms_calc(Ch_1_V, Fs, Freq, Harm_num);
ym = TDFRA_fit_viewer.calc_fitted_signal(Result, Ch_1_time);

Residuals_1 = Ch_1_V - ym;

Residuals_rms = sqrt(mean(Residuals_1.^2));

Res_to_noise = Residuals_rms/Noise_rms;

end