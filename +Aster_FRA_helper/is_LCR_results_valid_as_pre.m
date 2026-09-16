

function flag = is_LCR_results_valid_as_pre(LCR_res_arr)
arguments
    LCR_res_arr Aster_FRA.LCR_result_type
end

Freq_arr = [LCR_res_arr.freq];
Res = [LCR_res_arr.res_abs];
Res_err = [LCR_res_arr.res_abs_err];
Phi = [LCR_res_arr.phi];
Phi_err = [LCR_res_arr.phi_err];

Res_rel_err = Res_err./Res;

Freq_limit = 200;
Res_rel_err_limit = 10; % [%]
Phi_abs_err_limit = 10; % [deg]

range = (Freq_arr < Freq_limit) & ~isnan(Res) & ~isnan(Res_err) & ...
    ~isnan(Phi) & ~isnan(Phi_err) & ...
    (Res_rel_err < Res_rel_err_limit/100) & ...
    (Phi_err < Phi_abs_err_limit);

N = numel(find(range));

flag = (N >= 2);


end