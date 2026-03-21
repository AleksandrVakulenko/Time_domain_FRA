


function Noise_rms = noise_rms_calc(Signal, Fs, Noise_freq_low)
    Band_rej_value_dB = -160;
    Noise_sig = apply_nuttall(Signal, Fs);
    Noise_sig_filt = fft_band_rejection(Noise_sig, Fs, Band_rej_value_dB, 0, Noise_freq_low);
    
%     amp_noise = fft_plot(Noise_sig_filt, Fs);
    amp_noise = fft_calc(Noise_sig_filt, Fs);
    amp_noise(1) = [];
    
    Noise_rms = sqrt(sum(amp_noise.^2));
end