
% FIXME: (2) we have other function like this
% - Aster_ARA_helper.is_LCR_result_valid...
% - something to check valid harmonics

function inds = FRA_results_check_valid(Result_arr_Aster)
arguments
    Result_arr_Aster Aster_FRA.LCR_result_type
end


if isempty(Result_arr_Aster)
    inds = false;
else
    Res = [Result_arr_Aster.res_abs];
    Res_err = [Result_arr_Aster.res_abs_err];
    Phi = [Result_arr_Aster.phi];
    Phi_err = [Result_arr_Aster.phi_err];


    inds = ~isempty(Res) & ~isempty(Res_err) & ~isempty(Phi) & ...
        ~isempty(Phi_err) & ~isnan(Res) & ~isnan(Res_err) & ...
        ~isnan(Phi) & ~isnan(Phi_err);
end

end