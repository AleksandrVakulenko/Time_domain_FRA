

Est_time = ([Estimations.t_max] + [Estimations.t_min])/2;
Est_amp = [Estimations.amp];
Est_amperr = [Estimations.a_err];

Est_phi = [Estimations.phi];
Est_phierr = [Estimations.p_err];

Est_bg = [Estimations.bg];
Est_bgerr = [Estimations.c_err];


Props_amp = Props.amp;
Props_phi = Props.phi;
Props_bg = Props.bg;

Props_amp = interp1(Synth_time, Props_amp, Est_time);
Props_phi = interp1(Synth_time, Props_phi, Est_time);
Props_bg = interp1(Synth_time, Props_bg, Est_time);



figure('position', [360 205 882 784])

subplot(2, 2, 1)
hold on
plot(Est_time, Props_amp, '.b')
plot(Est_time, Est_amp, '.r')
% errorbar(Est_time, Est_amp, Est_amperr, '.')
ylabel('Amp')
legend({'Props', 'Est'}, 'Location', 'best')

subplot(2, 2, 2)
hold on
plot(Est_time, Props_phi, '.b')
plot(Est_time, Est_phi, '.r')
% errorbar(Est_time, Est_phi, Est_phierr, '.')
ylabel('Phi, [deg]')

subplot(2, 2, 3)
hold on
plot(Est_time, Props_bg, '.b')
plot(Est_time, Est_bg, '.r')
% errorbar(Est_time, Est_bg, Est_bgerr, '.')
ylabel('bg')

% plot(Est_time, Ext_amp, '.')



%%

plot(Est_time, Est_bg, '.')


%%

hold on


for i = 1:numel(Estimations)
    
    A = Estimations(i).amp;
    P = Estimations(i).phi;
    C = Estimations(i).bg;
    fit_res = Estimations(i).fitres;

    T_min = Estimations(i).t_min;
    T_max = Estimations(i).t_max;
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

xline(Estimations(1).t_min)
xline(Estimations(1).t_max)











