function Harm_est = estimate_harms_from_res(T_arr, Residuals, freq, ...
    Noise_rms, Harm_num)

Sense_level_dB = +2; % [dB] FIXME: magic constant

Harm_num(Harm_num == 1) = [];

Harm_amp_arr = zeros(size(Harm_num));
Harm_amp_arr_dB = zeros(size(Harm_num));
Harm_phi_arr = zeros(size(Harm_num));
for i = 1:numel(Harm_num)
    Harm_freq = freq*Harm_num(i);
    [Harm_amp, Phi_harm] = DFT_single_freq(T_arr, Residuals, Harm_freq);
    Harm_amp_arr(i) = Harm_amp;
    Value = Harm_amp;
    Value = Value/Noise_rms;
    Value = 20*log10(Value);
    Harm_amp_arr_dB(i) = Value;
    Harm_phi_arr(i) = Phi_harm;
end

range = Harm_amp_arr_dB > Sense_level_dB;
Harm_num_out = Harm_num(range);
Harm_amp_arr_dB = Harm_amp_arr_dB(range);
Harm_phi_arr = Harm_phi_arr(range);

N = numel(Harm_num_out);

if N > 0
    Harm_est = struct('n', [], 'amp', [], 'phi', []);
    for i = 1:N
        Harm_est(i).n = Harm_num_out(i);
        Harm_est(i).amp = Harm_amp_arr(i);
        Harm_est(i).phi = Harm_phi_arr(i);
        Harm_est(i).status = "fixed";
    end
else
    Harm_est = [];
end

end