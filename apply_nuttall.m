function [Signal_out, F_lim] = apply_nuttall(Signal, freq, Fs)
% Freq limit by number of points (For Nuttall window)
F_lim_window = Fs*(10.^(-1*log10(numel(Signal)) + 0.765));

if freq/F_lim_window > 1.5 % FIXME: magic constant
    Use_window = true;
else
    Use_window = false;
end

% Use_window = false;
% Use_window = true;

% disp(['Use window: ' num2str(Use_window)])
% disp(['Freq = ' num2str(freq) ' Hz'])
% disp(['F_lim = ' num2str(F_lim_window) ' Hz'])
% disp(['R = ' num2str(freq/F_lim_window)])
% disp(' ')

if Use_window
    F_lim = F_lim_window;
else
    F_lim = [];
end

if Use_window
    Window = nuttallwin(numel(Signal)); % Nuttall
    Win_scale = 2.7521;
    Signal_w = Signal.*Window'*Win_scale;
    Signal_out = Signal_w;
else
    Signal_out = Signal;
end

end