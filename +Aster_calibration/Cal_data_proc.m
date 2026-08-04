

% NOTE: script to create calibration objs

% TODO:
% 1) add calibration quality score


clc

Save_flag = false;

% NOTE: for internal cap 200 [pF]
True_value.phi = -90;
True_value.value = 195.9e-12;
True_value.sample_type = "cap";
Range_N = RN;

% % NOTE: for external res 1000 [Ohm] (RANGE 1)
% True_value.phi = 0;
% True_value.value = 1e3;
% True_value.sample_type = "res";
% Range_N = 1;
% inds = Freq > 10;
% Freq(inds) = [];
% Res(inds) = [];
% Phi(inds) = [];

% % NOTE: for external res 1000 [Ohm] (RANGE 2)
% True_value.phi = 0;
% True_value.value = 1e3;
% True_value.sample_type = "res";
% Range_N = 2;
% inds = Freq > 10;
% Freq(inds) = [];
% Res(inds) = [];
% Phi(inds) = [];

% % NOTE: for external res 1000 [Ohm] (RANGE 3) FIXME: 1kOhm ?
% True_value.phi = 0;
% True_value.value = 1e3;
% True_value.sample_type = "res";
% Range_N = 3;

% % NOTE: for external res 100 [MOhm] (RANGE 4)
% True_value.phi = 0;
% True_value.value = 100e6;
% True_value.sample_type = "res";
% Range_N = 4;


calibration_obj = calibration_fit(Freq, Res, Phi, True_value, Range_N);

if Save_flag
    Folder = '+Aster_calibration/Calibration_matfiles';
    Filename = ['Aster_calibration_N' num2str(Range_N) '.mat'];
    File_addr = fullfile([Folder '/' Filename]);
    save(File_addr, "calibration_obj");
    disp(['Save done: ' File_addr])
end

% ----

if True_value.sample_type == "cap"
    Value_data = 1./(2*pi*Res.*Freq)/True_value.value;
elseif True_value.sample_type == "res"
    Value_data = 1./(Res/True_value.value);
else
    error('Wrong sample type')
end
Phi_data = Phi - True_value.phi;
Freq_log = log10(Freq);
Freq_log_m = min(Freq_log)-0.5:0.01:max(Freq_log)+0.5;
Value_model_res = feval(calibration_obj.res, Freq_log_m);
Value_model_phi = feval(calibration_obj.phi, Freq_log_m);

figure
subplot(2, 1, 1)
hold on
plot(10.^Freq_log, Value_data,  '.b', 'MarkerSize', 12);
plot(10.^Freq_log_m, Value_model_res, '--r');
title(['amp : ' num2str(Range_N)])
set(gca, 'xscale', 'log')
grid on

