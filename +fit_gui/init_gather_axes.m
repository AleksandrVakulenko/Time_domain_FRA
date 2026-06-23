
function [Axes_arr] = init_gather_axes(Fig_or_ax1, ax2)
arguments
    Fig_or_ax1
    ax2 = []
end

if class(Fig_or_ax1) == "matlab.ui.Figure"
    F_ch = Fig_or_ax1.Children;
    N = numel(F_ch);
    Replace_axes = false;
    if N ~= 2
        Replace_axes = true;
    else
        for i = 1:N
            if class(F_ch) ~= "matlab.graphics.axis.Axes"
                Replace_axes = true;
            end
        end
    end

    if Replace_axes
        delete(F_ch);
        Axes_arr = create_axes(Fig_or_ax1);
    else
        ind = axes_sort_y(F_ch);
        Axes_arr = F_ch(ind);
    end

elseif class(Fig_or_ax1) == "matlab.graphics.axis.Axes" && ...
        class(ax2) == "matlab.graphics.axis.Axes"
    Axes_arr = [Fig_or_ax1, ax2];

elseif isempty(ax2) && numel(Fig_or_ax1) == 2 && ...
        class(Fig_or_ax1) == "matlab.graphics.axis.Axes"
    Axes_arr = Fig_or_ax1;

else
    Axes_arr = [];

end

end


function ind = axes_sort_y(Ax_arr)

y_pos = zeros(size(Ax_arr));
for i = 1:numel(Ax_arr)
    pos = Ax_arr(i).Position;
    y_pos(i) = pos(2);
end

[~, ind] = sort(y_pos, 1, "descend");

end

function Axes_arr = create_axes(Fig)
if ~isempty(Fig)
    figure(Fig)

    Ax1 = subplot(2, 1, 1);
    grid on
    grid minor
    box on
    hold on
    cla

    Ax2 = subplot(2, 1, 2);
    grid on
    grid minor
    box on
    hold on
    cla

    Axes_arr = [Ax1 Ax2];
else
    Axes_arr = [];
end
end