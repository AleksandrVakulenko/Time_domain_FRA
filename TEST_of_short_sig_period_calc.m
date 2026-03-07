



Phi_arr = -190:1:190;
Phi_calc = nan(size(Phi_arr));
Sec_num_arr = zeros(size(Phi_arr));



% NOTE: do not use this function if Fraction of Period
% is less than 0.35 OR more than 0.7

for k = 1:numel(Phi_arr)


% clc

Freq = 1;
Period = 1/Freq;
Phi = Phi_arr(k);
% Phi = -100;
Fraction = 0.5;

x = 0:Period/1000:Period*Fraction;
% y = sin(2*pi*x + Phi/180*pi) + 1 + x;
y = sin(2*pi*x + Phi/180*pi) + 1;
Noise = 2*(rand(size(x))-0.5)*0.07;
y = y + Noise;

% Phase = short_sig_phase_calc(x, y, Period);
[Phase, Status] = estimate_phi_part_sin(x, y, Period);

disp(' ')
disp(['Phi: ' num2str(Phi)])
disp(['Phase: ' num2str(Phase)])
disp(['error: ' num2str(Phi-Phase)])
% disp(['Sec: ' num2str(Sec_num)])


if ~isempty(Phase)
    Phi_calc(k) = Phase;
end
% Sec_num_arr(k) = Sec_num;


x_m = linspace(x(1), x(end), 100);
y_m = feval(fitresult, x_m);


% pause(0.25)
end



%%

figure('position', [505 188 594 694])
subplot(2, 1, 1)
hold on
plot(Phi_arr, Phi_calc)
xlabel('Phi (input), deg')
ylabel('Phi (calculated), deg')
% plot(Phi_arr, Sec_num_arr*10, '-x')
yline([-180 180])

% plot(Phi_arr, Out_1_arr)
% plot(Phi_arr, Out_2_arr)
% yline([50 40  20 10])


Diff_error = Phi_calc-Phi_arr;
Diff_error(Diff_error > 200) = Diff_error(Diff_error > 200) - 360;
Diff_error(Diff_error < -200) = Diff_error(Diff_error < -200) + 360;
subplot(2, 1, 2)
hold on
plot(Phi_arr, Diff_error)
xlabel('Phi (input), deg')
ylabel('diff error, deg')














%%


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


