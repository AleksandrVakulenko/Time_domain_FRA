

function Time_prediction_m = time_prediction(Freq_arr, Time_profile)

Periods = 1./Freq_arr;
if Time_profile == "common"
    Periods = Periods*1.47;
elseif Time_profile == "fine"
    Periods = Periods*2.08;
elseif Time_profile == "most_accurate"
    Periods = Periods*2.0;
elseif Time_profile == "ultra_fast"
    Periods = Periods*1.16;
end
Periods(Periods < 5) = 5;
Time_prediction_m = sum(Periods)/60;


end