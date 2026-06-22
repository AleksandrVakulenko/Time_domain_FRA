
function [Fig] = init_Aster_FRA_gui()

Fig_name = 'FRA GUI';

Screen_size = get(0, 'ScreenSize');
Screen_size(1:2) = [];
Screen_hor = Screen_size(1);
Screen_vert = Screen_size(2);


Aspect_ratio = 4/3;
Horizontal_part = 0.53;

Hor_size = round(Screen_hor*Horizontal_part);
Vert_size = round(Hor_size/Aspect_ratio);

Left_margin = 0.05;
Top_margin = 0.10;

Hor_pos = Screen_hor*Left_margin;
Vert_pos = Screen_vert - (Screen_vert*Top_margin + Vert_size);
Figure_pos = [Hor_pos, Vert_pos, Hor_size, Vert_size];

Fig = figure('Position', Figure_pos, ...
             'Name', Fig_name,'NumberTitle', 'off', ...
             'MenuBar', 'figure', 'Resize', 'off');

Ax1 = axes('Parent', Fig, 'Position', [0.480 0.557 0.504 0.406]);
Ax2 = axes('Parent', Fig, 'Position', [0.480 0.064 0.504 0.406]);

CB = @(a, b) disp('Stop button'); % FIXME: debug

Control_Frame = uipanel('parent', Fig, 'position', [0.0 0.5 0.3 0.5]);

Stop_button = uicontrol('parent', Control_Frame, ...
                   'Style', 'pushbutton', ...
                   'units', 'normalized', ...
                   'position', [0.05 0.85 0.15 0.15/Aspect_ratio], ...
                   'string', 'Stop', ...
                   'Callback', CB, ...
                   'BackgroundColor', [0.9 0.4 0.4]);

Data = struct('axes_top', Ax1, 'axes_bot', Ax2, 'stop_button', Stop_button);
Fig.UserData = Data;

end


