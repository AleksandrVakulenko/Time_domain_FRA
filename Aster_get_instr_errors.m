
function [Amp_err_rel, Phi_err_abs] = Aster_get_instr_errors(range_num)

Temp_diff = 10; % K

switch range_num

    case 1
        Basic_amp_error = 0.1; % [%]
        Temp_error = 5; % [ppm]

    case 2
        Basic_amp_error = 0.05; % [%]
        Temp_error = 5; % [ppm]

    case 3
        Basic_amp_error = 0.1; % [%]
        Temp_error = 10; % [ppm]

    case 4
        Basic_amp_error = 1; % [%]
        Temp_error = 25; % [ppm]

    case 5
        Basic_amp_error = 5; % [%]
        Temp_error = 250; % [ppm]

    case 6
        Basic_amp_error = 5; % [%]
        Temp_error = 500; % [ppm]

    otherwise
        error('Wrong range number')

end

Amp_err_rel = Basic_amp_error/100 + Temp_error*1e-6*Temp_diff;
Phi_err_abs = 0.2; % FIXME: magic constant

end



