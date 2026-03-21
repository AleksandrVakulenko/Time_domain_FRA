
Synth_flag = false;
Show_channel = 2;

if Synth_flag
    Props_in_1 = Props_1;
    Props_in_2 = Props_2;
else
    Props_in_1 = [];
    Props_in_2 = [];
end

if Show_channel == 1
    Estimations_in = Estimations_1;
    Props = Props_in_1;
elseif Show_channel == 2

    Estimations_in = Estimations_2;
    Props = Props_in_2;
else
    error('wrong channel number')
end



% Estimations_in = Estimations_extra;
% Estimations_in = Estimations_low;

Est_time = ([Estimations_in.t_max] + [Estimations_in.t_min])/2;
Est_amp = [Estimations_in.amp];
Est_amperr = [Estimations_in.a_err];

Est_phi = [Estimations_in.phi];
Est_phierr = [Estimations_in.p_err];

Est_bg = [Estimations_in.bg];
Est_bgerr = [Estimations_in.c_err];

if ~isempty(Props)
    Props_amp = Props.amp;
    Props_phi = Props.phi;
    Props_bg = Props.bg;
    
    Props_amp = interp1(Synth_time, Props_amp, Est_time);
    Props_phi = interp1(Synth_time, Props_phi, Est_time);
    Props_bg = interp1(Synth_time, Props_bg, Est_time);
end

Est_full_time = linspace(T_arr(1), T_arr(end), 10);
Est_full_time_norm = Est_full_time/Period;
Est_time_norm = Est_time/Period;
amp_poly = fit(Est_time_norm', Est_amp', 'poly1');
Amp_fit = feval(amp_poly, Est_full_time_norm);

phi_poly = fit(Est_time_norm', Est_phi', 'poly1');
Phi_fit = feval(phi_poly, Est_full_time_norm);

bg_poly = fit(Est_time_norm', Est_bg', 'poly2');
BG_fit = feval(bg_poly, Est_full_time_norm);


% figure('position', [360 205 882 784])

subplot(2, 2, 1)
hold on
if Synth_flag
    plot(Est_time, Props_amp, '.b')
end
plot(Est_time, Est_amp, '.r')
plot(Est_full_time, Amp_fit, '.-k')
% errorbar(Est_time, Est_amp, Est_amperr, '.')
ylabel('Amp')
legend({'Props', 'Est'}, 'Location', 'best')

subplot(2, 2, 2)
hold on
if Synth_flag
    plot(Est_time, Props_phi, '.b')
end
plot(Est_time, Est_phi, '.r')
plot(Est_full_time, Phi_fit, '.-k')
% errorbar(Est_time, Est_phi, Est_phierr, '.')
ylabel('Phi, [deg]')

subplot(2, 2, 3)
hold on
if Synth_flag
    plot(Est_time, Props_bg, '.b')
end
plot(Est_time, Est_bg, '.r')
plot(Est_full_time, BG_fit, '.-k')
% errorbar(Est_time, Est_bg, Est_bgerr, '.')
ylabel('bg')

% plot(Est_time, Ext_amp, '.')





%% Live view of estimation fit

hold on


for i = 1:numel(Estimations_in)
    
    A = Estimations_in(i).amp;
    P = Estimations_in(i).phi;
    C = Estimations_in(i).bg;
    fit_res = Estimations_in(i).fitres;

    T_min = Estimations_in(i).t_min;
    T_max = Estimations_in(i).t_max;
    range = T_arr >= T_min & T_arr <= T_max;
    T_arr_part = T_arr(range);

    ym = feval(fit_res, T_arr_part);
    cla
    plot(Synth_time, Synth_signal, '-b')
    plot(T_arr_part, ym, '-r', 'LineWidth', 2)
    drawnow

    pause(0.02)

    disp(['A: ' num2str(A) ' P: ' num2str(P) ' C: ' num2str(C)])

end

disp('-----------------------')
disp(['A: ' num2str(Props.amp(1)) ...
      ' P: ' num2str(Props.phi(1)) ...
      ' C: ' num2str(Props.bg(1))])





% plot(T_arr, ym, '-r', 'LineWidth', 2)

xline(Estimations_in(1).t_min)
xline(Estimations_in(1).t_max)











