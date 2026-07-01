
function Outliers_range_out = uppend_outliers(T_arr, Outliers_range, Outliers_range_force)

if ~isempty(Outliers_range)
    N_data = numel(T_arr);
    N_out = numel(Outliers_range);

    if N_out < N_data
        N_diff = N_data - N_out;
        Outliers_range = [Outliers_range false(1, N_diff)];
    end
end

Outliers_range_out = fit_core.unite_outliers(Outliers_range, Outliers_range_force);

end




