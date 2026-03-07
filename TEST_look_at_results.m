
clc

Data_time = Synth_time;
V_arr_in = V_arr;
Data_signal = Synth_signal;
Result_in = Result;
% Residuals_in = Residuals;

% Data_time = Synth_time;
% V_arr_in = Residuals;
% Data_signal = Residuals;
% Result_in = Result2;
% Residuals_in = Residuals2;

% Data_time = Synth_time;
% V_arr_in = Residuals2;
% Data_signal = Residuals2;
% Result_in = Result3;
% Residuals_in = Residuals3;

% Harm2_sig = calc_fitted_signal(Result2, Synth_time);
% Harm3_sig = calc_fitted_signal(Result3, Synth_time);
% Data_time = Synth_time;
% V_arr_in = V_arr;
% Data_signal = Synth_signal - Harm2_sig - Harm3_sig;
% Result_in = Result4;
% Residuals_in = Residuals4;

T_arr_min = linspace(T_arr(1), T_arr(end), 1000);

[ym, Amp_full, Phi_full, BG_full] = calc_fitted_signal(Result_in, T_arr);

Residuals_in = Data_signal - ym;


[~, Amp, Phi, BG, Amp_err, Phi_err, BG_err] = ...
    calc_fitted_signal(Result_in, T_arr_min);


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
    disp(['A div : ' num2str(A_div, '%0.2f') ' %'])
    disp(['P div : ' num2str(P_div, '%0.3f') ' deg'])
    disp(['C div : ' num2str(C_div, '%0.2f') ' %'])


    disp([newline 'Calc values: '])
    Str = err_str(Amp_out, Amp_err_out);
    disp(['A = ' Str ' [V]'])
    Str = err_str(Phi_out, Phi_err_out);
    disp(['P = ' Str ' [deg]'])
    Str = err_str(BG_out, BG_err_out);
    disp(['C = ' Str ' [V]'])

    disp([newline 'Real values: '])
    disp(['A = ' num2str(mean(Props.amp)) ' [V]']);
    disp(['P = ' num2str(mean(Props.phi)) ' [deg]']);
    disp(['C = ' num2str(mean(Props.bg)) ' [V]']);
end
%-------------------------------------------------------------------




% Residuals = V_arr-ym;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(Data_time, Data_signal, '-b')
plot(T_arr, ym, '--r', 'LineWidth', 2)
plot(T_arr, BG_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full+Amp_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full-Amp_full, '--k', 'LineWidth', 1)
title('Signal')

subplot(2, 1, 2)
plot(T_arr, Residuals_in, '-b')
yline(std(Residuals_in)*2)
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
    
    Amp = poly3calc(Result_in.amp_poly, T_arr);
    Phi = poly3calc(Result_in.phi_poly, T_arr);
    BG = poly3calc(Result_in.bg_poly, T_arr);
    Amp_err = poly3calc(Result_in.amp_poly_err, T_arr);
    Phi_err = poly3calc(Result_in.phi_poly_err, T_arr);
    BG_err = poly3calc(Result_in.bg_poly_err, T_arr);

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











