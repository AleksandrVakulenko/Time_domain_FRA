

%% NOTE: test for do_power_line_filter

Time = Ch_data.time;
Signal = Ch_data.voltage;
Fs = Ch_data.fs;
Freq = Ch_data.freq;

Freq = 57;

Psig = 85/180*pi;
Pnoise = 23/180*pi;
Signal = 1*sin(2*pi*(Freq)*Time+Psig);
% Signal = 0*ones(size(Time));
Noise = 0.2*sin(2*pi*50*Time + Pnoise);
% Noise = ones(size(Time));

Signal = Signal + Noise;

[Signal_f, Cut_FOP] = fit_core.do_power_line_filter(Time, Signal, Fs, Freq, 50);

% Signal_f = filter(Hd, Signal);

Cut_FOP

% figure
% subplot(2, 1, 1)
% hold on
% plot(Time, Signal, '-b')
% 
% 
% subplot(2, 1, 2)
% hold on
% plot(Time, Signal_f, '-r')
% xline(Cut_FOP/Freq)
% xline(Time(end)-Cut_FOP/Freq)

figure
% subplot(2, 1, 1)
hold on
plot(Time, Signal, '-b')
plot(Time, Signal_f, '-r')
xline(Cut_FOP/Freq)
xline(Time(end)-Cut_FOP/Freq)
% 
% 
% % subplot(2, 1, 2)
% % hold on


x = [ 4    2    6     5    1.5];
y = [0.22  0.4  0.16  0.20  0.4];







%% NOTE: One more test for do_power_line_filter


i = 5;
Ch_data_1 = Extra_data_arr(i).ch_data_1;
Ch_data_2 = Extra_data_arr(i).ch_data_2;

Ch_num = 2;

if Ch_num == 1
    Time = Ch_data_1.time;
    Signal = Ch_data_1.voltage;
    Fs = Ch_data_1.fs;
else
    Time = Ch_data_2.time;
    Signal = Ch_data_2.voltage;
    Fs = Ch_data_2.fs;
end

Time_length = Time(end) - Time(1);
Freq_res = 1./Time_length;

% Signal = apply_nuttall(Signal, Fs);

Signal_f = do_power_line_filter(Signal, Fs);

figure
hold on
plot(Time, Signal, '-b')
plot(Time, Signal_f, '--r')
% ylim([-1.3 1.3])
box on
grid on

%%
clc

Time_length_FOP = 20;
Fs = 10000;
Freq = 5;
Time_length = 1/Freq * Time_length_FOP;

Freq_res = 1./Time_length;
Period = 1/Freq;
Time = 0:1/Fs:Time_length-1/Fs;

Period_counter = Time_length/Period;
if Period_counter > 10
    Cut_FOP_first = 0.15*Period_counter;
elseif Period_counter > 5
    Cut_FOP_first = 0.1*Period_counter;
else
    Cut_FOP_first = 0;
end

% Signal = 1*sin(2*pi*Freq*Time) + ...
%     0.1*sin(2*pi*Freq*2*Time+123) + ...
%     0.05*sin(2*pi*Freq*3*Time+3) + ...
%     0.2*sin(2*pi*50*Time) + normrnd(0, 0.1, size(Time));
Signal = 1*sin(2*pi*Freq*Time) + 0.2*sin(2*pi*50*Time);

[Signal_f, Cut_FOP_filter] = fit_core.do_power_line_filter(Time, Signal, Fs, Freq);

Outliers_force_range = get_force_outliers(Time, Freq, ...
    Cut_FOP_filter, Cut_FOP_first);


figure
subplot(2, 1, 1)
hold on
plot(Time, Signal, '-b')
plot(Time, Signal_f, '--r')
ylim([-1.3 1.3])
box on

grid on

subplot(2, 1, 2)
hold on
% plot(Time, Signal, '-b')
plot(Time(~Outliers_force_range), Signal_f(~Outliers_force_range), '-r', 'LineWidth', 1.5)
plot(Time(Outliers_force_range), Signal_f(Outliers_force_range), '--r')
ylim([-1.3 1.3])
box on
grid on











