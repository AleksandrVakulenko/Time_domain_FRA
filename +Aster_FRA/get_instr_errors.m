
function [Amp_err_rel, Phi_err_abs] = get_instr_errors(range_num)

% NOTE: room T could be any value from 18 [C] to 30 [C]
Temp_diff = 12; % K

% NOTE: 0.05 is too low
% NOTE: maybe need 0.10
Phi_err_abs_basic = 0.08; % [deg] % FIXME: magic constant

[Basic_amp_error, Temp_drift_error, Phi_err_mult] = ...
    get_instr_err_internal_new(range_num);

Amp_err_rel = Basic_amp_error/100 + Temp_drift_error*1e-6*Temp_diff;
Phi_err_abs = Phi_err_abs_basic*Phi_err_mult; 

end


% NOTE: previous version (more errors)
function [Basic_amp_error, Temp_drift_error, Phi_err_mult] = ...
    get_instr_err_internal(range_num)

switch range_num

    case 1
        Basic_amp_error = 0.1; % [%]
        Temp_drift_error = 5; % [ppm]
		Phi_err_mult = 1;
		
    case 2
        Basic_amp_error = 0.05; % [%]
        Temp_drift_error = 5; % [ppm]
		Phi_err_mult = 1;

    case 3
        Basic_amp_error = 0.1; % [%]
        Temp_drift_error = 10; % [ppm]
		Phi_err_mult = 1;

    case 4
        Basic_amp_error = 1; % [%]
        Temp_drift_error = 25; % [ppm]
		Phi_err_mult = 2;

    case 5
        Basic_amp_error = 5; % [%]
        Temp_drift_error = 250; % [ppm]
		Phi_err_mult = 5;

    case 6
        Basic_amp_error = 5; % [%]
        Temp_drift_error = 500; % [ppm]
		Phi_err_mult = 10;

    otherwise
        error('Wrong range number')

end

end



% NOTE: version for new calibration type
function [Basic_amp_error, Temp_drift_error, Phi_err_mult] = ...
    get_instr_err_internal_new(range_num)

switch range_num

    case 1
        Basic_amp_error = 0.1; % [%]
        Temp_drift_error = 5; % [ppm]
		Phi_err_mult = 1;
		
    case 2
        Basic_amp_error = 0.05; % [%]
        Temp_drift_error = 5; % [ppm]
		Phi_err_mult = 1;

    case 3
        Basic_amp_error = 0.1; % [%]
        Temp_drift_error = 10; % [ppm]
		Phi_err_mult = 1;

    case 4
        Basic_amp_error = 1; % [%]
        Temp_drift_error = 25; % [ppm]
		Phi_err_mult = 2;

    case 5
        Basic_amp_error = 1; % [%]
        Temp_drift_error = 250; % [ppm]
		Phi_err_mult = 3;

    case 6
        Basic_amp_error = 1; % [%]
        Temp_drift_error = 500; % [ppm]
		Phi_err_mult = 5;

    otherwise
        error('Wrong range number')

end

end