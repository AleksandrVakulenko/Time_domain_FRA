
clc

Gen_freq = 100;
Period = 1/Gen_freq;

Sampling_freq = 5000*Gen_freq;

if Sampling_freq > 20000
    Sampling_freq = 20000;
end

Periods_counter = 20;


Full_time = Periods_counter*Period;


Num_of_samples = Full_time*Sampling_freq;


disp(['f = ' num2str(Gen_freq) ' Hz'])
disp(['PC = ' num2str(Periods_counter)])
disp(['T = ' num2str(Full_time) ' s'])
disp(['N = ' num2str(Num_of_samples)])



