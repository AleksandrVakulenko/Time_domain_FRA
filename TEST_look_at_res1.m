
clc

% % T_arr = T_arr;
% % Residuals_in = Residuals;

Show_channel = 1;

if  1 == Show_channel
    Data_time = Synth_time;
    V_arr_in = V1_arr;
    Data_signal = Synth_signal_1;
    Result_in = Result_1;
    Props = Props_1;
    T_arr_print = Synth_time;
elseif Show_channel == 2
    Data_time = Synth_time;
    V_arr_in = V2_arr;
    Data_signal = Synth_signal_2;
    Result_in = Result_2;
    Props = Props_2;
    T_arr_print = Synth_time;
else
    error('wrong channel number')
end


T_arr_min = linspace(T_arr_print(1), T_arr_print(end), 1000);

[ym, Amp_full, Phi_full, BG_full] = fit_viewer.calc_fitted_signal(Result_in, T_arr_print);

% Harm_disp(Result_in);

Harm_y = Harm_calc(Result_in, T_arr_print);
if ~isempty(Harm_y)
    ym = ym + Harm_y;
end
Residuals_in = Data_signal - ym;

Noise_freq_low = freq*max(Harm_num);
Noise_rms = noise_rms_calc(Data_signal, Fs, Noise_freq_low);

[~, Amp, Phi, BG, Amp_err, Phi_err, BG_err] = ...
    fit_viewer.calc_fitted_signal(Result_in, T_arr_min);


% Calc output values and errors ------------------------------------
pps = [];
Output = calc_output(Result_in, pps);
Amp_out = Output.amp;
Phi_out = Output.phi;
BG_out = Output.bg;
Amp_err_out = Output.amp_err;
Phi_err_out = Output.phi_err;
BG_err_out = Output.bg_err;
T_out = Output.time;


if Output.single_flag
    A_div = mean(abs(Props.amp - Amp_out)./Props.amp) * 100; % [%]
    P_div = mean(abs(Props.phi - Phi_out)); % [deg]
    C_div = mean(abs(Props.bg - BG_out)./Props.bg) * 100; % [%]
    disp('Deviation from Props:')
    disp(['A div : ' num2str(A_div, '%0.2f') ' %'])
    disp(['P div : ' num2str(P_div, '%0.3f') ' deg'])
    disp(['C div : ' num2str(C_div, '%0.2f') ' %'])


    disp([newline 'Calc values (mean):'])
    Str = err_str(Amp_out, Amp_err_out);
    disp(['A = ' Str ' [V]'])
    Str = err_str(Phi_out, Phi_err_out);
    disp(['P = ' Str ' [deg]'])
    Str = err_str(BG_out, BG_err_out);
    disp(['C = ' Str ' [V]'])

    disp([newline 'Real values (mean):'])
    disp(['A = ' num2str(mean(Props.amp)) ' [V]']);
    disp(['P = ' num2str(mean(Props.phi)) ' [deg]']);
    disp(['C = ' num2str(mean(Props.bg)) ' [V]']);

    SNR = 20*log10(Amp_out/Noise_rms);
    disp([newline 'Noise level:'])
    disp(['Noise amp = ' num2str(Noise_rms*1e3, '%0.2f') ' mV'])
    disp(['SNR = ' num2str(Amp_out/Noise_rms, '%0.2f')])
    disp(['SNR = ' num2str(SNR, '%0.2f') ' dB'])

end
%-------------------------------------------------------------------


Harm_check(Result_in, Props);


% Residuals = V_arr-ym;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(Data_time, Data_signal, '-b')
plot(T_arr_print, ym, '--r', 'LineWidth', 2)
plot(T_arr_print, BG_full, '--k', 'LineWidth', 1)
plot(T_arr_print, BG_full+Amp_full, '--k', 'LineWidth', 1)
plot(T_arr_print, BG_full-Amp_full, '--k', 'LineWidth', 1)
title('Signal')

subplot(2, 1, 2)
plot(T_arr_print, Residuals_in, '-b')
yline(std(Residuals_in)*2)
yline(Noise_rms)
title('Residuals')


figure('position', [871 333 746 696])

subplot(2, 2, 1)
hold on
plot(Data_time, Props.amp, '-b', 'LineWidth', 2)
plot(T_arr_min, Amp, '--r', 'LineWidth', 2)
plot(T_arr_min, Amp+Amp_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Amp-Amp_err, '-k', 'LineWidth', 0.5)
errorbar(T_out, Amp_out, Amp_err_out, '.m', 'MarkerSize', 12);
title('Amp')
legend({'Props', 'Est'}, 'Location', 'best')

subplot(2, 2, 2)
hold on
plot(Data_time, Props.phi, '-b', 'LineWidth', 2)
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
plot(Data_time, Props.bg, '-b', 'LineWidth', 2)
plot(T_arr_min, BG, '--r', 'LineWidth', 2)
plot(T_arr_min, BG+BG_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, BG-BG_err, '-k', 'LineWidth', 0.5)
errorbar(T_out, BG_out, BG_err_out, '.m', 'MarkerSize', 12);
title('background')

subplot(2, 2, 4)
histogram(Residuals_in, 'Normalization', 'pdf')
title('Residuals histogram')




%%
HHH = Harm_calc(Result, T_arr_print);
plot(T_arr_print, HHH);
%%




function Output = calc_output(Result_in, pps)
arguments
    Result_in
    pps = []
end
    T_start = Result_in.amp_poly.x(1);
    T_end = Result_in.amp_poly.x(3);
    Length = T_end - T_start;  % [s]

    flag = false;
    if isempty(pps)
        pps = 5;
        flag = true;
    else

    end

    N = round(Length * pps);
    if N < 1
        N = 5;
        flag = true;
    end
    T_arr = linspace(T_start, T_end, N);
    
    Amp = fit_viewer.poly3calc(Result_in.amp_poly, T_arr);
    Phi = fit_viewer.poly3calc(Result_in.phi_poly, T_arr);
    BG = fit_viewer.poly3calc(Result_in.bg_poly, T_arr);
    Amp_err = fit_viewer.poly3calc(Result_in.amp_poly_err, T_arr);
    Phi_err = fit_viewer.poly3calc(Result_in.phi_poly_err, T_arr);
    BG_err = fit_viewer.poly3calc(Result_in.bg_poly_err, T_arr);

    if flag
        Amp_err = sqrt(std(Amp)^2 + mean(Amp_err).^2);
        Phi_err = sqrt(std(Phi)^2 + mean(Phi_err).^2);
        BG_err = sqrt(std(BG)^2 + mean(BG_err).^2);

        Amp = mean(Amp);
        Phi = mean(Phi);
        BG = mean(BG);

        T_arr = mean(T_arr);
    end

    Output.amp = Amp;
    Output.amp_err = Amp_err;
    Output.phi = Phi;
    Output.phi_err = Phi_err;
    Output.bg = BG;
    Output.bg_err = BG_err;
    Output.time = T_arr;
    Output.freq = Result_in.freq;
    Output.debug_result = Result_in;
    Output.single_flag = flag;
end


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







