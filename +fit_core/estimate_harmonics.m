
function Harm_est = estimate_harmonics(T_arr, V_arr, Fs, freq, Harm_num, do_not_disp)
arguments
T_arr
V_arr
Fs
freq
Harm_num
do_not_disp = false
end

Harm_num(Harm_num == 1) = [];

if ~isempty(Harm_num)

    [V_arr, F_lim] = apply_nuttall(V_arr, Fs, freq);

    % FIXME: disp
    if ~do_not_disp
        if ~isempty(F_lim)
            disp(['Nuttall window is used' newline]);
        else
            disp(['noise calc without window' newline])
        end
    end

    % NOTE: do not use for noise amp calc
    
    [~, nf_calc] = fit_core.noise_amp_calc(freq, T_arr, V_arr, Fs, F_lim);

    HNR_min_dB = 10; % FIXME: magic constant "harm to noise ratio"

    k = 0;
    Harm_est = struct('n', [], 'amp', [], 'phi', []);
    for hn = Harm_num
        % FIXME: fit_core.DFT_single_freq could return empty
        [Amp_DFT, Phi_DFT] = fit_core.DFT_single_freq(T_arr, V_arr, hn*freq);
        if Amp_DFT > 10^(HNR_min_dB/20)*nf_calc(hn*freq)
            k = k + 1;
            Harm_est(k).n = hn;
            Harm_est(k).amp = Amp_DFT;
            Harm_est(k).phi = Phi_DFT;
            Harm_est(k).status = 'est_1';
            if ~do_not_disp
            disp('GOOD'); %FIXME: disp
            disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V']); %FIXME: disp
            disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
                '    ' newline ...
                'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline]); %FIXME: disp
            end
        else
            if ~do_not_disp
            disp('BAD'); %FIXME: disp
            disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V']); %FIXME: disp
            disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
                '    ' newline ...
                'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline]); %FIXME: disp
            end
        end
    end
    if k == 0
        Harm_est = [];
    end

else
    Harm_est = [];
end

end
