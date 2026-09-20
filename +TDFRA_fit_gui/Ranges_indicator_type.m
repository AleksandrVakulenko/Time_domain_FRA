
% FIXME: (1) add visible on/off method

classdef Ranges_indicator_type < handle

    properties (Access = private)
        Range_ind_color_green = [0.20 0.90 0.20];
        Range_ind_color_white = [0.85 0.85 0.85];
        Range_ind_color_gray = [0.35 0.35 0.35];

        NR
        Range_ind_arr = [];
        Frame
    end

    methods (Access = public)

        function obj = Ranges_indicator_type(Control_Frame, Aspect_ratio, Number_of_ranges)

            Ranges_Frame = uipanel('parent', Control_Frame, 'position', ...
                [0.85, 0.025, 0.1 Number_of_ranges*0.1/Aspect_ratio]);

            obj.Frame = Ranges_Frame;

            N = Number_of_ranges;
            obj.NR = N;

            for i = 1:N
                Range_ind = uicontrol('parent', Ranges_Frame, ...
                    'Style', 'pushbutton', ...
                    'units', 'normalized', ...
                    'position', [0, (N-i)/N, 1.0, 1/N], ...
                    'string', num2str(i), ...
                    'BackgroundColor', [0.80 0.80 0.80], ...
                    'Enable', 'inactive', ...
                    'Visible', 'on');
                obj.Range_ind_arr = [obj.Range_ind_arr Range_ind];
            end
            obj.reinit();
        end

        function reinit(obj)
            for i = 1:obj.NR
                obj.Range_ind_arr(i).BackgroundColor = obj.Range_ind_color_gray;
            end
        end

        function set_range(obj, num, possible)
            % FIXME: (2) ugly debug version
            Check_f = @(n) ~(isempty(n) || numel(n) ~= 1 || n < 1 || n > obj.NR);

            if ~Check_f(num)
                obj.reinit();
                warning("Range indicator error")
                return;
            end

            possible = sort(unique(possible));
            for i = possible
                if ~Check_f(i)
                    obj.reinit();
                    warning("Range indicator error")
                    return;
                end
            end

            obj.reinit();
            for i = possible
                obj.Range_ind_arr(i).BackgroundColor = obj.Range_ind_color_white;
            end
            obj.Range_ind_arr(num).BackgroundColor = obj.Range_ind_color_green;
            drawnow

        end

    end


end