

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
% Amp_type = "poly2"; % "poly2", "const", "linear"
% BG_type = "poly2"; % "poly2", "const", "linear"
% Phi_type = "poly2"; % "poly2", "const", "linear"
disp(['Amp type: ' char(Amp_type)])
disp(['Phi type: ' char(Phi_type)])
disp(['BG type: ' char(BG_type)])

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


% disp(Amp_str)
% disp(Phi_str)
% disp(BG_str)

Eq = [Amp_str ' * sin(2*pi*' num2str(F) '*(1+D/1e6)*x + ' Phi_str ') + ' BG_str];

% disp(Eq)
% disp(' ')
% disp([Lower', StartPoint', Upper'])


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

CI = confint(fitresult);
CI = (CI(2, :) - CI(1, :))/2;
Names = coeffnames(fitresult);
for i = 1:numel(Names)
    Value = fitresult.(Names{i});
    Err = CI(i);
    Str= err_str(Value, Err);
    disp([char(Names{i}) ' = ' Str])
end

% FIXME: add errors

D = fitresult.D;

switch Amp_type
    case "const"
        amp_poly_out.p1 = 0;
        amp_poly_out.p2 = 0;
        amp_poly_out.p3 = fitresult.a3;
    case "linear"
        amp_poly_out.p1 = 0;
        amp_poly_out.p2 = fitresult.a2;
        amp_poly_out.p3 = fitresult.a3;
    case "poly2"
        amp_poly_out.p1 = fitresult.a1;
        amp_poly_out.p2 = fitresult.a2;
        amp_poly_out.p3 = fitresult.a3;
    otherwise
        error('unreachable')
end


switch BG_type
    case "const"
        bg_poly_out.p1 = 0;
        bg_poly_out.p2 = 0;
        bg_poly_out.p3 = fitresult.c3;
    case "linear"
        bg_poly_out.p1 = 0;
        bg_poly_out.p2 = fitresult.c2;
        bg_poly_out.p3 = fitresult.c3;
    case "poly2"
        bg_poly_out.p1 = fitresult.c1;
        bg_poly_out.p2 = fitresult.c2;
        bg_poly_out.p3 = fitresult.c3;
    otherwise
        error('unreachable')
end


switch Phi_type
    case "const"
        phi_poly_out.p1 = 0;
        phi_poly_out.p2 = 0;
        phi_poly_out.p3 = fitresult.p3;
    case "linear"
        phi_poly_out.p1 = 0;
        phi_poly_out.p2 = fitresult.p2;
        phi_poly_out.p3 = fitresult.p3;
    case "poly2"
        phi_poly_out.p1 = fitresult.p1;
        phi_poly_out.p2 = fitresult.p2;
        phi_poly_out.p3 = fitresult.p3;
    otherwise
        error('unreachable')
end



Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'f_div_ppm', D);


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







