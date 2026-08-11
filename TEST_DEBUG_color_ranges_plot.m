

Range_N_arr = [Result_arr_Aster.range_n];
Freq_arr_plot_Aster = [Result_arr_Aster.freq];
Res_Aster = [Result_arr_Aster.res_abs];
Res_err_Aster = [Result_arr_Aster.res_abs_err];
Phi_Aster = [Result_arr_Aster.phi];
Phi_err_Aster = [Result_arr_Aster.phi_err];

%%
Un_ranges = unique(Range_N_arr);

inds = Range_N_arr == 3;
% Res_basic_value = mean(Res_Aster(ind));
Cap_basic_value = 1./(2*pi*Res_Aster(inds).*Freq_arr_plot_Aster(inds));
Cap_basic_value = mean(Cap_basic_value);
Phi_basic_value = mean(Phi_Aster(inds));

for i = 1:numel(Un_ranges)
    Un_ranges(i)
    inds = Un_ranges(i) == Range_N_arr;
    Freq = Freq_arr_plot_Aster(inds);
    Phi = Phi_Aster(inds);
    Phi = mean(medfilt1(Phi, 3));
    Res = Res_Aster(inds);
    
    Cap = 1./(2*pi*Res.*Freq);
    Cap = medfilt1(Cap, 3);
    Cap = mean(Cap);
    if Un_ranges(i) == 3
        Scale_Res(i) = 1;
        Scale_Phi(i) = 0;
    else
        Scale_Res(i) = Cap/Cap_basic_value;
        Scale_Phi(i) = Phi_basic_value - Phi;
    end
end

%%

% figure('position', [468 218 686 783])

subplot(2, 1, 1)
hold on
for i = 1:numel(Un_ranges)
    Un_ranges(i)
    inds = Un_ranges(i) == Range_N_arr;
    errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')
    % errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
%     plot(Freq_arr_plot_Aster(inds), 1./(2*pi*Res_Aster(inds).*Freq_arr_plot_Aster(inds))*1e12, '.')
%     plot(Freq_arr_plot_Aster(inds), 1./(2*pi*Res_Aster(inds)*Scale_Res(i).*Freq_arr_plot_Aster(inds))*1e12, '.')
end
ylabel('|R|, Ohm')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
grid on
grid minor
box on

subplot(2, 1, 2)
hold on
for i = 1:numel(Un_ranges)
    inds = Un_ranges(i) == Range_N_arr;
%     errorbar(Freq_arr_plot_Aster(inds), Phi_Aster(inds)-Scale_Phi(i), Phi_err_Aster(inds), '.')
    errorbar(Freq_arr_plot_Aster(inds), Phi_Aster(inds), Phi_err_Aster(inds), '.')

end
ylabel('Phi, deg')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
grid on
grid minor
box on