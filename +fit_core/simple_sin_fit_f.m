


function Result = ... % simple_sin_fit_f
    simple_sin_fit_f(Time, Signal, Freq, Estimations)
    
    Start_time = Time(1);
    End_time = Time(end);
    Mid_time = (End_time + Start_time)/2;
    
    if numel(Estimations) ~= 1
        Estimations = combining_estimations(Estimations);
    end
    % FIXME: ??? wtf
    Start_Amp = Estimations(1).amp;
    Start_Phi = Estimations(1).phi;
    Start_BG = Estimations(1).bg;
    
    Eq = [ 'A*sin(2*pi*' num2str(Freq) '*x+P/180*pi) + C + Z*x' ];
    
    ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.TolX = 1e-6; % FIXME: default
    opts.TolFun = 1e-6; % default
    
    A = Start_Amp;
    P = Start_Phi;
    C = Start_BG;
    %                     A     C     P      Z
    opts.Lower      =  [   0   -5   -180   -inf ];
    opts.StartPoint =  [   A    C      P      0 ];
    opts.Upper      =  [  10   +5   +180   +inf ];
    
    [fitresult, gof] = fit(Time', Signal', ft, opts);
    
    % FIXME: do we need to check quality? (use gof somehow)
    
    A = fitresult.A;
    P = fitresult.P;
    C = fitresult.C;
    Z = fitresult.Z;

    C = C + Z*Mid_time;

    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    
    A_err = CI(1);
    C_err = CI(2);
    P_err = CI(3);

    Result = fit_core.Estimation;
    Result.amp = A;
    Result.phi = P;
    Result.bg = C;
    Result.a_err = A_err;
    Result.p_err = P_err;
    Result.c_err = C_err;
    Result.fitres = fitresult;
    Result.t_min = Start_time;
    Result.t_max = End_time;
    Result.z = Z;
    Result.status = "ok";
    Result.source = "simplefit";

end



function Result = combining_estimations(Estimations)
    N = numel(Estimations);
    % FIXME: UNDONE
    Result.amp = mean([Estimations.amp]);
    Result.bg = mean([Estimations.bg]);
    Result.phi = mean([Estimations.phi]);
    
end
