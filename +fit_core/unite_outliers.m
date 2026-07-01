function Outliers_range = unite_outliers(Outliers_range_1, Outliers_range_2)

if isempty(Outliers_range_1) && isempty(Outliers_range_2)
    Outliers_range = [];

elseif isempty(Outliers_range_1) && ~isempty(Outliers_range_2)
    Outliers_range = Outliers_range_2;

elseif ~isempty(Outliers_range_1) && isempty(Outliers_range_2)
    Outliers_range = Outliers_range_1;

else
    N1 = numel(Outliers_range_1);
    N2 = numel(Outliers_range_1);
    if N1 > N2
        N_diff = N1 - N2;
        Outliers_range_2 = [Outliers_range_2 false(1, N_diff)];
    elseif N1 < N2
        N_diff = N2 - N1;
        Outliers_range_1 = [Outliers_range_1 false(1, N_diff)]; 
    end
    Outliers_range = Outliers_range_1 | Outliers_range_2;

end

end