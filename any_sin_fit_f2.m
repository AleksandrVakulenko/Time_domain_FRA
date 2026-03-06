

function Result = ...
    any_sin_fit_f2(Time, Signal, Freq, Estimations, Properties)

F = Freq;
P = 1/F;
Period = P;

Est_time = ([Estimations.t_max] + [Estimations.t_min])/2;
Est_amp = [Estimations.amp];
Est_phi = [Estimations.phi];
Est_bg = [Estimations.bg];
Est_time_norm = Est_time/Period;


[Amp_type, BG_type, Phi_type] = prop_parser(Properties);
disp(['Amp type: ' char(Amp_type)]); % FIXME: debug
disp(['Phi type: ' char(Phi_type)]);
disp(['BG type: ' char(BG_type)]);

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
        Amp_str = func_constructor([], 'a');
        a3 = mean(Est_amp);
        Lower = [Lower -inf];
        StartPoint = [StartPoint a3];
        Upper = [Upper inf];
    case "linear"
        Amp_str = func_constructor([X_arr(1) X_arr(3)], 'a');
        amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
        a2 = feval(amp_poly, X_arr(1)/Period);
        a3 = feval(amp_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint a2 a3];
        Upper = [Upper +inf +inf];
    case "poly2"
        Amp_str = func_constructor(X_arr, 'a');
        amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
        a1 = feval(amp_poly, X_arr(1)/Period); % FIXME: use feval once for all
        a2 = feval(amp_poly, X_arr(2)/Period);
        a3 = feval(amp_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint a1 a2 a3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


switch BG_type
    case "const"
        BG_str = func_constructor([], 'c');
        c3 = mean(Est_bg);
        Lower = [Lower -inf];
        StartPoint = [StartPoint c3];
        Upper = [Upper inf];
    case "linear"
        BG_str = func_constructor([X_arr(1) X_arr(3)], 'c');
        bg_poly = fit(Est_time_norm', Est_bg', 'poly2');
        c2 = feval(bg_poly, X_arr(1)/Period);
        c3 = feval(bg_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint c2 c3];
        Upper = [Upper +inf +inf];
    case "poly2"
        BG_str = func_constructor(X_arr, 'c');
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
        Phi_str = func_constructor([], 'p');
        p3 = mean(Est_phi);
        Lower = [Lower -inf];
        StartPoint = [StartPoint p3];
        Upper = [Upper +inf];
    case "linear"
        Phi_str = func_constructor([X_arr(1) X_arr(3)], 'p');
        phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
        p2 = feval(phi_poly, X_arr(1)/Period);
        p3 = feval(phi_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint p2 p3];
        Upper = [Upper +inf +inf];

    case "poly2"
        Phi_str = func_constructor(X_arr, 'p');
        phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
        p1 = feval(phi_poly, X_arr(1)/Period); % FIXME: use feval once for all
        p2 = feval(phi_poly, X_arr(2)/Period);
        p3 = feval(phi_poly, X_arr(3)/Period);
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint p1 p2 p3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


Eq = [Amp_str ' * sin(2*pi*' num2str(F) '*(1+0/1e6)*x + ' Phi_str '/180*pi) + ' BG_str];



ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-12; % FIXME: default
opts.TolFun = 1e-12; % default
opts.Display = 'Off';

opts.Lower = Lower;
opts.StartPoint = StartPoint;
opts.Upper = Upper;


[fitresult, gof] = fit(Time', Signal', ft, opts);

% CI = confint(fitresult);
% CI = (CI(2, :) - CI(1, :))/2;
% Names = coeffnames(fitresult);
% for i = 1:numel(Names)
%     Value = fitresult.(Names{i});
%     Err = CI(i);
%     Str= err_str(Value, Err);
%     disp([char(Names{i}) ' = ' Str])
% end

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



