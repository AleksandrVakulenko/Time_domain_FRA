


function Zmodel = LCR_res_to_Zmodel(Result_arr_Aster, Results_arr_PRE)
[Freq, Res] = unite_datasets(Result_arr_Aster, Results_arr_PRE);
Zmodel = do_res_fit(Freq, Res);
end


function [Freq_out, Res_out] = unite_datasets(Result_arr_Aster, Results_arr_PRE)

N_result = numel(Result_arr_Aster);
N_pre = numel(Results_arr_PRE);

% Res_pre = [Results_arr_PRE.res_abs];
% Freq_pre = [Results_arr_PRE.freq];

% Res = [Result_arr_Aster.res_abs];
% Freq = [Result_arr_Aster.freq];

if N_result == 0 && N_pre == 0
    Freq_out = [1 100];
    Res_out = [1e6 1e6]; % FIXME: magic constant

elseif N_result == 0 && N_pre == 1
    Res_pre = [Results_arr_PRE.res_abs];
    Freq_out = [1 100];
    Res_out = [Res_pre(1) Res_pre(1)];

elseif N_result == 0 && N_pre >= 2
    Res_pre = [Results_arr_PRE.res_abs];
    Freq_pre = [Results_arr_PRE.freq];
    Freq_out = Freq_pre;
    Res_out = Res_pre;

elseif N_result == 1 && N_pre == 0
    Res = [Result_arr_Aster.res_abs];
    Freq_out = [1 100];
    Res_out = [Res(1) Res(1)];

elseif N_result == 1 && N_pre > 0
    Res_pre = [Results_arr_PRE.res_abs];
    Freq_pre = [Results_arr_PRE.freq];
    Res = [Result_arr_Aster.res_abs];
    Freq = [Result_arr_Aster.freq];
    Freq_out = [Freq(1) Freq_pre];
    Res_out = [Res(1) Res_pre];

elseif N_result >= 2
    Res = [Result_arr_Aster.res_abs];
    Freq = [Result_arr_Aster.freq];
    Freq_out = Freq;
    Res_out = Res;
else
    N_result
    N_pre
    error('unreachable code')
end

end



function Zmodel = do_res_fit(Freq, Res)

Freq_log = log10(Freq);
Res_log = log10(Res);

% plot(Freq_log, Res_log, '.')


[xData, yData] = prepareCurveData( Freq_log, Res_log );
ft = fittype( 'poly1' );
fitresult = fit( xData, yData, ft );

Zmodel = @(f) 10.^feval(fitresult, log10(f));

end