
% NOTE: test for err_str function (from Fern::common)

clc

Value = 11.2;
Err = 0.000245;

[Str, Value, Err] = err_str(Value, Err)

%%

clc

SI_unit = 'F';
Value = 0.11279080;
Err = 0.0245;

% Value = 1127.9080;
% Err = 24;

[Str, Value, Err] = err_str2(Value, Err, SI_unit)



