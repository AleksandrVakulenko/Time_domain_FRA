


function Time_profile = Aster_max_time_profile(Time_profile, Range)

if Range == 5
    if Time_profile == "most_accurate"
        Time_profile = "fine";
    end
elseif Range == 6
    % FIXME: do we need fine on range 6?
%     if Time_profile == "fine" || Time_profile == "most_accurate"
%         Time_profile = "common";
%     end
    if Time_profile == "most_accurate"
        Time_profile = "fine";
    end
end

end







