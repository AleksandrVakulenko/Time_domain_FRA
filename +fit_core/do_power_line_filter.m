function [Signal_f, Cut_FOP] = do_power_line_filter(Time, Signal, Fs, Freq, Rej_freq)
arguments
    Time
    Signal
    Fs
    Freq
    Rej_freq {mustBeMember(Rej_freq, [50, 60])} = 50;
end

% NOTE: experimental
Freq_diff = abs(Rej_freq - Freq);
if Freq_diff > 12
    Rej_span_basic = 5;
else
    Rej_span_basic = Freq_diff/4;
end
if Rej_span_basic < 0.25
    Rej_span_basic = 0.25;
end
% ------------------

Min_freq_to_filt = 2; % [Hz]
Fs_minimum = 1000; % [Hz]

Period = 1/Freq;
Time_length = Time(end) - Time(1);
Period_counter = Time_length/Period;
Freq_resolution = 1./Time_length;

Rej_span = Rej_span_basic;
if Rej_span < 2*Freq_resolution
    Rej_span = 2*Freq_resolution;
end

Filter_tau = 0.2; % [s] FIXME: must be a function of filter props
Cut_FOP_basic = Filter_tau/Period;

Rej_freq_low = Rej_freq - Rej_span/2;
Rej_freq_high = Rej_freq + Rej_span/2;

if Rej_freq_low < Rej_freq*0.6 || Rej_freq_high > Rej_freq*1.4
    Signal_f = Signal;
    Cut_FOP = 0;
    return;
end

if Fs > Fs_minimum && Freq > Min_freq_to_filt && ...
        (Freq < 0.99*Rej_freq_low || Freq > 1.01*Rej_freq_high)
    Signal_f = fft_band_rejection(Signal, Fs, -80, Rej_freq_low, Rej_freq_high);
    Cut_FOP = 0.12*Period_counter;
    if Cut_FOP < Cut_FOP_basic
        Cut_FOP = Cut_FOP_basic;
    end
else
    Signal_f = Signal;
    Cut_FOP = 0;
end

if Cut_FOP/Period_counter > 0.3
    Signal_f = Signal;
    Cut_FOP = 0;
end


end








