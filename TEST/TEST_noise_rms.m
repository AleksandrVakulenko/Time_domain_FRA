
%NOTE: TEST for noise_rms_calc functions

clc


Noise_rms = fit_core.noise_rms_calc(Residuals_in, Fs, freq, Harm_num);


disp(['Noise rms = ' num2str(Noise_rms*1e3, '%0.2f') ' mV'])
