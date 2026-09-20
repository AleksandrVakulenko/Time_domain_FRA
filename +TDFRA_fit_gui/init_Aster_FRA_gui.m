
function [Fig] = init_FRA_gui()

Fig_name = 'FRA GUI';

Screen_size = get(0, 'ScreenSize');
Screen_size(1:2) = [];
if isunix
    % FIXME: (2) DEBUG section just to use in GNOME env with two monitors
    % NOTE: use 'xrandr --query'
    Screen_hor = Screen_size(1)/2;
    Screen_vert = Screen_size(2);
else
    Screen_hor = Screen_size(1);
    Screen_vert = Screen_size(2);
end

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
grid(Ax1, 'on')
grid(Ax1, 'minor')
box(Ax1, 'on')
hold(Ax1, 'on')
cla(Ax1)

Ax2 = axes('Parent', Fig, 'Position', [0.480 0.064 0.504 0.406]);
grid(Ax2, 'on')
grid(Ax2, 'minor')
box(Ax2, 'on')
hold(Ax2, 'on')
cla(Ax2)





% FIXME: (3) default demo callback of button
CB = @(a, b) disp('Stop button is pressed');

Control_Frame = uipanel('parent', Fig, 'position', [0.0 0.5 0.3 0.5]);

Stop_button = uicontrol('parent', Control_Frame, ...
                   'Style', 'pushbutton', ...
                   'units', 'normalized', ...
                   'position', [0.05 0.85 0.15 0.15/Aspect_ratio], ...
                   'string', 'Stop', ...
                   'Callback', CB, ... % FIXME: (3) demo function?
                   'BackgroundColor', [0.95 0.73 0.73]);

Stop_button.UserData = struct('stop', false);
Stop_button.Callback = @TDFRA_fit_gui.stop_callback;


Underrange_ind_12 = uicontrol('parent', Control_Frame, ...
                   'Style', 'pushbutton', ...
                   'units', 'normalized', ...
                   'position', [0.64,0.9175,0.35,0.075], ...
                   'string', 'Underrange', ...
                   'BackgroundColor', [0.80 0.80 0.80], ...
                   'Enable', 'inactive', ...
                   'Visible', 'on');
Underrange_ind_12.UserData = @(x) set_underrange(x, Underrange_ind_12);


% --- RANGING FRAME ---

% FIXME: (2) add empty Control_Frame and get its content from actual devices

Number_of_ranges = 6; % FIXME: (2) magic constant (Aster specific code)

Ranges_Frame = uipanel('parent', Control_Frame, 'position', ...
    [0.85, 0.025, 0.1 Number_of_ranges*0.1/Aspect_ratio]);

Ranges_ind = TDFRA_fit_gui.Ranges_indicator_type(Control_Frame, ...
    Aspect_ratio, Number_of_ranges);
% ---------------------



Data = struct('axes_top', Ax1, 'axes_bot', Ax2, ...
              'stop_button', Stop_button, ...
              'underrange_ind', Underrange_ind_12, ...
              'range_ind', Ranges_ind);

Fig.UserData = Data;

end




function set_underrange(arg, Underrange_button)

if arg
    Underrange_button.BackgroundColor = [224 31 31]/255;
else
    Underrange_button.BackgroundColor = [0.80 0.80 0.80];
end

end

