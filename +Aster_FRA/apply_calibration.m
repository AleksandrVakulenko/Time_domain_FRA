
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
    klog.disp(['Number of data to calibrate: ' num2str(N1)], "debug_full");
end

if isempty(Calibration_set)
    % FIXME: (2) opens file from disk every time
    Calibration_set = Aster_calibration.open_storage();
end
Range_list = [Calibration_set.range];
ind = find(Range_list == Range_N);
if isempty(ind)
    error(['could not find calibration data for range: ' num2str(Range_N)]);
end
Calibration_data = Calibration_set(ind);


[Amp_cal, Amp_err, Phi_cal, Phi_err] = Calibration_function(Calibration_data, ...
    Freq_arr, Range_N);

% FIXME: (3) delete this sections if errors are not scalar anymore
if numel(Amp_err) == 1
    Amp_err = Amp_err*ones(size(Freq_arr));
end
if numel(Phi_err) == 1
    Phi_err = Phi_err*ones(size(Freq_arr));
end


Res_out = Res_arr.*Amp_cal; % "*" is res, "/" is cur amp
Phi_out = Phi_arr - Phi_cal;
Amp_cal_err = Amp_err; % FIXME: (2) maybe +additional error as below for Phi?
Phi_cal_err = Phi_err + 0.05*Phi_cal; % FIXME: (3) magic constant

end



function [Amp, Res_err, Phi, Phi_err] = Calibration_function(Calibration_data, ...
    Freq_arr, Range_N)

freq_log = log10(Freq_arr);

F_LIMIT = Aster_FRA.range_freq_limit(Range_N); % Hz

Res_obj = Calibration_data.res;
Phi_obj = Calibration_data.phi;

Res_err = Calibration_data.res_err;
Phi_err = Calibration_data.phi_err;

if Freq_arr > F_LIMIT*1.0001
    Amp = [];
    Phi = [];
else
    Amp = feval(Res_obj, freq_log);
    Phi = feval(Phi_obj, freq_log);
    Amp = reshape(Amp, 1, numel(Amp));
    Phi = reshape(Phi, 1, numel(Phi));
end

end
















