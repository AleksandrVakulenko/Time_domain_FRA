
function y = model_2(x, x0, p, C, A)

y = C*ones(size(x));

range = x >= x0;
x_part = x(range);

y_add = A*exp((x_part-x0).^p)-A;



y(range) = y(range) + y_add;

end