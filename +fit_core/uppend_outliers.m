
% FIXME: delete this

function Outliers_range_1 = uppend_outliers(T_arr, Outliers_range_1)

N_data = numel(T_arr);
N_out = numel(Outliers_range_1);

if N_out < N_data
    N_diff = N_data - N_out;
    Outliers_range_1 = [Outliers_range_1 false(1, N_diff)];
end

end