
function plot_test_signals(Synth_time, Synth_signal_1, Synth_signal_2)

figure('position', [502 246 687 725])
subplot(2, 1, 1)
plot(Synth_time, Synth_signal_1)
grid on
grid minor
ylabel('signal, V')
xlabel('t, s')
title('Ch 1')

subplot(2, 1, 2)
plot(Synth_time, Synth_signal_2)
grid on
grid minor
ylabel('signal, V')
xlabel('t, s')
title('Ch 2')

end