subplot(2, 1, 2)
hold on
plot(10.^Freq_log, Value_data - feval(calibration_obj.res, Freq_log)',  '.k', 'MarkerSize', 12);
set(gca, 'xscale', 'log')
grid on


figure
subplot(2, 1, 1)
hold on
plot(10.^Freq_log, Phi_data,  '.b', 'MarkerSize', 12);
plot(10.^Freq_log_m, Value_model_phi, '--r');
title(['phi : ' num2str(Range_N)])
set(gca, 'xscale', 'log')
grid on

subplot(2, 1, 2)
hold on
plot(10.^Freq_log, Phi_data - feval(calibration_obj.phi, Freq_log)',  '.k');
set(gca, 'xscale', 'log')
grid on









function [calibration_obj] = calibration_fit(Freq, Res, Phi, True_value, Range_N)

Sample_type = True_value.sample_type;

if Sample_type == "cap"
    Value = 1./(2*pi*Freq.*Res)/True_value.value;
    Phi = Phi - True_value.phi; % NOTE: must be -90 [deg]
elseif Sample_type == "res"
    Value = 1./(Res/True_value.value);
    Phi = Phi - True_value.phi; % NOTE: must be 0 [deg]
else
    error('wrong sample type')
end

% NOTE:
% PHI: 180/pi*atan(10.^x/f0) + (D*x.^3 + A*x.^2 + B*x + C).*soft_window(x, -8, log10(f0));
% AMP: 1/sqrt(1+(10^x/f0)^2) + (a*x^2 + B*x + C)*soft_window(x, -8, log10(f0))

switch Range_N

    case 1
        % NOTE: in case of the 'mean_only' the next 4 values ​​are not used.
        mean_only = true;
        f0_min = 10e3;
        f0_start = 100e3;
        Poly_N_amp = 0;
        Poly_N_phi = 0;

    case 2
        mean_only = true;
        f0_min = 10e3;
        f0_start = 100e3;
        Poly_N_amp = 0;
        Poly_N_phi = 0;

    case 3
        mean_only = true; 
        f0_min = 2000;
        f0_start = 10e3;
        Poly_N_amp = 0;
        Poly_N_phi = 1;

    case 4
        mean_only = false;
        f0_min = 250;
        f0_start = 700;
        Poly_N_amp = 1;
        Poly_N_phi = 2;

    case 5
        mean_only = false;
        f0_min = 5;
        f0_start = 12;
        Poly_N_amp = 2;
        Poly_N_phi = 2;

    case 6
        mean_only = false;
        f0_min = 0.1;
        f0_start = 0.5;
        Poly_N_amp = 2;
        Poly_N_phi = 3;

    otherwise
        error('wrong range num')

end

if mean_only
    [cal_res, res_err] = calibration_fit_internal(Freq, Value, f0_start, ...
        f0_min, 'const', Poly_N_amp);
    [cal_phi, phi_err] = calibration_fit_internal(Freq, Phi, f0_start, ...
        f0_min, 'const', Poly_N_phi);
else
    [cal_res, res_err] = calibration_fit_internal(Freq, Value, f0_start, ...
        f0_min, 'amp', Poly_N_amp);
    [cal_phi, phi_err] = calibration_fit_internal(Freq, Phi, f0_start, ...
        f0_min, 'phi', Poly_N_phi);
end

calibration_obj.res = cal_res;
calibration_obj.res_err = res_err;
calibration_obj.phi = cal_phi;
calibration_obj.phi_err = phi_err;
calibration_obj.range = Range_N;
calibration_obj.date_of_creation = datetime;

end




function [fit_res, c_err] = calibration_fit_internal(Freq, Value, f0_start, f0_min, Eq_type, Poly_N)

arguments
Freq double {mustBeGreaterThan(Freq, 0)}
Value double
f0_start double {mustBeGreaterThan(f0_start, 0)}
f0_min double {mustBeGreaterThan(f0_min, 0)}
Eq_type string {mustBeMember(Eq_type, ["amp", "phi", "const"])}
Poly_N double {mustBeMember(Poly_N, [0, 1, 2, 3, 4, 5])}
end

if Eq_type == "const"
    mean_only_mode = true;
else
    mean_only_mode = false;
end

if mean_only_mode
    Eq_str = 'C + x*0';
else
    if Eq_type == "amp"
        Poly_str = Poly_gen(Poly_N);
        Eq_str = ['1./sqrt(1+(10.^x/f0).^2) + ' ...
            '(' Poly_str ').*soft_window(x, -8, log10(3*f0))'];
        Eq_lite_str = '1./sqrt(1+(10.^x/f0).^2) + C';
    else
        Poly_str = Poly_gen(Poly_N);
        Eq_str = ['180/pi*atan(10.^x/f0) + ' ...
            '(' Poly_str ').*soft_window(x, -8, log10(f0))'];
        Eq_lite_str = '180/pi*atan(10.^x/f0) + C';
    end
end
Freq_log = log10(Freq);

[xData, yData] = prepareCurveData(Freq_log, Value);

if mean_only_mode
    ft_main = fittype(Eq_str , 'independent', 'x', 'dependent', 'y' );
    opts_main = fitoptions('Method', 'NonlinearLeastSquares');
    opts_main.Display = 'Off';
    opts_main.Lower =      [-inf];
    opts_main.StartPoint = [mean(yData)];
    opts_main.Upper =      [inf];

    [fit_res, ~, extra] = fit(xData, yData, ft_main, opts_main);
else
    % - PREFIT -----------------------------------------------------------------
    ft_init = fittype(Eq_lite_str , 'independent', 'x', 'dependent', 'y' );
    opts_init = fitoptions('Method', 'NonlinearLeastSquares');
    opts_init.Display = 'Off';
    opts_init.Lower =      [-inf  f0_min];
    opts_init.StartPoint = [  0   f0_start];
    opts_init.Upper =      [inf   f0_start*100];

    [fit_res, ~, ~] = fit(xData, yData, ft_init, opts_init);
    f0_start_main = fit_res.f0;
    % --------------------------------------------------------------------------

    % - MAIN FIT ---------------------------------------------------------------
    ft_main = fittype(Eq_str , 'independent', 'x', 'dependent', 'y' );
    opts_main = fitoptions('Method', 'NonlinearLeastSquares');
    opts_main.Display = 'Off';
    opts_main.Lower =      [-inf(1, Poly_N+1)   f0_min];
    opts_main.StartPoint = [zeros(1, Poly_N+1)  f0_start_main];
    opts_main.Upper =      [inf(1, Poly_N+1)    f0_start*100];

    [fit_res, ~, extra] = fit(xData, yData, ft_main, opts_main);
    % --------------------------------------------------------------------------
end
residuals = extra.residuals;
r_min = prctile(residuals, 3);
r_max = prctile(residuals, 97);
span = r_max - r_min; % [%]

c_err = span;
if Eq_type == "amp"
    span = span * 100; % NOTE: convert to [%]
else
    % NOTE: else [deg]
end

if span > 1.0 % FIXME: BAD CODE, find new way to estimate fit quality

    disp(['S = ' num2str(span)])
    Freq_log_m = min(Freq_log)-1:0.01:max(Freq_log)+1;
    Value_model = feval(fit_res, Freq_log_m);

    figure
    subplot(2, 1, 1)
    hold on
    plot(Freq_log, Value,  '.b', 'MarkerSize', 12);
    plot(Freq_log_m, Value_model, '--r');
    title(Eq_type)
    grid on
    
    subplot(2, 1, 2)
    hold on
    plot(Freq_log, residuals,  '.k');
    grid on

    error('clibration fit fails: residuals are too much');
end


end




function Poly_str = Poly_gen(Poly_N)

switch Poly_N
    case 0
        Poly_str = 'A1';
    case 1
        Poly_str = 'A1*x + A2';
    case 2
        Poly_str = 'A1*x.^2 + A2*x + A3';
    case 3
        Poly_str = 'A1*x.^3 + A2*x.^2 + A3*x + A4';
    case 4
        Poly_str = 'A1*x.^4 + A2*x.^3 + A3*x.^2 + A4*x + A5';
    case 5
        Poly_str = 'A1*x.^5 + A2*x.^4 + A3*x.^3 + A4*x.^2 + A5*x + A6';
    otherwise
        error('Poly N must be <= 5')
end

end








