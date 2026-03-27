% NOTE: if you want to find exact freq in fft - use this to trim data
% to length of N*(1/freq)
function [Time, Signal] = signal_cut_by_n_periods(Time, Signal, freq)
    Time_length = Time(end) - Time(1);
    Period_length = Time_length*freq;
    if Period_length < 1
        % FIXME: maybe half period ?
        Time = [];
        Signal = [];
    else
        Delta = abs(round(Period_length)-Period_length);
        if Delta > 0.01 % FIXME: magic constant
            Period_length = floor(Period_length);
            Time_length_new = Period_length*1/freq;
            
            range = Time > Time_length_new + Time(1);
            Time(range) = [];
            Signal(range) = [];
        else
%             'OK'
        end

    end
end