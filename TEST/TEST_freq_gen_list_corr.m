
clc

F_min = 1;
F_max = 200;
F_num = 200;


Freq_arr = fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "off", "repeat", 1, 'correction', 'off')

figure
plot(Freq_arr, '.')
xlim([1 F_num])
yline(45)
yline(50)
yline(55)
yline(60)



