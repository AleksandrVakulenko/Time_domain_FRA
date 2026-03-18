

Fern.load('aDevice')


%%

% FIXME: [in Aster_dev:] read_data forces dev to measure single point

clc
Aster = Aster_dev(3);


Aster.set_connection_mode("I2V");
Aster.set_sensitivity(1/1e3);
Aster.initiate();
pause(0.2);

% Aster.CMD_data_stream(1);

adev_utils.Wait(1, 'Wait for data gathering ...');


pause(0.05);


[Time_arr, V1_arr, V2_arr] = Aster.get_CV();
% Aster.CMD_data_stream(0);

Aster.terminate();
delete(Aster);

% V1_arr = V1_arr - mean(V1_arr);
Time_arr = Time_arr - Time_arr(1);

%%

figure('position', [303 235 768 797])

subplot(2, 1, 1)
hold on
plot(Time_arr, V1_arr, '.-b')


subplot(2, 1, 2)
hold on
plot(Time_arr, V2_arr, '.-b')



