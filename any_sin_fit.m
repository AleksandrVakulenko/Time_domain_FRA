

function [Result, Residuals, DEBUG] = ...
    any_sin_fit(Time, Signal, Freq, Estimations, Properties, Harm_est)

Period = 1/Freq;

if ~isempty(Properties)
    [Amp_type, BG_type, Phi_type] = prop_parser(Properties);
else
    Amp_type = "const";
    Phi_type = "const";
    BG_type = "const";
end

if numel(Estimations) > 1
    Est_time = ([Estimations.t_max] + [Estimations.t_min])/2;
    Est_amp = [Estimations.amp];
    Est_phi = [Estimations.phi];
    Est_bg = [Estimations.bg];
elseif numel(Estimations) == 1
    Est_time = [Time(1) Time(2)];
    Est_amp = [Estimations.amp Estimations.amp];
    Est_phi = [Estimations.phi Estimations.phi];
    Est_bg = [Estimations.bg Estimations.bg];
    Amp_type = "const";
    Phi_type = "const";
    BG_type = "const";
else
    Est_time = [Time(1) Time(2)];
    Est_amp = 0;
    Est_phi = 0;
    Est_bg = 0;
    Amp_type = "const";
    Phi_type = "const";
    BG_type = "const";
end

% FIXME: debug print
disp(['Amp type: ' char(Amp_type)]);
disp(['Phi type: ' char(Phi_type)]);
disp(['BG type: ' char(BG_type)]);

Est_time_norm = Est_time/Period;


% D = 0; % FIXME: freq div start value
% Lower = [-300];
% StartPoint = [D];
% Upper = [+300];
Lower = [];
StartPoint = [];
Upper = [];

X_arr = [Time(1), Time(round(end/2)), Time(end)];


