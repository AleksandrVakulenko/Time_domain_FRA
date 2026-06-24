
% FIXME: add header

classdef LCR_result_type

    properties (Access = public)

        freq doube; % Measurment frequency

        res_abs double; % Resistance absolute value
        res_abs_err double; % Error of resistance absolute value

        phi = Phase_diff; % Resistance phase
        phi_err = Phase_diff_error; % Error of resistance phase

        % FIXME: add harm struct data type
        harm2 = Harm_2_out_arr; % Resistance harmonics struct

        cap_par = C_par; % FIXME: delete this

        current = []; % FIXME: debug; previously: Cur;
        current_error = []; % FIXME: debug; previously: Cur_err;
        voltage = []; % FIXME: debug; previously: Volt1;
        voltage_error = [];% FIXME: debug; previously: Volt1_err;

        r_scale = R_Scale;
        range_n double; % The range number of FRA device used for this measurement


    end

end



% Result.res_abs = Res;
% Result.res_abs_err = Res_err;
% 
% Result.phi = Phase_diff;
% Result.phi_err = Phase_diff_error;
% 
% Result.harm2 = Harm_2_out_arr;
% 
% Result.cap_par = C_par;
% Result.r_scale = R_Scale;
% Result.current = []; % FIXME: debug; previously: Cur;
% Result.current_error = []; % FIXME: debug; previously: Cur_err;
% Result.voltage = []; % FIXME: debug; previously: Volt1;
% Result.voltage_error = [];% FIXME: debug; previously: Volt1_err;
% 
% Result.range_n = Range_N;
% Result.freq = freq;









