

function Result = ...
    any_sin_fit_f(Time, Signal, Freq, Estimations, Properties)

F = Freq;
P = 1/F;
Period = P;

Est_time = ([Estimations.t_max] + [Estimations.t_min])/2;
Est_amp = [Estimations.amp];
Est_phi = [Estimations.phi];
Est_bg = [Estimations.bg];
Est_time_norm = Est_time/Period;


[Amp_type, BG_type, Phi_type] = prop_parser(Properties);
% "poly2", "const", "linear"
disp(['Amp type: ' char(Amp_type)]);  % FIXME: debug
disp(['Phi type: ' char(Phi_type)]);
disp(['BG type: ' char(BG_type)]);

D = 0; % FIXME: freq div start value
Lower = [-300];
StartPoint = [D];
Upper = [+300];


switch Amp_type
    case "const"
        Amp_str = 'a3';
        a3 = mean(Est_amp);
        Lower = [Lower -inf];
        StartPoint = [StartPoint a3];
        Upper = [Upper inf];
    case "linear"
        Amp_str = ['(a2*(x/' num2str(P) ') + a3)'];
        amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
        a2 = amp_poly.p1;
        a3 = amp_poly.p2;
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint a2 a3];
        Upper = [Upper +inf +inf];
    case "poly2"
        Amp_str = ['(a1*(x/' num2str(P) ')^2 + a2*(x/' num2str(P) ') + a3)'];
        amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
        a1 = amp_poly.p1;
        a2 = amp_poly.p2;
        a3 = amp_poly.p3;
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint a1 a2 a3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


switch BG_type
    case "const"
        BG_str = 'c3';
        c3 = mean(Est_bg);
        Lower = [Lower -inf];
        StartPoint = [StartPoint c3];
        Upper = [Upper +inf];
    case "linear"
        BG_str = ['c2*(x/' num2str(P) ') + c3'];
        bg_poly = fit(Est_time_norm', Est_bg', 'poly2');
        c2 = bg_poly.p2;
        c3 = bg_poly.p3;
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint c2 c3];
        Upper = [Upper +inf +inf];
    case "poly2"
        BG_str = ['c1*(x/' num2str(P) ')^2 + c2*(x/' num2str(P) ') + c3'];
        bg_poly = fit(Est_time_norm', Est_bg', 'poly2');
        c1 = bg_poly.p1;
        c2 = bg_poly.p2;
        c3 = bg_poly.p3;
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint c1 c2 c3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


switch Phi_type
    case "const"
        Phi_str = 'p3/180*pi';
        p3 = mean(Est_phi);
        Lower = [Lower -inf];
        StartPoint = [StartPoint p3];
        Upper = [Upper +inf];
    case "linear"
        Phi_str = ['(p2*(x/' num2str(P) ') + p3)/180*pi'];
        phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
        p2 = phi_poly.p1;
        p3 = phi_poly.p2;
        Lower = [Lower -inf -inf];
        StartPoint = [StartPoint p2 p3];
        Upper = [Upper +inf +inf];

    case "poly2"
        Phi_str = ['(p1*(x/' num2str(P) ')^2 + p2*(x/' num2str(P) ') + p3)/180*pi'];
        phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
        p1 = phi_poly.p1;
        p2 = phi_poly.p2;
        p3 = phi_poly.p3;
        Lower = [Lower -inf -inf -inf];
        StartPoint = [StartPoint p1 p2 p3];
        Upper = [Upper +inf +inf +inf];
    otherwise
        error('unreachable')
end


Eq = [Amp_str ' * sin(2*pi*' num2str(F) '*(1+D/1e6)*x + ' Phi_str ') + ' BG_str];


ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % FIXME: default
opts.TolFun = 1e-6; % default
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


D = fitresult.D;
D_err = get_error(fitresult, 'D');

amp_poly_out.p1 = get_value(fitresult, 'a1');
amp_poly_out.p2 = get_value(fitresult, 'a2');
amp_poly_out.p3 = get_value(fitresult, 'a3');

bg_poly_out.p1 = get_value(fitresult, 'c1');
bg_poly_out.p2 = get_value(fitresult, 'c2');
bg_poly_out.p3 = get_value(fitresult, 'c3');

phi_poly_out.p1 = get_value(fitresult, 'p1');
phi_poly_out.p2 = get_value(fitresult, 'p2');
phi_poly_out.p3 = get_value(fitresult, 'p3');


amp_poly_err.p1 = get_error(fitresult, 'a1');
amp_poly_err.p2 = get_error(fitresult, 'a2');
amp_poly_err.p3 = get_error(fitresult, 'a3');

bg_poly_err.p1 = get_error(fitresult, 'c1');
bg_poly_err.p2 = get_error(fitresult, 'c2');
bg_poly_err.p3 = get_error(fitresult, 'c3');

phi_poly_err.p1 = get_error(fitresult, 'p1');
phi_poly_err.p2 = get_error(fitresult, 'p2');
phi_poly_err.p3 = get_error(fitresult, 'p3');



Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'amp_poly_err', amp_poly_err, ...
    'phi_poly_err', phi_poly_err, ...
    'bg_poly_err', bg_poly_err, ...
    'f_div_ppm', D, ...
    'f_dev_ppm_err', D_err, ...
    'fit_function', 'any_sin_fit_f' ...
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






% FIXME: debug zone (put in Fern module)
function [Str, Value, Err] = err_str(Value, Err)
if Err == 0
    Ne = 0;
else
    Ne = floor(log10(abs(Err)));
end
if Value == 0
    Nv = 0;
else
    Nv = floor(log10(abs(Value)));
end
if Nv <= Ne
    Nv = Nv-1;
else
    Nv = Ne;
end
Err = round(Err./10.^(Ne-1)).*10.^(Ne-1);
Value = round(Value./10.^(Nv)).*10.^(Nv);
Str = [num2str(Value) ' ± ' num2str(Err)];
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
        Value = 0;
        Err = 0;
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
        Err = 0;
    end
end



