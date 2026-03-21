
function Harm_est = estimate_harmonics(T_arr, V_arr, Fs, freq, Harm_num)

Harm_num(Harm_num == 1) = [];

if ~isempty(Harm_num)

    [V_arr, F_lim] = apply_nuttall(V_arr, Fs, freq);

    % FIXME: debug print
    if ~isempty(F_lim)
        disp(['Nuttall window is used' newline]);
    else
        disp(['noise calc without window' newline])
    end

    % NOTE: do not use for noise amp calc
    [~, nf_calc] = noise_amp_calc(freq, T_arr, V_arr, Fs, F_lim);

    HNR_min_dB = 10; % FIXME: magic constant "harm to noise ratio"

    k = 0;
    Harm_est = struct('n', [], 'amp', [], 'phi', []);
    for hn = Harm_num
        [Amp_DFT, Phi_DFT] = DFT_single_freq(T_arr, V_arr, hn*freq);
        if Amp_DFT > 10^(HNR_min_dB/20)*nf_calc(hn*freq)
            k = k + 1;
            Harm_est(k).n = hn;
            Harm_est(k).amp = Amp_DFT;
            Harm_est(k).phi = Phi_DFT;
            Harm_est(k).status = 'est_1';
            disp('GOOD')
            disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V'])
            disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
                '    ' newline ...
                'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline])
        else
            disp('BAD')
            disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V'])
            disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
                '    ' newline ...
                'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline])
        end
    end
    if k == 0
        Harm_est = [];
    end

else
    Harm_est = [];
end

end
