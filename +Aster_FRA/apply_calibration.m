
% FIXME: add force flag to calibration to preserve harmonics

function [Res_out, Phi_out, Amp_cal_err, Phi_cal_err] = ...
    apply_calibration(Range_N, Freq_arr, Res_arr, Phi_arr, Calibration_set)
arguments
    Range_N
    Freq_arr
    Res_arr
    Phi_arr
    Calibration_set = []
end

N1 = numel(Freq_arr);
N2 = numel(Res_arr);
N3 = numel(Phi_arr);
if N1 ~= N2 || N1 ~= N3 || N2 ~= N3
    error('Freq, Res and Phi arrays must have same size')
end
if N1 > 1
    disp(['Number of data to calibrate: ' num2str(N1)]); % FIXME: disp
end

if isempty(Calibration_set)
    Calibration_set = Aster_calibration.open_storage(); % FIXME: get from outside
end
Range_list = [Calibration_set.range];
ind = find(Range_list == Range_N);
if isempty(ind)
    error(['could not find calibration data for range: ' num2str(Range_N)]);
end
Calibration_data = Calibration_set(ind);


[Amp_cal, Amp_err, Phi_cal, Phi_err] = Calibration_function(Calibration_data, ...
    Freq_arr, Range_N);

% FIXME: delete this sections if errors are not scalar anymore
if numel(Amp_err) == 1
    Amp_err = Amp_err*ones(size(Freq_arr));
end
if numel(Phi_err) == 1
    Phi_err = Phi_err*ones(size(Freq_arr));
end

% ----- FIXME: experimental part -----
% FIXME: delete this
% Alpha_min = 0.85*ones(size(Phi_arr));
% Alpha = Alpha_min + abs(Phi_arr)/80*(1-Alpha_min);
% Alpha(Phi_arr >= 0) = Alpha_min;
% Alpha(Phi_arr <= -80) = 1;
% Phi_cal = Phi_cal * Alpha;
% ----- end of experimantal part -----


Res_out = Res_arr.*Amp_cal; % "*" is res, "/" is cur amp
Phi_out = Phi_arr - Phi_cal;
Amp_cal_err = Amp_err; % FIXME: undone
Phi_cal_err = Phi_err + 0.05*Phi_cal; % FIXME: magic constant




end



function [Amp, Res_err, Phi, Phi_err] = Calibration_function(Calibration_data, ...
    Freq_arr, Range_N)

freq_log = log10(Freq_arr);

F_LIMIT = Aster_FRA.range_freq_limit(Range_N); % Hz

Res_obj = Calibration_data.res;
Phi_obj = Calibration_data.phi;

Res_err = Calibration_data.res_err;
Phi_err = Calibration_data.phi_err;

if Freq_arr > F_LIMIT*1.0001 % FIXME:
    Amp = [];
    Phi = [];
else
    Amp = feval(Res_obj, freq_log);
    Phi = feval(Phi_obj, freq_log);
    Amp = reshape(Amp, 1, numel(Amp));
    Phi = reshape(Phi, 1, numel(Phi));
end

end
















