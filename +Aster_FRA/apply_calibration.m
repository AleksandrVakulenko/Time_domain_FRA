
% FIXME: add force flag to calibration to preserve harmonics

function [Res_out, Phi_out, Amp_cal_err, Phi_cal_err] = ...
    apply_calibration(Range_N, Freq_arr, Res_arr, Phi_arr)

N1 = numel(Freq_arr);
N2 = numel(Res_arr);
N3 = numel(Phi_arr);
if N1 ~= N2 || N1 ~= N3 || N2 ~= N3
    error('Freq, Res and Phi arrays must have same size')
end
N = N1;


Res_out = NaN(size(Freq_arr));
Phi_out = NaN(size(Freq_arr));
Amp_cal_err = NaN(size(Freq_arr));
Phi_cal_err = NaN(size(Freq_arr));

for i = 1:N
    Freq = Freq_arr(i);
    Res = Res_arr(i);
    Phi = Phi_arr(i);

    [Amp_cal, Phi_cal] = Calibration_function(Range_N, Freq);

    % FIXME: split in two if
    if ~isempty(Amp_cal) && ~isnan(Amp_cal) && ~isempty(Phi_cal) && ~isnan(Phi_cal)
        % FIXME: experimental part
        Alpha_min = 0.85;
        if Phi >= 0
            Alpha = Alpha_min;
        elseif Phi <= -80
            Alpha = 1;
        else
            Alpha = Alpha_min + abs(Phi)/80*(1-Alpha_min);
        end
        Phi_cal = Phi_cal * Alpha;
        % end of experimantal part

        Res_out(i) = Res*Amp_cal; % "*" is res, "/" is cur amp
        Phi_out(i) = Phi - Phi_cal;
        Amp_cal_err(i) = 0; % FIXME: undone
        Phi_cal_err(i) = 0.2*Phi_cal; % FIXME: magic constant
    end
end


end



function [Amp, Phi] = Calibration_function(Range, Freq)

freq_log = log10(Freq);

switch Range

    case 1
        F_LIMIT = Aster_FRA.range_freq_limit(1); % Hz

        Amp_model.foo = "Aster_FRA.calibration_model_1";
        Amp_model.A = 0;
        Amp_model.C = 0.9993;
        Amp_model.p = 1;
        Amp_model.x0 = 10;

        Phi_model.foo = "Aster_FRA.calibration_model_1";
        Phi_model.A = -0.5781;
        Phi_model.C = -0.01156;
        Phi_model.p = 6.732;
        Phi_model.x0 = 1;

    case 2
        F_LIMIT = Aster_FRA.range_freq_limit(2); % Hz

        Amp_model.foo = "Aster_FRA.calibration_model_1";
        Amp_model.A = 0;
        Amp_model.C = 0.9998;
        Amp_model.p = 1;
        Amp_model.x0 = 10;

        Phi_model.foo = "Aster_FRA.calibration_model_1";
        Phi_model.A = -0.2505;
        Phi_model.C = 0.04411;
        Phi_model.p = 5.794;
        Phi_model.x0 = -1;

    case 3
        F_LIMIT = Aster_FRA.range_freq_limit(3); % Hz

        Amp_model.foo = "Aster_FRA.calibration_model_1";
        Amp_model.A = 0;
        Amp_model.C = 0.9997;
        Amp_model.p = 1;
        Amp_model.x0 = 10;

        Phi_model.foo = "Aster_FRA.calibration_model_1";
        Phi_model.A = -0.2178;
        Phi_model.C = -0.0007526;
        Phi_model.p = 4.582;
        Phi_model.x0 = 0;

    case 4
        F_LIMIT = Aster_FRA.range_freq_limit(4); % [Hz]

        Amp_model.foo = "Aster_FRA.calibration_model_1";
        Amp_model.A = -0.3144;
        Amp_model.C = 1.003;
        Amp_model.p = 9.478;
        Amp_model.x0 = 0.04901;

        Phi_model.foo = "Aster_FRA.calibration_model_2";
        Phi_model.A = 0.0005951;
        Phi_model.C = -0.02704;
        Phi_model.p = 1.315;
        Phi_model.x0 = -3.537;

    case 5
        F_LIMIT = Aster_FRA.range_freq_limit(5); % Hz

        Amp_model.foo = "Aster_FRA.calibration_model_2";
        Amp_model.A = -0.0003747;
        Amp_model.C = 1.016;
        Amp_model.p = 2.065;
        Amp_model.x0 = -1.604;

        Phi_model.foo = "Aster_FRA.calibration_model_2";
        Phi_model.A = 6.839e-06;
        Phi_model.C = -0.0005538;
        Phi_model.p = 1.277;
        Phi_model.x0 = -7.655;

    case 6
        F_LIMIT = Aster_FRA.range_freq_limit(6); % Hz

        Amp_model.foo = "Aster_FRA.calibration_model_2";
        Amp_model.A = -0.001272;
        Amp_model.C = 1.075;
        Amp_model.p = 1.639;
        Amp_model.x0 = -3.243;

        Phi_model.foo = "Aster_FRA.calibration_model_1";
        Phi_model.A = 0.5725;
        Phi_model.C = 1.172;
        Phi_model.p = 6.137;
        Phi_model.x0 = -3.63;

end

if Freq > F_LIMIT*1.0001 % FIXME:
    Amp = [];
    Phi = [];
else
    Amp = feval(Amp_model.foo, freq_log, Amp_model.x0, Amp_model.p, ...
        Amp_model.C, Amp_model.A);
    Phi = feval(Phi_model.foo, freq_log, Phi_model.x0, Phi_model.p, ...
        Phi_model.C, Phi_model.A);
end

end