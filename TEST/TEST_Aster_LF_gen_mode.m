
% NOTE: this file is only to test new LF gen mode in Astra (04.08.2026)

clc

load('Results_cal\028_LF_gen.mat')
Ch_data_1_LF = Extra_data_arr(1).ch_data_1;
Ch_data_2_LF = Extra_data_arr(1).ch_data_2;



load('Results_cal\026.mat')
Ch_data_1_OLD = Extra_data_arr(1).ch_data_1;
Ch_data_2_OLD = Extra_data_arr(1).ch_data_2;

disp('OK')

%%


time1 = Ch_data_2_LF.time;
v1_LF = Ch_data_1_LF.voltage;
v2_LF = Ch_data_2_LF.voltage;

time2 = Ch_data_2_OLD.time;
v1_OLD = Ch_data_1_OLD.voltage;
v2_OLD = Ch_data_2_OLD.voltage;
time2(end-10:end) = [];
v1_OLD(end-10:end) = [];
v2_OLD(end-10:end) = [];

figure
hold on
plot(time1, v1_LF, '.b')
plot(time2, v1_OLD, '.r')
grid on

figure
hold on
plot(time1, v2_LF, '-b')
plot(time2, v2_OLD, '-r')
grid on

%%
clc

N = -24;
v1_LF_n = circshift(v1_LF, N);

v1_OLD_n = v1_OLD;
time1_n = time1;
time1_n(1:abs(N)) = [];
time1_n(end-abs(N):end) = [];
v1_OLD_n(1:abs(N)) = [];
v1_OLD_n(end-abs(N):end) = [];
v1_LF_n(1:abs(N)) = [];
v1_LF_n(end-abs(N):end) = [];

figure
hold on
plot(time1_n, v1_LF_n - v1_OLD_n, '-b')
grid on







