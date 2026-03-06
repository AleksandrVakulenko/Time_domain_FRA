
function [A, P, C, D, fitresult, gof] = sin_fit_f(Time, Signal, Freq)
    
    Start_time = Time(1);
    End_time = Time(end);
    
    % FIXME: do npt do it here (phase mismatch)
%     if Time(1) ~= 0
%         Time = Time - Time(1);
%     end
    
    Signal2 = medfilt1(Signal);
    Min = min(Signal2);
    Max = max(Signal2);
    Mean = mean(Signal2);
    Span = abs(Max-Min);

    Start_Amp = Span;
    Start_Phi = 0;
    Start_BG = Mean;
    
    Eq = [ 'A*sin(2*pi*' num2str(Freq) '*x+P/180*pi) + C' ];
    
    ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.TolX = 1e-6; % FIXME: default
    opts.TolFun = 1e-6; % default
    
    A = Start_Amp;
    P = Start_Phi;
    C = Start_BG;
    D = 0;
    %                     A     C     P
    opts.Lower      =  [   0   -5   -180  ];
    opts.StartPoint =  [   A    C      P  ];
    opts.Upper      =  [  10   +5   +180  ];
    
    [fitresult, gof] = fit(Time', Signal', ft, opts);
    
    % FIXME: check quality (use gof somehow)
    
    A = fitresult.A;
    P = fitresult.P;
    C = fitresult.C;
    
    % coeffnames(fitresult)
    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    
    A_err = CI(1);
    C_err = CI(2);
    P_err = CI(3);
    
    Result = struct(...
        'amp', A, 'phi', P, 'bg', C, 'f_dev', NaN, ...
        'a_err', A_err, 'p_err', P_err, 'c_err', C_err, 'fd_err', NaN, ...
        'fitres', fitresult, ...
        't_min', Start_time, 't_max', End_time);

end