
function [Out_values, base_values] = poly3_gen(Time, Init_value, V_rdiv_pmin, V_adiv_pmin)

Duration = Time(end) - Time(1);

Value_rel_dev = V_rdiv_pmin^(Duration/60);
Value_abs_dev = V_adiv_pmin*Duration/60;

if Value_rel_dev > 3
    Value_rel_dev = 3;
end

if Value_rel_dev < 0.1
    Value_rel_dev = 0.1;
end

Value_start = Init_value;
Value_finish = Init_value*Value_rel_dev + Value_abs_dev;

% Init_value
% Init_value*Value_rel_dev
% Value_abs_dev

Value = [Value_start Value_finish];
Value(3) = Value(2);
Value(2) = test_gen.rand_range(Value(1), Value(3));


fitobj = fit([0 0.5 1]', Value', 'poly2');

Out_values = feval(fitobj, Time/Duration);

% NOTE: debug section
base_values = Value;
end



