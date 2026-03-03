function [A, P, C, D, fitresult, gof] = ...
    simple_sin_fit_f(Time, Signal, Freq)

if Time(1) ~= 0
    Time = Time - Time(1);
end

Eq = ['A*sin(2*pi*(' num2str(Freq) '*(1+D/1e6))*x+P/180*pi) + C'];


ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % default
opts.TolFun = 1e-6; % default

% FIXME: limits
%                     A     C   D[ppm]   P
opts.Lower      =  [   0   -5   -400   -180  ];
opts.StartPoint =  [   1    0   -150      0  ];
opts.Upper      =  [  10   +5   +400   +180  ];
% FIXME: check limits on D
% FIXME: use D only on long data


[fitresult, gof] = fit(Time, Signal, ft, opts);

A = fitresult.A;
C = fitresult.C;
D = fitresult.D;
P = fitresult.P;

end