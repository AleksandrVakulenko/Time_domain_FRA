

function [Result, Residuals] = ...
    any_sin_fit_f2(Time, Signal, Freq, Estimations, Properties)

Period = 1/Freq;

if ~isempty(Properties)
    [Amp_type, BG_type, Phi_type] = prop_parser(Properties);
    disp(['Amp type: ' char(Amp_type)]); % FIXME: debug
    disp(['Phi type: ' char(Phi_type)]);
    disp(['BG type: ' char(BG_type)]);
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
Est_time_norm = Est_time/Period;


% D = 0; % FIXME: freq div start value
% Lower = [-300];
% StartPoint = [D];
% Upper = [+300];
Lower = [];
StartPoint = [];
Upper = [];

X_arr = [Time(1), Time(round(end/2)), Time(end)];


% In order : Amp_str, BG_str, Phi_str
% to append Lower, StartPoint, Upper in right way
[Amp_str, Lower, StartPoint, Upper] = ...
    ploy_str(Time, Period, Amp_type, 'a', Est_time_norm, Est_amp, ...
    Lower, StartPoint, Upper);

[BG_str, Lower, StartPoint, Upper] = ...
    ploy_str(Time, Period, BG_type, 'c', Est_time_norm, Est_bg, ...
    Lower, StartPoint, Upper);

[Phi_str, Lower, StartPoint, Upper] = ...
    ploy_str(Time, Period, Phi_type, 'p', Est_time_norm, Est_phi, ...
    Lower, StartPoint, Upper);


Eq = [Amp_str ' * sin(2*pi*' num2str(Freq) '*(1+0/1e6)*x + ' Phi_str '/180*pi) + ' BG_str];


ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-12; % FIXME: default
opts.TolFun = 1e-12; % default
opts.Display = 'Off';

opts.Lower = Lower;
opts.StartPoint = StartPoint;
opts.Upper = Upper;


[fitresult, gof, output] = fit(Time', Signal', ft, opts);

Residuals = output.residuals';


try % FIXME: debug
    D = fitresult.D;
    D_err = get_error(fitresult, 'D');
catch
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

amp_poly_err.p1 = get_error(fitresult, 'a1');
amp_poly_err.p2 = get_error(fitresult, 'a2');
amp_poly_err.p3 = get_error(fitresult, 'a3');
amp_poly_err.x = X_arr;

bg_poly_err.p1 = get_error(fitresult, 'c1');
bg_poly_err.p2 = get_error(fitresult, 'c2');
bg_poly_err.p3 = get_error(fitresult, 'c3');
bg_poly_err.x = X_arr;

phi_poly_err.p1 = get_error(fitresult, 'p1');
phi_poly_err.p2 = get_error(fitresult, 'p2');
phi_poly_err.p3 = get_error(fitresult, 'p3');
phi_poly_err.x = X_arr;

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
    'freq', Freq ...
    );

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


function [Str, Lower, StartPoint, Upper] = ...
    ploy_str(Time, Period, Phi_type, Pref, Est_time_norm, Est_v, Lower, StartPoint, Upper)

    X_arr = [Time(1), Time(round(end/2)), Time(end)];
    
    switch Phi_type
        case "const"
            Str = func_constructor([], Pref);
            p3 = mean(Est_v);
            Lower = [Lower -inf];
            StartPoint = [StartPoint p3];
            Upper = [Upper +inf];
        case "linear"
            Str = func_constructor([X_arr(1) X_arr(3)], Pref);
            phi_poly = fit(Est_time_norm', Est_v', 'poly2');
            p2 = feval(phi_poly, X_arr(1)/Period);
            p3 = feval(phi_poly, X_arr(3)/Period);
            Lower = [Lower -inf -inf];
            StartPoint = [StartPoint p2 p3];
            Upper = [Upper +inf +inf];
        case "poly2"
            Str = func_constructor(X_arr, Pref);
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






















