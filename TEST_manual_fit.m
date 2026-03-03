
clc

freq = 0.01;
Freq_dev = 0;
Duration = 1000;
Profile = 'weak';
% Traits = ["nobg", "zerophi"];
Traits = ["", "nonoise"];
Seed = 'SGQGQQ';
% Fs = 10e3;
Fs = 100e3/Duration;

[Synth_time, Synth_signal, Props] = gen_synth_sig(freq, Freq_dev, Duration, ...
    Profile, Traits, Seed, Fs);

disp(['Seed: ' char(Props.seed)]);

plot(Synth_time, Synth_signal)


%%

A1 =  -0.0001833;
A2 =      0.9732;
C1 =    0.001224;
C2 =     -0.5462;
P1 =     0.01701;
P2 =      -0.216;

clc

% disp(mean(Props.amp))
% disp([0.1494, 0.1497])
% 
% disp(mean(Props.phi))
% disp([-129, -128.8])
% 
% disp(mean(Props.bg))
% disp([-0.0004311, -0.0002582])


figure
hold on
plot(Synth_time, Props.amp, '-b')
plot(Synth_time, A1*Synth_time + A2, '-r')
title('Amp')

figure
hold on
plot(Synth_time, Props.phi, '-b')
plot(Synth_time, P1*Synth_time + P2, '-r')
title('Phi')

figure
hold on
plot(Synth_time, Props.bg, '-b')
plot(Synth_time, C1*Synth_time + C2, '-r')
title('BG')

%%

x = 0:0.1:1000;

Phase1 = 2*pi*(0.01+(-99)/1e6)*x + (P1*x+P2)/180*pi;

plot(x, Phase1)


%%

clc

PP1 = 2*pi*(0.01+(-100)/1e6)*1000;
PP2 = 2*pi*(0.01+(-150)/1e6)*1000;

PP1
PP2

clearvars PP1 PP2























%%

[Preview_time, Preview_signal] = gen_preview(Synth_time, Synth_signal);
hold on
% plot(Synth_time, Synth_signal)
plot(Preview_time, Preview_signal)




function [Preview_time, Preview_signal] = gen_preview(Synth_time, Synth_signal)

N = numel(Synth_time);
if N < 100e3
    Preview_time = Synth_time;
    Preview_signal = Synth_signal;
else
    Preview_time = linspace(Synth_time(1), Synth_time(end), 100e3);
    Preview_signal = interp1(Synth_time, Synth_signal, Preview_time);
end

end
