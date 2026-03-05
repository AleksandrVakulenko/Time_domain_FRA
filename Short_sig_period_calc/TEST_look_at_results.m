
T_arr_min = linspace(T_arr(1), T_arr(end), 1000);

D = Result.f_div_ppm;
Amp = poly3calc(Result.amp_poly, T_arr_min, Period);
Phi = poly3calc(Result.phi_poly, T_arr_min, Period);
BG = poly3calc(Result.bg_poly, T_arr_min, Period);

Amp_err = poly3calc_err(Result.amp_poly_err, T_arr_min, Period);
Phi_err = poly3calc_err(Result.phi_poly_err, T_arr_min, Period);
BG_err = poly3calc_err(Result.bg_poly_err, T_arr_min, Period);

Freq2 = Freq*(1+D/1e6);

Amp_full = poly3calc(Result.amp_poly, T_arr, Period);
Phi_full = poly3calc(Result.phi_poly, T_arr, Period);
BG_full = poly3calc(Result.bg_poly, T_arr, Period);

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
plot(Synth_time, Props.amp, '-b')
plot(T_arr_min, Amp, '--r', 'LineWidth', 2)
plot(T_arr_min, Amp+Amp_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, Amp-Amp_err, '-k', 'LineWidth', 0.5)
title('Amp')
legend({'Props', 'Est'}, 'Location', 'best')

subplot(2, 2, 2)
hold on
plot(Synth_time, Props.phi, '-b')
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
plot(Synth_time, Props.bg, '-b')
plot(T_arr_min, BG, '--r', 'LineWidth', 2)
plot(T_arr_min, BG+BG_err, '-k', 'LineWidth', 0.5)
plot(T_arr_min, BG-BG_err, '-k', 'LineWidth', 0.5)
title('background')

subplot(2, 2, 4)
histogram(Residuals, 'Normalization', 'pdf')
title('Residuals histogram')





function y = poly3calc(poly, x, Period)
    p1 = poly.p1;
    p2 = poly.p2;
    p3 = poly.p3;
    
    y = p1*(x/Period).^2 + p2*(x/Period) + p3;
end


% function y_err = poly3calc_err(poly, poly_err, x, Period)
function y_err = poly3calc_err(poly_err, x, Period)
%     p1 = poly.p1;
%     p2 = poly.p2;
%     p3 = poly.p3;

    p1e = poly_err.p1;
    p2e = poly_err.p2;
    p3e = poly_err.p3;
    
%     y = p1*(x/Period).^2 + p2*(x/Period) + p3;
    
    dy_dp1 = (x/Period).^2;
    dy_dp2 = (x/Period);
    dy_dp3 = 1;
    
    y_err1 = dy_dp1*p1e;
    y_err2 = dy_dp2*p2e;
    y_err3 = dy_dp3*p3e;

    y_err = sqrt(y_err1.^2 + y_err2.^2 + y_err3.^2);
    
end











