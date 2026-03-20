
% FIXME: put in Fern module
% NOTE: unused

function FFT = fft_erase_single_freq(FFT, FFT_freq, Freq_filt)
    [~, ind1] = min(abs(FFT_freq - Freq_filt));
    ind2 = 2 + numel(FFT) - ind1;
    FFT(ind1) = 0;
    FFT(ind2) = 0;
end
