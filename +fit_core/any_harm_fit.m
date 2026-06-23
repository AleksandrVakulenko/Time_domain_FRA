% ------------------------------------------------------------------------------
%
%        ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂     ⎛⎝( ` ᢍ ´ )⎠⎞ᵐᵘʰᵃʰᵃ  ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂
%
% ------------------------------------------------------------------------------

function [Result, Residuals, DEBUG] = ...
    any_harm_fit(Time, Signal, Freq, Harm_est, Freq_dev_const)

Period = 1/Freq; % FIXME: unused


Lower = [];
StartPoint = [];
Upper = [];

F_dev_str = ['*(' num2str(1+Freq_dev_const/1e6) ')'];

Eq = '';

HPref = 'r';
if ~isempty(Harm_est)
    for i = 1:numel(Harm_est)
        Status = Harm_est(i).status;
        Hn = Harm_est(i).n;
        HarmN_eq = [HPref num2str(Hn) 'a' '*sin(2*pi*' ...
            num2str(Hn*Freq) F_dev_str '*x + ' HPref num2str(Hn) 'p' '/180*pi)'];
        Eq = [Eq ' + ' HarmN_eq];
        if Status == "est_1"
            %FIXME: phi limits?
            Lower = [Lower Harm_est(i).amp*0.05 Harm_est(i).phi-45];
            StartPoint = [StartPoint Harm_est(i).amp Harm_est(i).phi];
            Upper = [Upper Harm_est(i).amp*20 Harm_est(i).phi+45];
        elseif Status == "fixed"
            Lower = [Lower Harm_est(i).amp*0.8 Harm_est(i).phi-10];
            StartPoint = [StartPoint Harm_est(i).amp Harm_est(i).phi];
            Upper = [Upper Harm_est(i).amp*1.2 Harm_est(i).phi+10];
        else
            error("unreachable")
        end
    end
end

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.TolX = 1e-12; % FIXME: default
opts.TolFun = 1e-12; % default
opts.Display = 'off';

opts.Lower = Lower;
opts.StartPoint = StartPoint;
opts.Upper = Upper;

% FIXME: debug section
% NOTE: used in DEL_plot_fit_ST.m
DEBUG.StartPoint = StartPoint;
DEBUG.coeffnames = coeffnames(ft);

% disp('--- Main fit call ---') % FIXME: debug
[fitresult, gof, output] = fit(Time', Signal', ft, opts);
% disp('--- Main fit call end ---') % FIXME: debug

Residuals = output.residuals';

Error_mult = 3; % NOTE: ± N*std


D = Freq_dev_const;
D_err = 0;


if ~isempty(Harm_est)
    harm_out = struct('n', [], 'amp', [], 'phi', []);
    harm_err = struct('n', [], 'amp', [], 'phi', []);
    for i = 1:numel(Harm_est)
        hn = Harm_est(i).n;
        harm_out(i).n = hn;
        harm_out(i).amp = get_value(fitresult, [HPref num2str(hn) 'a']);
        harm_out(i).phi = get_value(fitresult, [HPref num2str(hn) 'p']);
        harm_out(i).status = Harm_est(i).status;
        harm_err(i).n = hn;
        harm_err(i).amp = get_error(fitresult, [HPref num2str(hn) 'a'])*Error_mult;
        harm_err(i).phi = get_error(fitresult, [HPref num2str(hn) 'p'])*Error_mult;
        harm_err(i).status = Harm_est(i).status;
    end
else
    harm_out = [];
    harm_err = [];
end

Result = fit_core.Result_type;
Result.amp_poly = [];
Result.phi_poly = [];
Result.bg_poly = [];
Result.amp_poly_err = [];
Result.phi_poly_err = [];
Result.bg_poly_err = [];
Result.f_dev_flag = false;
Result.f_dev_ppm = D;
Result.f_dev_ppm_err = D_err;
Result.fit_function = "any_harm_fit";
Result.freq = Freq;
Result.harm = harm_out;
Result.harm_err = harm_err;
Result.estimations = fit_core.Estimation.empty();

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




