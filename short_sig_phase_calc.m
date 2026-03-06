
% NOTE: do not use this function if Fraction of Period
% is less than 0.35 OR more than 0.7

function Phase = short_sig_phase_calc(Time, Signal, Period)
Time_len = Time(end) - Time(1);
Fraction = Time_len/Period;

if Fraction < 0.3 || Fraction > 0.75
    % FIXME: or just return []?
    error('Wrong fraction of period')
end

x = Time;
y = Signal;

if numel(x) > 65 % FIXME: magic numbers
    N = 65;
elseif numel(x) > 25
    N = 25;
else
    error('return empty')
end

ind = round(linspace(1, numel(x), N));
xp = x(ind);
yp = y(ind);


[fitresult, ~] = fit(xp', yp', 'poly3');
p1 = fitresult.p1;
p2 = fitresult.p2;
p3 = fitresult.p3;
p4 = fitresult.p4;
% y   =     p1*x^3 +   p2*x^2 + p3*x + p4
% y'  =   3*p1*x^2 + 2*p2*x + p3;
% y'' = 2*3*p1*x + 2*p2;

Zeros = calc_zeros(3*p1, 2*p2, p3);
range_inside = (Zeros > x(1)) & (Zeros < x(end));
Zeros_inside = Zeros(range_inside);
range_close = (Zeros > x(1) - 0.6*Period) & (Zeros < x(end) + 0.6*Period);
Zeros_close = Zeros(range_close);

% disp(['Zeros: ' num2str(Zeros)])
% disp(['Zeros inside: ' num2str(Zeros_inside)])
% disp(['Zeros close: ' num2str(Zeros_close)])


switch numel(Zeros_close)
case 0
    Sec_num = 1;
    Phase = [];
    
case 1
    switch numel(Zeros_inside)
    case 0
        Sec_num = 2;
        convex = convex_calc(p1, p2, Zeros_close);
        Phase = Zeros_close/Period*2;
        Phase = -90/0.5*Phase + 90;
        if convex < 0
            Phase = Phase + 180;
        end
    case 1
        Sec_num = 3;
        convex = convex_calc(p1, p2, Zeros_inside);
        Phase = Zeros_inside/Period*2;
        Phase = -90/0.5*Phase + 90;
        if convex < 0
            Phase = Phase + 180;
        end
    case 2
        Sec_num = 4;
        error('unreachable')
    end

case 2
    switch numel(Zeros_inside)
    case 0
        Sec_num = 5;
        convex = convex_calc(p1, p2, Zeros_close);
        Phase = Zeros_close/Period*2;
        Phase = -90/0.5*Phase + 90;
        for i = 1:numel(Phase)
            if convex(i) < 0
                Phase(i) = Phase(i) + 180;
            end
        end
        Phase = phase_correction(Phase);
        Phase = mean(Phase);
    case 1
        Sec_num = 6;
        convex = convex_calc(p1, p2, Zeros_inside);
        Phase = Zeros_inside/Period*2;
        Phase = -90/0.5*Phase + 90;
        if convex < 0
            Phase = Phase + 180;
        end
    case 2
        Sec_num = 7;
        convex = convex_calc(p1, p2, Zeros_inside);
        Phase = Zeros_inside/Period*2;
        Phase = -90/0.5*Phase + 90;
        for i = 1:numel(Phase)
            if convex(i) < 0
                Phase(i) = Phase(i) + 180;
            end
        end
        Phase = phase_correction(Phase);
        Phase = mean(Phase);
    end

end

% FIXME: one more time
Phase = phase_correction(Phase);

end





function Phase = phase_correction(Phase)
    Phase(Phase > 180) = Phase(Phase > 180) - 360;
    Phase(Phase < -180) = Phase(Phase < -180) + 360;
end

function Zeros = calc_zeros(a, b, c)
    D = b^2 - 4*a*c;
    if D > 0
        Zeros(1) = (-b + sqrt(D))/(2*a);
        Zeros(2) = (-b - sqrt(D))/(2*a);
    elseif D == 0
        Zeros = -b/(2*a);
    else
        Zeros = [];
    end
end


function convex = convex_calc(p1, p2, x)
    second_der = 2*3*p1*x + 2*p2;
    convex = zeros(size(x));
    convex(second_der>0) = -1;
    convex(second_der<0) = 1;
end
