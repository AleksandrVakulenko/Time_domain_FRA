
function data_gather_plot(Ax, T_arr, V_arr, Outliers_range, Result, style_num)

    cla(Ax);

    [Data, Outlier, Fit] = get_plot_style(style_num, numel(T_arr));

    plot(T_arr(~Outliers_range), V_arr(~Outliers_range), ...
        Data.stile, 'Color', Data.color, 'LineWidth', Data.linewidth, ...
        'MarkerSize', Data.marker_size, 'Parent', Ax)

    plot(T_arr(Outliers_range), V_arr(Outliers_range), ...
        Outlier.style, 'Color', Outlier.color, 'Linewidth', Outlier.linewidth, ...
        'MarkerSize', Outlier.marker_size, 'Parent', Ax)

    if ~isempty(Result)
        Fit_y_1 = fit_viewer.calc_fitted_signal(Result, T_arr); % FIXME: UNCOMMENT
        plot(T_arr, Fit_y_1, ...
            Fit.style, 'Color', Fit.color, 'LineWidth', Fit.linewidth, ...
            'MarkerSize', Fit.marker_size, 'Parent', Ax)
    end

end



function [Data, Outlier, Fit] = get_plot_style(style_num, N)
arguments
    style_num
    N = []
end

if style_num == 1
    Data.color = 'b';
    Data.stile = '-';
    Data.marker_size = 5;
    Data.linewidth = 1;

    Outlier.color = 'r';
    Outlier.style = '.';
    Outlier.marker_size = 5;
    Outlier.linewidth = 1;

    Fit.color = 'k';
    Fit.style = '-';
    Fit.marker_size = 5;
    Fit.linewidth = 1;


elseif style_num == 2
    Data.color = double([0x00 0x21 0x81])/255;
    Data.stile = '.';
    Data.marker_size = Marker_size_calc(N)*0.8 + 2;
    Data.linewidth = Line_width_calc(N)*0.9; % NOTE: need update

    Outlier.color = double([0x70 0x90 0x80])/255*1.2;
    Outlier.style = '.';
    Outlier.marker_size = Marker_size_calc(N)*0.8 + 2;
    Outlier.linewidth = Line_width_calc(N)*0.9; % NOTE: need update

    Fit.color = double([0xFF 0x4a 0x00])/255;
    Fit.style = '-';
    Fit.marker_size = Marker_size_calc(N)*0.8;  % NOTE: need update
    Fit.linewidth = Line_width_calc(N)*0.9;

else
    error('wrong plot style value')
end

end



function Size = Line_width_calc(N)

Size = -0.001*N + 2.1;
if Size > 2
    Size = 2;
end
if Size < 1.6
    Size = 1.6;
end

end

function Size = Marker_size_calc(N)

Size = 1.278e-05*N^2 - 0.02517*N + 17.39;
if Size > 15
    Size = 15;
end
if Size < 5
    Size = 5;
end

end

