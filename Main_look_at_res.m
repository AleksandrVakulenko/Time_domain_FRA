
clc

% % T_arr = T_arr;
% % Residuals_in = Residuals;

Show_channel = 2;



if  1 == Show_channel
    Ch_data = Ch_data_1;
    Result_in = Result_1;
elseif Show_channel == 2
    Ch_data = Ch_data_2;
    Result_in = Result_2;
else
    error('wrong channel number')
end

T_arr = Ch_data.time;
Data_signal = Ch_data.voltage;

Data_time = T_arr;

T_arr_min = linspace(T_arr(1), T_arr(end), 1000);

[ym, Amp_full, Phi_full, BG_full] = fit_viewer.calc_fitted_signal(Result_in, T_arr);

Harm_y = Harm_calc(Result_in, T_arr);
if ~isempty(Harm_y)
    ym = ym + Harm_y;
end
Residuals_in = Data_signal - ym;

Noise_rms = fit_core.noise_rms_calc(Data_signal, Fs, freq, Harm_num);

[~, Amp, Phi, BG, Amp_err, Phi_err, BG_err] = ...
    fit_viewer.calc_fitted_signal(Result_in, T_arr_min);


% Calc output values and errors ------------------------------------
pps = [0];
Output = fit_viewer.calc_output(Result_in, pps);
Amp_out = Output.amp;
Phi_out = Output.phi;
BG_out = Output.bg;
Amp_err_out = Output.amp_err;
Phi_err_out = Output.phi_err;
BG_err_out = Output.bg_err;
T_out = Output.time;

Freq_dev = Result_in.f_dev_ppm;
Freq_dev_err = Result_in.f_dev_ppm_err;
disp(['Δf = ' num2str(Freq_dev, '%0.1f') ' ± ' ...
    num2str(Freq_dev_err, '%0.1f') ' ppm'])


if Output.single_flag
    disp([newline 'Calc values (mean):'])
    Str = err_str(Amp_out, Amp_err_out);
    disp(['A = ' Str ' [V]'])
    Str = err_str(Phi_out, Phi_err_out);
    disp(['P = ' Str ' [deg]'])
    Str = err_str(BG_out, BG_err_out);
    disp(['C = ' Str ' [V]'])

    SNR = 20*log10(Amp_out/Noise_rms);
    disp([newline 'Noise level:'])
    disp(['Noise amp = ' num2str(Noise_rms*1e3, '%0.2f') ' mV'])
    disp(['SNR = ' num2str(Amp_out/Noise_rms, '%0.2f')])
    disp(['SNR = ' num2str(SNR, '%0.2f') ' dB'])

end
%-------------------------------------------------------------------


disp([newline '     Harmonics:' newline '-----------------------'])
Harm_disp(Result_in);
disp(['-----------------------'])

% Residuals = V_arr-ym;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(Data_time, Data_signal, '.b')
plot(T_arr, ym, '--r', 'LineWidth', 2)
plot(T_arr, BG_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full+Amp_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full-Amp_full, '--k', 'LineWidth', 1)
title('Signal')

subplot(2, 1, 2)
plot(T_arr, Residuals_in, '-b')
yline(std(Residuals_in)*2)
yline(Noise_rms, '-r')
title('Residuals')


figure('position', [871 333 746 696])

subplot(2, 2, 1)
hold on
plot(T_arr_min, Amp, '--r', 'LineWidth', 2)
plot(T_arr_min, Amp+Amp_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Amp-Amp_err, '-k', 'LineWidth', 0.5)
errorbar(T_out, Amp_out, Amp_err_out, '.m', 'MarkerSize', 12);
title('Amp')

subplot(2, 2, 2)
hold on
plot(T_arr_min, Phi, '--r', 'LineWidth', 2)
plot(T_arr_min, Phi+Phi_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Phi-Phi_err, '-k', 'LineWidth', 0.5)
errorbar(T_out, Phi_out, Phi_err_out, '.m', 'MarkerSize', 12);
title('Phi, deg')
% Max = max([Props.phi Phi]);
% Min = min([Props.phi Phi]);
% Max = Max + abs(Max-Min)*1.1;
% Min = Min - abs(Max-Min)*1.1;
% ylim([Min Max])

