


D = Result.f_div_ppm;
Amp = poly3calc(Result.amp_poly, T_arr, Period);
Phi = poly3calc(Result.phi_poly, T_arr, Period);
BG = poly3calc(Result.bg_poly, T_arr, Period);

Freq2 = Freq*(1+D/1e6);

ym = Amp.*sin(2*pi*Freq2*T_arr + Phi/180*pi) + BG;

Residuals = V_arr-ym;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(T_arr, V_arr, '-b')
plot(T_arr, ym, '--r', 'LineWidth', 2)
title('Signal')

subplot(2, 1, 2)
plot(T_arr, Residuals, '-b')
title('Residuals')


figure('position', [871 333 746 696])

subplot(2, 2, 1)
hold on
plot(T_arr, Props.amp, '-b')
plot(T_arr, Amp, '--r', 'LineWidth', 2)
title('Amp')

subplot(2, 2, 2)
hold on
plot(T_arr, Props.phi, '-b')
plot(T_arr, Phi, '--r', 'LineWidth', 2)
title('Phi, deg')

subplot(2, 2, 3)
hold on
plot(T_arr, Props.bg, '-b')
plot(T_arr, BG, '--r', 'LineWidth', 2)
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














