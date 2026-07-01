function Outliers_force_range = get_force_outliers(Time, Freq, ...
    Cut_FOP_filter, Cut_FOP_first)

if Cut_FOP_filter == 0 && Cut_FOP_first == 0
    Outliers_force_range = [];
else
    Outliers_force_range = false(size(Time));
    Time2cut_both = Cut_FOP_filter*1/Freq;
    Time2cut_left = Cut_FOP_first*1/Freq;
    Range1 = Time < Time(1)+Time2cut_both | Time > Time(end) - Time2cut_both;
    Range2 = Time < Time(1) + Time2cut_left;
    Outliers_force_range(Range1 | Range2) = true;
end

end