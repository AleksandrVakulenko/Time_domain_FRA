
%NOTE: TEST for noise_rms_calc functions

clc

Noise_freq_low = freq*max(Harm_num);

Noise_rms = noise_rms_calc(Residuals_in, Fs, Noise_freq_low);


disp(['Noise rms = ' num2str(Noise_rms*1e3, '%0.2f') ' mV'])
