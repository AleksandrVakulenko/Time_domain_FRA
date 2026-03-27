
% NOTE: 'DEBUG' is from fit_core::any_sin_fit()

% FIXME: use amp, phi, bg types for start point parsing

plot(DEBUG.X_arr, DEBUG.StartPoint([1, 2, 3]), 'xk', 'MarkerSize', 15)

plot(DEBUG.X_arr([1 3]), DEBUG.StartPoint([4, 5]), 'xk', 'MarkerSize', 15)

plot(DEBUG.X_arr, DEBUG.StartPoint([6, 7, 8]), 'xk', 'MarkerSize', 15)



