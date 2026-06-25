
function [Amp_err_rel, Phi_err_abs] = get_instr_errors(range_num)

Temp_diff = 10; % K

switch range_num

    case 1
        Basic_amp_error = 0.1; % [%]
        Temp_error = 5; % [ppm]
		Phi_err_mult = 1;
		
    case 2
        Basic_amp_error = 0.05; % [%]
        Temp_error = 5; % [ppm]
		Phi_err_mult = 1;

    case 3
        Basic_amp_error = 0.1; % [%]
        Temp_error = 10; % [ppm]
		Phi_err_mult = 1;

    case 4
        Basic_amp_error = 1; % [%]
        Temp_error = 25; % [ppm]
		Phi_err_mult = 2;

    case 5
        Basic_amp_error = 5; % [%]
        Temp_error = 250; % [ppm]
		Phi_err_mult = 5;

    case 6
        Basic_amp_error = 5; % [%]
        Temp_error = 500; % [ppm]
		Phi_err_mult = 10;

    otherwise
        error('Wrong range number')

end

% NOTE: 0.05 is too low
% NOTE: maybe need 0.10
Phi_err_abs_basic = 0.08; % [deg] % FIXME: magic constant

Amp_err_rel = Basic_amp_error/100 + Temp_error*1e-6*Temp_diff;
Phi_err_abs = Phi_err_abs_basic*Phi_err_mult; 

end



