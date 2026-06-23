
function y = calibration_model_1(x, x0, p, C, A)

y = C*ones(size(x));

range = x >= x0;
x_part = x(range);

y_add = sign(A)*(abs(A)*(x_part-x0)).^p;

y(range) = y(range) + y_add;

end











