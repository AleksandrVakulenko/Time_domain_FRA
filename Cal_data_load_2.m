
clc

Folder = 'Results_cal';

Files = find_files(Folder);

Result_arr_Aster = [];
Result_ch1_arr = [];
Result_ch2_arr = [];
Range_used = [];

for i = 1:numel(Files)
    disp([num2str(i) '/' num2str(numel(Files))])
    Data = load(Files(i).full_path, "Result_arr_Aster");
    Data_ext = load(Files(i).full_path, "Extra_data_arr");
    Data_ext = Data_ext.Extra_data_arr;

    try
        Data.Result_arr_Aster = rmfield(Data.Result_arr_Aster, ["res_abs_err_fit", "phi_err_fit"]);
        disp('nyan');
    catch
       
    end

    Result_arr_Aster = [Result_arr_Aster Data.Result_arr_Aster];
    Result_ch1_arr = [Result_ch1_arr Data_ext.result_1];
    Result_ch2_arr = [Result_ch2_arr Data_ext.result_2];
    Range_used = [Range_used Data_ext.aster_range];

end

clearvars ans i Data Files Folder

disp('FINISH')

%% Do uncalibrated data from Extra_data

Result_arr_Aster_nc = [];

for i = 1:numel(Result_ch1_arr)
    disp([num2str(i) '/' num2str(numel(Result_ch1_arr))])

    Result_1 = Result_ch1_arr(i);
    Result_2 = Result_ch2_arr(i);
    Freq = Result_1.freq;
    Aster_range = Range_used(i);

    Fit_Result = Aster_FRA.do_FRA_result(Result_1, Result_2, Freq, ...
        Aster_range, [], "use_correction", "none", "disp_flag", "off");

    Result_arr_Aster_nc = [Result_arr_Aster_nc Fit_Result];


end


%%
%%

try
    Result_arr_Aster_in = Result_arr_Aster_nc;
catch
    Result_arr_Aster_in = Result_arr_Aster;
end

Freq_arr_plot_Aster = [Result_arr_Aster_in.freq];
Res_Aster = [Result_arr_Aster_in.res_abs];
Res_err_Aster = [Result_arr_Aster_in.res_abs_err];
Phi_Aster = [Result_arr_Aster_in.phi];
Phi_err_Aster = [Result_arr_Aster_in.phi_err];
Range_Aster = [Result_arr_Aster_in.range_n];



% Sort
[Freq_arr_plot_Aster, inds] = sort(Freq_arr_plot_Aster);
Res_Aster = Res_Aster(inds);
Res_err_Aster = Res_err_Aster(inds);
Phi_Aster = Phi_Aster(inds);
Phi_err_Aster = Phi_err_Aster(inds);
Range_Aster = Range_Aster(inds);

disp('OK')
%%

% Get cap
Cap_Aster = 1./(2*pi*Freq_arr_plot_Aster.*Res_Aster);
% plot(Cap_Aster)

Range = Cap_Aster > 204e-12 | Cap_Aster < 170e-12;
% plot(Cap_Aster(~Range))

Freq_arr_plot_Aster(Range) = [];
Res_Aster(Range) = [];
Res_err_Aster(Range) = [];
Phi_Aster(Range) = [];
Phi_err_Aster(Range) = [];
Range_Aster(Range) = [];

disp('OK')
%%

Un_ranges = unique(Range_Aster);

Resistance = [];

for i = 1:numel(Un_ranges)
    RN = Un_ranges(i);
    inds = Range_Aster == RN;

    Data_range(i) = RN;
    Data_Freq{i} = Freq_arr_plot_Aster(inds);
    Data_Res{i} = Res_Aster(inds);
    Data_Res_err{i} = Res_err_Aster(inds);
    Data_Phi{i} = Phi_Aster(inds);
    Data_Phi_err{i} = Phi_err_Aster(inds);
    
end

clearvars -except Data_range Data_Freq Data_Res Data_Res_err Data_Phi Data_Phi_err

disp('OK')

%% Find true value by range N3


i = find(Data_range == 3);
Freq = Data_Freq{i};
Freq_log = log10(Freq);
Res = Data_Res{i};
Res_err = Data_Res_err{i};
Phi = Data_Phi{i};
Phi_err = Data_Phi_err{i};

RF = Res.*Freq;
Cap = 1./(2*pi*Freq.*Res);

Cap_mean = mean(Cap)
RF_mean = mean(RF);
Phi_mean = mean(Phi);

%% Plot all normalized

Ranges_color = ["b", "r", "g", "k"];

figure('position', [400 158 686 783])
subplot(2, 1, 1)
hold on

subplot(2, 1, 2)
hold on

Ranges_freq_low_lim = [1  1  2  0.1  5e-4  1e-6];

for i = 1:1
RN = Data_range(i);
Freq = Data_Freq{i};
Freq_log = log10(Freq);
Res = Data_Res{i};
Res_err = Data_Res_err{i};
Phi = Data_Phi{i};
Phi_err = Data_Phi_err{i};

inds = Freq < Ranges_freq_low_lim(RN);
Freq(inds) = [];
Freq_log(inds) = [];
Res(inds) = [];
Res_err(inds) = [];
Phi(inds) = [];
Phi_err(inds) = [];

RF = Res.*Freq;
RF_err = Res_err.*Freq;

% RF = RF/RF_mean;
% RF_err = RF_err/RF_mean;
% Phi = Phi - Phi_mean;

% if RN == 6
% v = calibration_2nd_model_calc(Calibration_2nd_model, Freq);
% % RF = RF./v;
% v2 = calibration_2nd_model_calc(Calibration_2nd_model_phi, Freq);
% % Phi = Phi-v2;
% end

% Phi = Phi + 90;
Cap = 1./(2*pi*Freq.*Res);
Cap_rel = 1./(2*pi*Freq.*Res)/195.9e-12;
% Cap_rel = 1./Res;
% PHI: 180/pi*atan(10.^x/f0) + (D*x.^3 + A*x.^2 + B*x + C).*soft_window(x, -6, log10(f0));
% AMP: 1/sqrt(1+(10^x/f0)^2) + (a*x^2 + B*x + C)*soft_window(x, log10(1e-6), log10(f0))
err_rel = RF_err./RF;
inds = err_rel < 0.005;

col = Ranges_color(i);

subplot(2, 1, 1)
plot(Freq, Cap, '.', 'Color', col);
% plot(Freq, Res, '.', 'Color', col);
% plot(Freq, RF, '.', 'Color', col);
% errorbar(Freq, RF, RF_err, '.', 'Color', col)
% errorbar(Freq(inds), RF(inds), RF_err(inds), '.', 'Color', col)
% plot(Freq, err_rel, '.')

subplot(2, 1, 2)
plot(Freq, Phi, '.', 'Color', col);
% errorbar(Freq, Phi, Phi_err, '.', 'Color', col)

end

% subplot(2, 1, 1)
% plot(Freq, v, '-b', 'LineWidth', 3);
% 
% subplot(2, 1, 2)
% plot(Freq, v2, '-b', 'LineWidth', 3);

subplot(2, 1, 1)
xlim([1e-5 1e3])
ylabel('|R|, Ohm')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
grid on
grid minor
box on

subplot(2, 1, 2)
xlim([1e-5 1e3])
ylabel('Phi, deg')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
grid on
grid minor
box on






