switch Amp_type
    case "const"
        Amp_str = fit_helper.func_constructor([], 'a');
        a3 = mean(Est_amp);
        Lower = [Lower 0];
        StartPoint = [StartPoint a3];
        Upper = [Upper inf];
    case "linear"
        Amp_str = fit_helper.func_constructor([X_arr(1) X_arr(3)], 'a');
        amp_poly = fit(Est_time_norm', Est_amp', 'poly1');
        a2 = feval(amp_poly, X_arr(1)/Period);
        a3 = feval(amp_poly, X_arr(3)/Period);
        Lower = [Lower 0 0];
        StartPoint = [StartPoint a2 a3];
        Upper = [Upper +inf +inf];
    case "poly2"
        Amp_str = fit_helper.func_constructor(X_arr, 'a');
        amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
        a1 = feval(amp_poly, X_arr(1)/Period); % FIXME: use feval once for all
        a2 = feval(amp_poly, X_arr(2)/Period);
        a3 = feval(amp_poly, X_arr(3)/Period);
        Lower = [Lower 0 0 0];
        StartPoint = [StartPoint a1 a2 a3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


switch BG_type
    case "const"
        BG_str = fit_helper.func_constructor([], 'c');
        c3 = mean(Est_bg);
        Lower = [Lower -inf];
        StartPoint = [StartPoint c3];
        Upper = [Upper inf];
    case "linear"
        BG_str = fit_helper.func_constructor([X_arr(1) X_arr(3)], 'c');
        bg_poly = fit(Est_time_norm', Est_bg', 'poly1');
        c2 = feval(bg_poly, X_arr(1)/Period);
        c3 = feval(bg_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint c2 c3];
        Upper = [Upper +inf +inf];
    case "poly2"
        BG_str = fit_helper.func_constructor(X_arr, 'c');
        bg_poly = fit(Est_time_norm', Est_bg', 'poly2');
        c1 = feval(bg_poly, X_arr(1)/Period); % FIXME: use feval once for all
        c2 = feval(bg_poly, X_arr(2)/Period);
        c3 = feval(bg_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint c1 c2 c3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


switch Phi_type
    case "const"
        Phi_str = fit_helper.func_constructor([], 'p');
        p3 = mean(Est_phi);
        Lower = [Lower -180];
        StartPoint = [StartPoint p3];
        Upper = [Upper +180];
    case "linear"
        Phi_str = fit_helper.func_constructor([X_arr(1) X_arr(3)], 'p');
        phi_poly = fit(Est_time_norm', Est_phi', 'poly1');
        p2 = feval(phi_poly, X_arr(1)/Period);
        p3 = feval(phi_poly, X_arr(3)/Period);
        Lower = [Lower -180 -180];
        StartPoint = [StartPoint p2 p3];
        Upper = [Upper +180 +180];

    case "poly2"
        Phi_str = fit_helper.func_constructor(X_arr, 'p');
        phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
        p1 = feval(phi_poly, X_arr(1)/Period); % FIXME: use feval once for all
        p2 = feval(phi_poly, X_arr(2)/Period);
        p3 = feval(phi_poly, X_arr(3)/Period);
        Lower = [Lower -180 -180 -180];
        StartPoint = [StartPoint p1 p2 p3];
        Upper = [Upper +180 +180 +180];
    otherwise
        error('unreachable')
end

Freq_div_flag = true; % FIXME: debug
if Freq_div_flag
    F_div_str = '*(1+q/1e6)'; % FIXME: add D (coeffname: q)
    Lower = [Lower -500];
    StartPoint = [StartPoint -150]; % FIXME: magic constant
    Upper = [Upper +500];
else
    F_div_str = '';
end

Eq = [Amp_str ' * sin(2*pi*' num2str(Freq) F_div_str '*x + ' Phi_str '/180*pi) + ' BG_str];

HPref = 'r';
if ~isempty(Harm_est)
    for i = 1:numel(Harm_est)
        Hn = Harm_est(i).n;
        HarmN_eq = [HPref num2str(Hn) 'a' '*sin(2*pi*' ...
            num2str(Hn*Freq) F_div_str '*x + ' HPref num2str(Hn) 'p' '/180*pi)'];
        Eq = [Eq ' + ' HarmN_eq];
        Lower = [Lower Harm_est(i).amp*0.1 Harm_est(i).phi-45];
        StartPoint = [StartPoint Harm_est(i).amp Harm_est(i).phi];
        Upper = [Upper Harm_est(i).amp*10 Harm_est(i).phi+45];
    end
end

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-12; % FIXME: default
opts.TolFun = 1e-12; % default
opts.Display = 'Off';

% FIXME: debug, comment or delete 3 lines
% disp(Eq)
% coeffnames(ft)
% disp(num2str(StartPoint'))

opts.Lower = Lower;
opts.StartPoint = StartPoint;
opts.Upper = Upper;

% FIXME: debug section
% NOTE: used in DEL_plot_fit_ST.m
DEBUG.StartPoint = StartPoint;
DEBUG.X_arr = X_arr;

[fitresult, gof, output] = fit(Time', Signal', ft, opts);

Residuals = output.residuals';

Error_mult = 3; % NOTE: ± N*std

if Freq_div_flag
    D = get_value(fitresult, 'q');
    D_err = get_error(fitresult, 'q')*Error_mult;
else
    D = 0;
    D_err = 0;
end

amp_poly_out.p1 = get_value(fitresult, 'a1');
amp_poly_out.p2 = get_value(fitresult, 'a2');
amp_poly_out.p3 = get_value(fitresult, 'a3');
amp_poly_out.x = X_arr;

bg_poly_out.p1 = get_value(fitresult, 'c1');
bg_poly_out.p2 = get_value(fitresult, 'c2');
bg_poly_out.p3 = get_value(fitresult, 'c3');
bg_poly_out.x = X_arr;

phi_poly_out.p1 = get_value(fitresult, 'p1');
phi_poly_out.p2 = get_value(fitresult, 'p2');
phi_poly_out.p3 = get_value(fitresult, 'p3');
phi_poly_out.x = X_arr;

amp_poly_err.p1 = get_error(fitresult, 'a1')*Error_mult;
amp_poly_err.p2 = get_error(fitresult, 'a2')*Error_mult;
amp_poly_err.p3 = get_error(fitresult, 'a3')*Error_mult;
amp_poly_err.x = X_arr;

bg_poly_err.p1 = get_error(fitresult, 'c1')*Error_mult;
bg_poly_err.p2 = get_error(fitresult, 'c2')*Error_mult;
bg_poly_err.p3 = get_error(fitresult, 'c3')*Error_mult;
bg_poly_err.x = X_arr;

phi_poly_err.p1 = get_error(fitresult, 'p1')*Error_mult;
phi_poly_err.p2 = get_error(fitresult, 'p2')*Error_mult;
phi_poly_err.p3 = get_error(fitresult, 'p3')*Error_mult;
phi_poly_err.x = X_arr;

if ~isempty(Harm_est)
    harm_out = struct('n', [], 'amp', [], 'phi', []);
    harm_err = struct('n', [], 'amp', [], 'phi', []);
    for i = 1:numel(Harm_est)
        hn = Harm_est(i).n;
        harm_out(i).n = hn;
        harm_out(i).amp = get_value(fitresult, [HPref num2str(hn) 'a']);
        harm_out(i).phi = get_value(fitresult, [HPref num2str(hn) 'p']);
        harm_err(i).n = hn;
        harm_err(i).amp = get_error(fitresult, [HPref num2str(hn) 'a'])*Error_mult;
        harm_err(i).phi = get_error(fitresult, [HPref num2str(hn) 'p'])*Error_mult;
    end
else
    harm_out = [];
    harm_err = [];
end

Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'amp_poly_err', amp_poly_err, ...
    'phi_poly_err', phi_poly_err, ...
    'bg_poly_err', bg_poly_err, ...
    'f_div_ppm', D, ...
    'f_dev_ppm_err', D_err, ...
    'fit_function', 'any_sin_fit_f2', ...
    'freq', Freq, ...
    'harm', harm_out, ...
    'harm_err', harm_err);
end






function [Amp_type, BG_type, Phi_type] = prop_parser(Properties)
    P = Properties;
    
    Amp_type = "poly2";
    if P.const_amp > 10 && P.const_amp > P.linear_amp*2
        Amp_type = "const";
    elseif P.linear_amp > 10 
        Amp_type = "linear";
    end
    
    BG_type = "poly2";
    if P.const_bg > 10 && P.const_bg > P.linear_bg*2
        BG_type = "const";
    elseif P.linear_bg > 10 
        BG_type = "linear";
    end
    
    Phi_type = "poly2";
    if P.const_phase > 10 && P.const_phase > P.linear_phase*2
        Phi_type = "const";
    elseif P.linear_phase > 10 
        Phi_type = "linear";
    end
end


function [Value, Err] = get_value(fitresult, Name)
    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    Names = coeffnames(fitresult);
    Names_str = "";
    for i = 1:numel(Names)
        Names_str(i) = string(Names{i});
    end
    ind = find(Names_str == Name);
    if ~isempty(ind)
        Value = fitresult.(Names{ind});
        Err = CI(ind);
    else
        Value = NaN;
        Err = NaN;
    end
end


function Err = get_error(fitresult, Name)
    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    Names = coeffnames(fitresult);
    Names_str = "";
    for i = 1:numel(Names)
        Names_str(i) = string(Names{i});
    end
    ind = find(Names_str == Name);
    if ~isempty(ind)
        Err = CI(ind);
    else
        Err = NaN;
    end
end

% FIXME: unused function: use or delete or put in archive
function [Str, Lower, StartPoint, Upper] = ...
    ploy_str(Time, Period, Phi_type, Pref, Est_time_norm, Est_v, Lower, StartPoint, Upper)

    X_arr = [Time(1), Time(round(end/2)), Time(end)];
    
    switch Phi_type
        case "const"
            Str = fit_helper.func_constructor([], Pref);
            p3 = mean(Est_v);
            Lower = [Lower -inf];
            StartPoint = [StartPoint p3];
            Upper = [Upper +inf];
        case "linear"
            Str = fit_helper.func_constructor([X_arr(1) X_arr(3)], Pref);
            phi_poly = fit(Est_time_norm', Est_v', 'poly2');
            p2 = feval(phi_poly, X_arr(1)/Period);
            p3 = feval(phi_poly, X_arr(3)/Period);
            Lower = [Lower -inf -inf];
            StartPoint = [StartPoint p2 p3];
            Upper = [Upper +inf +inf];
        case "poly2"
            Str = fit_helper.func_constructor(X_arr, Pref);
            phi_poly = fit(Est_time_norm', Est_v', 'poly2');
            p1 = feval(phi_poly, X_arr(1)/Period); % FIXME: use feval once for all
            p2 = feval(phi_poly, X_arr(2)/Period);
            p3 = feval(phi_poly, X_arr(3)/Period);
            Lower = [Lower -inf -inf -inf];
            StartPoint = [StartPoint p1 p2 p3];
            Upper = [Upper +inf +inf +inf];
        otherwise
            error('unreachable')
    end
end






















