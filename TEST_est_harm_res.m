
% NOTE: TEST script for fit_core::estimate_harms_from_res()

clc

Noise_freq_low = freq*max(Harm_num)
Noise_rms = fit_core.noise_rms_calc(Data_signal, Fs, Noise_freq_low)


%%

Fs_new = DEBUG_1.Fs_new;

T_arr_new = DEBUG_1.T_arr_new;

Residuals_new = Residuals_1;

%%
clc

% Input args:
% - T_arr_new
% - Residuals_new
% - Fs_new
% - freq
% - Noise_rms
% - Harm_num

% Output:
% Harm_est
% 

Harm_est = fit_core.estimate_harms_from_res(T_arr_new, Residuals_new, freq, ...
    Noise_rms, Harm_num)



%%

plot(T_arr_new, Residuals_new)

yline(Value)



