

clc

Fs = 10e3; % [1/s]
Duration = 5; % [s]
Noise_scale = 1;


Time = 0:1/Fs:Duration-1/Fs;



% Signal = zeros(size(Time));
% Signal = 1.0*sin(2*pi*10*Time + 10/180*pi) + ...
%          0.5*sin(2*pi*50*Time + 45/180*pi);
Signal_clear = 0.1*sin(2*pi*10*Time + 10/180*pi)+1;


Noise = test_gen.current_noise_gen(Time)/3e-10*Noise_scale;
% Noise = 0.05*sin(2*pi*50*Time + 10/180*pi);
% Noise = 2*(rand(size(Time))-0.5)*0.1;
Synth_signal = Signal_clear + Noise;


Signal_filt = fft_brf(Synth_signal, Fs, -80, 11, []);

hold on
plot(Time, Synth_signal, '-b')
plot(Time, Signal_filt, '--r')
% plot(Time, Signal, '.g')
plot(Time, Signal_clear, '.g')


% plot(abs((FFT)))

%%

clc

Signal_filt = fft_brf(Synth_signal, Fs, -80, 0.00, 0.04);
Signal_filt = fft_brf(Signal_filt, Fs, -80, 0.08, []);

hold on
plot(Synth_time, Synth_signal, '-b')
plot(Synth_time, Signal_filt, '--r')

DFT_single_freq(Synth_time, Synth_signal, 0.05)
DFT_single_freq(Synth_time, Signal_filt, 0.05)


%%

clc

fft_plot(Synth_signal, Fs);
fft_plot(Signal_filt, Fs);







%%

function Signal_filt = fft_brf(Signal, Fs, ValueDB, Freq_min, Freq_max)
    if mod(numel(Signal), 2) == 1
        Signal(end) = [];
        flag = true;
    else
        flag = false;
    end
    
    L = numel(Signal);
    FFT_freq = Fs*(0:(L/2-1))/L;
    
    FFT = fft(Signal)/numel(Signal);
    FFT = FFT_erase_zone(FFT, FFT_freq, ValueDB, Freq_min, Freq_max);
    
    FFT2 = flip(fft(FFT));
    
    FFT2(2:end+1) = FFT2;
    FFT2(1) = FFT2(2);
    FFT2(end) = [];
    
    Signal_filt = real(FFT2);
    if flag
        Signal_filt(end+1) = Signal_filt(end);
    end
end


function FFT = FFT_erase_freq(FFT, FFT_freq, Freq_filt)
    [~, ind1] = min(abs(FFT_freq - Freq_filt));
    ind2 = 2 + numel(FFT) - ind1;
    FFT(ind1) = 0;
    FFT(ind2) = 0;
end


function FFT = FFT_erase_zone(FFT, FFT_freq, ValueDB, Freq_min, Freq_max)
arguments
    FFT
    FFT_freq
    ValueDB
    Freq_min
    Freq_max = []
end
    if isempty(Freq_max)
        Freq_max = FFT_freq(end);
    end
    [~, ind11] = min(abs(FFT_freq - Freq_min));
    if ind11 < 2
        ind11 = 2;
    end
    ind12 = 2 + numel(FFT) - ind11;

    [~, ind21] = min(abs(FFT_freq - Freq_max));
    if ind21 < 2
        ind21 = 2;
    end
    ind22 = 2 + numel(FFT) - ind21;

    FFT(ind11:ind21) = FFT(ind11:ind21)*10^(ValueDB/20);
    FFT(ind22:ind12) = FFT(ind22:ind12)*10^(ValueDB/20);

end
















