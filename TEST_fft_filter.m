
clc

Fs = 10e3; % [1/s]
Duration = 5; % [s]
Noise_scale = 1;


Time = 0:1/Fs:Duration-1/Fs;



% Signal = zeros(size(Time));
% Signal = 1.0*sin(2*pi*10*Time + 10/180*pi) + ...
%          0.5*sin(2*pi*50*Time + 45/180*pi);
Signal_clear = 0.1*sin(2*pi*10*Time + 10/180*pi);


Noise = test_gen.current_noise_gen(Time)/3e-10*Noise_scale;
% Noise = 0.05*sin(2*pi*50*Time + 10/180*pi);
Signal = Signal_clear + Noise;

if mod(numel(Signal), 2) == 1
    Time(end) = [];
    Signal(end) = [];
end


% plot(Time, Signal)
% fft_plot(Signal, Fs)

L = numel(Signal);
FFT_freq = Fs*(0:(L/2-1))/L;

FFT = fft(Signal)/numel(Signal);

FFT = FFT_erase_zone(FFT, FFT_freq, 45, 55);
FFT = FFT_erase_zone(FFT, FFT_freq, 145, 155);

FFT2 = flip(fft(FFT));

FFT2(2:end+1) = FFT2;
FFT2(1) = FFT2(2);
FFT2(end) = [];

FFT2 = real(FFT2);

hold on
plot(Time, Signal, '-b')
plot(Time, (FFT2), '--r')
% plot(Time, Signal, '.g')
plot(Time, Signal_clear, '.g')


% plot(abs((FFT)))


%%

clc

fft_plot(Signal, Fs);
fft_plot(FFT2, Fs);



function FFT = FFT_erase_freq(FFT, FFT_freq, Freq_filt)
    [~, ind1] = min(abs(FFT_freq - Freq_filt));
    ind2 = 2 + numel(FFT) - ind1;
    FFT(ind1) = 0;
    FFT(ind2) = 0;
end


function FFT = FFT_erase_zone(FFT, FFT_freq, Freq_min, Freq_max)
arguments
    FFT
    FFT_freq
    Freq_min
    Freq_max = []
end
    if isempty(Freq_max)
        Freq_max = FFT_freq(end);
    end
    [~, ind11] = min(abs(FFT_freq - Freq_min));
    ind12 = 2 + numel(FFT) - ind11;

    [~, ind21] = min(abs(FFT_freq - Freq_max));
    ind22 = 2 + numel(FFT) - ind21;

    FFT(ind11:ind21) = 0;
    FFT(ind22:ind12) = 0;

end



