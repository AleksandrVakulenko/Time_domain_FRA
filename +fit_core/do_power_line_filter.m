function [Signal_f, Cut_FOP] = do_power_line_filter(Time, Signal, Fs, Freq, Rej_freq)
arguments
    Time
    Signal
    Fs
    Freq
    Rej_freq {mustBeMember(Rej_freq, [50, 60])} = 50;
end

Min_freq_to_filt = 2; % [Hz]

Period = 1/Freq;
Time_length = Time(end) - Time(1);
Period_counter = Time_length/Period;
Freq_res = 1./Time_length;

Rej_span = 2;
if Rej_span < 2*Freq_res
    Rej_span = 2*Freq_res;
end

Rej_freq_low = Rej_freq - Rej_span/2;
Rej_freq_high = Rej_freq + Rej_span/2;

if Fs > 1000 && Freq > Min_freq_to_filt && ...
        (Freq < 0.9*Rej_freq_low || Freq > 1.1*Rej_freq_high)
    Signal_f = fft_band_rejection(Signal, Fs, -120, Rej_freq_low, Rej_freq_high);
    Cut_FOP = 0.12*Period_counter;
else
    Signal_f = Signal;
    Cut_FOP = 0;
    disp('NO FILTER')
end

end