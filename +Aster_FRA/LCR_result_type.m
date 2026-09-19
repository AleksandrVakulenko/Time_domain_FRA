
% FIXME: (3) add info header , add class constructor

classdef LCR_result_type

    methods (Access = public, Static)
        function v = get_version()
            v = [1 0 0];
        end
    end

    properties (Access = public)

        freq double; % Measurment frequency
        gen_amp double; % Measurment voltage level
        gen_dc double; % Measurment DC bias level

        res_abs double; % Resistance absolute value
        res_abs_err double; % Error of resistance absolute value

        phi double; % Resistance phase
        phi_err double; % Error of resistance phase

        harm Aster_FRA.LCR_harm_result_type ;% Resistance harmonics struct

        cap_par double; % Cap value for result estimation

        current double;
        current_error double;
        voltage double;
        voltage_error double;

        r_scale double; % V to Amp scale coefficient
        range_n double; % The range number of FRA device used for this measurement


    end

end










