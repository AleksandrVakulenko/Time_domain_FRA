
clc

% Result_in = Result;
Result_in = Result2;
% Result_in = Result3;

T_arr_min = linspace(T_arr(1), T_arr(end), 1000);

Amp_full = poly3calc(Result_in.amp_poly, T_arr);
Phi_full = poly3calc(Result_in.phi_poly, T_arr);
BG_full = poly3calc(Result_in.bg_poly, T_arr);

Amp = poly3calc(Result_in.amp_poly, T_arr_min);
Phi = poly3calc(Result_in.phi_poly, T_arr_min);
BG = poly3calc(Result_in.bg_poly, T_arr_min);

Amp_err = poly3calc(Result_in.amp_poly_err, T_arr_min);
Phi_err = poly3calc(Result_in.phi_poly_err, T_arr_min);
BG_err = poly3calc(Result_in.bg_poly_err, T_arr_min);


D = Result_in.f_div_ppm;
Freq2 = Result_in.freq*(1+D/1e6);
ym = Amp_full.*sin(2*pi*Freq2*T_arr + Phi_full/180*pi) + BG_full;

Residuals = V_arr-ym;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(Synth_time, Synth_signal, '-b')
plot(T_arr, ym, '--r', 'LineWidth', 2)
plot(T_arr, BG_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full+Amp_full, '--k', 'LineWidth', 1)
plot(T_arr, BG_full-Amp_full, '--k', 'LineWidth', 1)
title('Signal')

subplot(2, 1, 2)
plot(T_arr, Residuals, '-b')
yline(std(Residuals)*2)
title('Residuals')


figure('position', [871 333 746 696])

subplot(2, 2, 1)
hold on
plot(Synth_time, Props.amp, '-b', 'LineWidth', 2)
plot(T_arr_min, Amp, '--r', 'LineWidth', 2)
plot(T_arr_min, Amp+Amp_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Amp-Amp_err, '-k', 'LineWidth', 0.5)
title('Amp')
legend({'Props', 'Est'}, 'Location', 'best')

subplot(2, 2, 2)
hold on
plot(Synth_time, Props.phi, '-b', 'LineWidth', 2)
plot(T_arr_min, Phi, '--r', 'LineWidth', 2)
plot(T_arr_min, Phi+Phi_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Phi-Phi_err, '-k', 'LineWidth', 0.5)
title('Phi, deg')
% Max = max([Props.phi Phi]);
% Min = min([Props.phi Phi]);
% Max = Max + abs(Max-Min)*1.1;
% Min = Min - abs(Max-Min)*1.1;
% ylim([Min Max])

subplot(2, 2, 3)
hold on
plot(Synth_time, Props.bg, '-b', 'LineWidth', 2)
plot(T_arr_min, BG, '--r', 'LineWidth', 2)
plot(T_arr_min, BG+BG_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, BG-BG_err, '-k', 'LineWidth', 0.5)
title('background')

subplot(2, 2, 4)
histogram(Residuals, 'Normalization', 'pdf')
title('Residuals histogram')








function y = poly3calc(poly, x)
    y1 = poly.p1;
    y2 = poly.p2;
    y3 = poly.p3;

    if ~isnan(y1) && ~isnan(y2)
        xf = poly.x;
        yf = [y1 y2 y3];
        fitres = fit(xf', yf', 'poly2');
        y = feval(fitres, x);
    elseif ~isnan(y2)
        xf = [poly.x(1) poly.x(3)];
        yf = [y2 y3];
        fitres = fit(xf', yf', 'poly1');
        y = feval(fitres, x);
    else
        y = repmat(y3, 1, numel(x));
    end

    y = reshape(y, 1, numel(y));
end















