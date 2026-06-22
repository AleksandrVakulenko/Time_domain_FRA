
clc

Freq_arr =[];
Res_arr = [];
Phi_arr = [];

Harm_2_freq = [];
Harm_2_res_arr = [];
Harm_2_phi_arr = [];

Harm_3_freq = [];
Harm_3_res_arr = [];
Harm_3_phi_arr = [];

for i = 1:numel(Extra_data_arr)

    Extra_data = Extra_data_arr(i);
    Result_1 = Extra_data.result_1;
    Result_2 = Extra_data.result_2;
    Freq = Result_1.freq;
    Range_N = Extra_data.used_ranges;

    if numel(Range_N) > 1
        error(num2str(Range_N))
    end

    Result = Aster_FRA_result(Result_1, Result_2, Freq, Range_N);

    Res = Result.res_abs;
    Phi = Result.phi;

    Res_arr = [Res_arr Res];
    Phi_arr = [Phi_arr Phi];

    Harm_arr = Result.harm2;

    Freq_arr = [Freq_arr Freq];
    for j = 1:numel(Harm_arr)
        Harm = Harm_arr(j);
        if Harm.n == 2
            Harm_2_freq = [Harm_2_freq Freq];
            Harm_2_res_arr = [Harm_2_res_arr Harm.res/Res];
            Harm_2_phi_arr = [Harm_2_phi_arr Harm.phi];
        elseif Harm.n == 3
            if ~isempty(Harm.res)
                Harm_3_freq = [Harm_3_freq Freq];
                Harm_3_res_arr = [Harm_3_res_arr Harm.res/Res];
                Harm_3_phi_arr = [Harm_3_phi_arr Harm.phi];
            else
                disp('!!!!!!!!!!!!!!!!!!!!!!!')
                pause(0.5)
            end
        end

    end

end

disp('finish')

%% Fundamental

figure

subplot(2, 1, 1)
plot(Freq_arr, Res_arr)
    set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

subplot(2, 1, 2)
plot(Freq_arr, Phi_arr)
set(gca, 'xscale', 'log')


%% Harm 2 3
figure
subplot(2, 1, 1)
hold on
plot(Harm_2_freq, 20*log10(1./Harm_2_res_arr), '-b', 'DisplayName', 'Harm 2')
plot(Harm_3_freq, 20*log10(1./Harm_3_res_arr), '-r', 'DisplayName', 'Harm 3')
ylim([-100 0])
ylabel('|1/R|, dBc')
set(gca, 'xscale', 'log')


subplot(2, 1, 2)
hold on
plot(Harm_2_freq, Harm_2_phi_arr, '-b')
plot(Harm_3_freq, Harm_3_phi_arr, '-r')
% ylim([-100 0])
set(gca, 'xscale', 'log')


















