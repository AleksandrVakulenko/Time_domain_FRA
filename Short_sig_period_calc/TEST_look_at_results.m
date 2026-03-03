


D = Result.f_div_ppm;
Amp = poly3calc(Result.amp_poly, T_arr);
Phi = poly3calc(Result.phi_poly, T_arr);
BG = poly3calc(Result.bg_poly, T_arr);

Freq2 = Freq*(1+D/1e6);

ym = Amp.*sin(2*pi*Freq2*T_arr + Phi/180*pi) + BG;


figure('position', [98 155 742 874])
subplot(2, 1, 1)
hold on
plot(T_arr, V_arr, '-b')
plot(T_arr, ym, '--r', 'LineWidth', 2)

subplot(2, 1, 2)
plot(T_arr, V_arr-ym, '-b')


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




function y = poly3calc(poly, x)
p1 = poly.p1;
p2 = poly.p2;
p3 = poly.p3;

y = p1*x.^2 + p2*x + p3;

end














