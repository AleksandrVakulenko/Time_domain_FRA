function inds = FRA_results_check_valid(Result_arr_Aster)
% FIXME: undone function. remake it after adding FRA result type
res_abs = [Result_arr_Aster.res_abs];
inds = ~isempty(res_abs);

end