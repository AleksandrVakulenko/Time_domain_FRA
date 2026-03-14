function Amp = find_spectrum_amps(Time, Signal, Freq_list)
    Amp = zeros(size(Freq_list));
    for i = 1:numel(Freq_list)
        F = Freq_list(i);
        Scale = 1.01;
        LB = F/Scale;
        HB = F*Scale;
        Freq_list_part = 10.^linspace(log10(LB), log10(HB), 20);
    
        Amp_part = zeros(size(Freq_list_part));
        for k = 1:numel(Freq_list_part)
            Freq = Freq_list_part(k);
            Amp_part(k) = DFT_single_freq(Time, Signal, Freq);
        end
        Amp(i) = max(Amp_part);
    end
end