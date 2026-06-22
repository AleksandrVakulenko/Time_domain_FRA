


clc

Time_length = 3;

% Fs = Num_of_points

T_arr = linspace(0, Time_length, 500);

V1_arr = sin(2*pi*T_arr) + normrnd(0, 0.05, size(T_arr));
% y = sin(2*pi*x)

Outliers_range_1 = T_arr > 2 & T_arr < 2.4;

fitres = fit(T_arr', V1_arr', 'A*sin(2*pi*x)');
Fit_y_1 = feval(fitres, T_arr);


Periods_counter = 1.4; % FIXME: debug
V2_arr = V1_arr; % FIXME: debug
Outliers_range_2 = Outliers_range_1; % FIXME: debug


%%


Fig = figure;

Ax_1 = subplot(2, 1, 1);
grid on
grid minor
box on
hold on
cla

Ax_2 = subplot(2, 1, 2);
grid on
grid minor
box on
hold on
cla


Axes_arr = init_gather_axes([Ax_1 Ax_2]);

%

if numel(Axes_arr) == 2 && all(isvalid(Axes_arr))
    style_num = 2;

    Ax1 = Axes_arr(1);
    Ax2 = Axes_arr(2);

    data_gather_plot(Ax1, T_arr, V1_arr, ...
        Outliers_range_1, Result_1, style_num);
    title(['Ch 1 (PC: ' num2str(Periods_counter, '%0.3f') ')'], 'Parent', Ax1);
    xlabel('t, s', 'Parent', Ax1)
    ylabel('V1, V', 'Parent', Ax1)

    data_gather_plot(Ax2, T_arr, V2_arr, ...
        Outliers_range_2, Result_2, style_num);
    title('Ch 2', 'Parent', Ax2);
    xlabel('t, s', 'Parent', Ax2);
    ylabel('V2, V', 'Parent', Ax2);

    drawnow
end























