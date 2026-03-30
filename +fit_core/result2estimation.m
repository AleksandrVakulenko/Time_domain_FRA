

function Estimations_old = result2estimation(Result)
arguments
    Result fit_core.Result_type;
end

% -----------------------------------------
Estimations_old = Result.estimations;
% -----------------------------------------

Time = Result.amp_poly.x;
Period = 1/Result.freq;

% disp(['Time nyan = ' num2str(Time)])

Estimation_1 = fit_core.Estimation;

Estimation_1.amp = Result.amp_poly.p3;
Estimation_1.phi = Result.phi_poly.p3;
Estimation_1.bg = Result.bg_poly.p3;
Estimation_1.f_dev = Result.f_dev_ppm;

Estimation_1.t_min = Time(1);
Estimation_1.t_max = Time(1);

Estimation_1.Period_counter = (Time(3) - Time(1))/Period;

Estimation_1.status = "fixed";
Estimation_1.legacy_status = "";
Estimation_1.source = "fit_res";

Estimation_2 = Estimation_1;
Estimation_2.t_min = Time(2);
Estimation_2.t_max = Time(2);

Estimation_3 = Estimation_1;
Estimation_3.t_min = Time(3);
Estimation_3.t_max = Time(3);
% -----------------------------------------
Estimations_old = [Estimations_old Estimation_1 Estimation_2 Estimation_3];
% -----------------------------------------
end




