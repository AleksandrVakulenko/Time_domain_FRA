
clc

%---------------
Fs = 100;
Duration = 60;


%---------------

Synth_time = (0:1/Fs:Duration);



Profile = "const"; % "strong", "mid", "weak", "const"

[Amp_value, Phi_value, Bg_value] = sin_prog_gen(Synth_time, Profile);




hold on
cla
% plot(Synth_time, Amp_value, '-b')
% plot(Synth_time, Bg_value+Amp_value, '-b')
% plot(Synth_time, Bg_value-Amp_value, '-b')
% plot(Synth_time, Bg_value, '--b')
% ylim([-5 5])

plot(Synth_time, Phi_value, '-b')
% ylim([-200 200])

disp('Finish')




