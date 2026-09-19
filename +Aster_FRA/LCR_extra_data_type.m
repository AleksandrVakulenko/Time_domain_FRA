
% FIXME: (3) add info header / add class constructor

classdef LCR_extra_data_type

    methods (Access = public, Static)
        function v = get_version()
            v = [1 0 0];
        end
    end

    properties (Access = public)

        freq double; % Measurment frequency
        ch_data_1 TDFRA_fit_core.Ch_data_type; % V ch
        ch_data_2 TDFRA_fit_core.Ch_data_type; % I ch

        result_1 TDFRA_fit_core.Result_type;
        result_2 TDFRA_fit_core.Result_type;

        residuals_1 double
        residuals_2 double

        score

        used_ranges double % all used ranges
        aster_range double % range for this results

        % FIXME: (3) delete this
        DEBUG % legacy debug data

    end

end










