

T_arr = Ch_data_2.time;
V2_arr = Ch_data_2.voltage;

[range, Outliers_volume, Limits, Residuals] = ...
    fit_core.find_outliers(Ch_data_2, Result_2);

disp(['Outliers volume = ' num2str(Outliers_volume*100, '%0.2f') ' %'])

figure
hold on
plot(T_arr(~range), V2_arr(~range), '.b')
plot(T_arr(range), V2_arr(range), '.r')




%%

figure
histogram(Residuals, 200)
xline(Limits.top)
xline(Limits.bot)


%%













