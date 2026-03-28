
% NOTE: 'DEBUG' is from fit_core::any_sin_fit()

% FIXME: use amp, phi, bg types for start point parsing

DEBUG = DEBUG_1;

% plot(DEBUG.X_arr, DEBUG.StartPoint([1, 2, 3]), 'xk', 'MarkerSize', 15)
% 
% plot(DEBUG.X_arr([1 3]), DEBUG.StartPoint([4, 5]), 'xk', 'MarkerSize', 15)
% 
% plot(DEBUG.X_arr, DEBUG.StartPoint([6, 7, 8]), 'xk', 'MarkerSize', 15)


subplot(2, 2, 1)
plot(DEBUG.X_arr(2), DEBUG.StartPoint(1), 'xk', 'MarkerSize', 25)

subplot(2, 2, 2)
plot(DEBUG.X_arr(2), DEBUG.StartPoint(3), 'xk', 'MarkerSize', 25)

subplot(2, 2, 3)
plot(DEBUG.X_arr(2), DEBUG.StartPoint(2), 'xk', 'MarkerSize', 25)