subplot(2, 2, 3)
hold on
plot(T_arr_min, BG, '--r', 'LineWidth', 2)
plot(T_arr_min, BG+BG_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, BG-BG_err, '-k', 'LineWidth', 0.5)
errorbar(T_out, BG_out, BG_err_out, '.m', 'MarkerSize', 12);
title('background')

subplot(2, 2, 4)
histogram(Residuals_in, 'Normalization', 'pdf')
title('Residuals histogram')




%%
HHH = Harm_calc(Result, T_arr);
plot(T_arr, HHH);
%%




function disp_harm_info(harm, Freq)
hn = harm.n;
A = harm.amp;
P = harm.phi;
disp(['Harmonic ' num2str(hn) ':'])
disp(['Freq = ' num2str(hn*Freq) ' Hz'])
disp(['A = ' num2str(A) ' V' ...
      newline ...
      'P = ' num2str(P) ' deg' newline])
end

function Harm_check(Result, Props)

Freq = Props.freq;
P_harm = Props.harm;
R_harm = Result.harm;
R_harm_err = Result.harm_err;

disp([newline 'Harmonics:' newline '-----------------------'])
if isempty(R_harm)
    disp([newline 'No harmonic in result struct' newline])
    return
else
end

if isempty(P_harm)
    disp('Wrong harmonics:')
    for i = 1:numel(R_harm)
        disp_harm_info(R_harm(i), Freq)
    end
else
    for i = 1:numel(P_harm)
        hn = P_harm(i).n;
        ind = find([R_harm.n] == hn);
        if ~isempty(ind)
            disp([' Right harmonic: [' num2str(hn) ']'])

            if ~isnan(R_harm_err(ind).amp)
                Str = err_str(R_harm(ind).amp, R_harm_err(ind).amp);
                disp(['A = ' Str ' [V]'])
            else
                disp(['A = ' num2str(R_harm(ind).amp) ' ± NaN [V]'])
            end

            if ~isnan(R_harm_err(ind).phi)
                Str = err_str(R_harm(ind).phi, R_harm_err(ind).phi);
                disp(['P = ' Str ' [deg]'])
            else
                disp(['A = ' num2str(R_harm(ind).phi) ' ± NaN [deg]'])
            end

            disp(' Real values:')
            disp(['A = ' num2str(P_harm(i).amp) ' [V]'])
            disp(['P = ' num2str(P_harm(i).phi) ' [deg]'])
            disp(' ')

            R_harm(ind) = [];
            R_harm_err(ind) = [];
        else
            disp('NO harmonic:')
            disp(['(for) Props harmonic:' '[' num2str(P_harm(i).n) ']'])
            disp_harm_info(P_harm(i), Freq);
            disp(' ')
        end
    end

    if ~isempty(R_harm)
    disp('Wrong harmonics:')
    for i = 1:numel(R_harm)
        disp_harm_info(R_harm(i), Freq)
    end
    end
    
disp(['-----------------------' newline])
end

end


function Harm_disp(Result_in)
Harm = Result_in.harm;
if ~isempty(Harm)
    Freq = Result_in.freq;
%     Freq_dev = Result_in.f_dev_ppm;
%     Freq = Freq * (1 + Freq_dev/1e6);
    for i = 1:numel(Harm)
        hn = Harm(i).n;
        A = Harm(i).amp;
        P = Harm(i).phi;
        disp(['Harmonic ' num2str(hn) ':'])
        disp(['Freq = ' num2str(hn*Freq) ' Hz'])
        disp(['A = ' num2str(A) ' V' ...
              newline ...
              'P = ' num2str(P) ' deg' newline])
    end
end

end

function out = Harm_calc(Result_in, Time)
Harm = Result_in.harm;
if ~isempty(Harm)
    Freq = Result_in.freq;
    Freq_dev = Result_in.f_dev_ppm;
    Freq = Freq * (1 + Freq_dev/1e6);
    out = zeros(size(Time));
    for i = 1:numel(Harm)
        hn = Harm(i).n;
        A = Harm(i).amp;
        P = Harm(i).phi;
        H_value = A*sin(2*pi*hn*Freq*Time + P/180*pi);
        out = out + H_value;
    end
else
    out= [];
end

end







