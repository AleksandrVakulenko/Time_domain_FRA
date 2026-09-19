


function [Time_profile, is_changed] = max_time_profile(Time_profile, Range)

is_changed = false;

if Range == 5
    if Time_profile == "most_accurate"
        Time_profile = "fine";
        is_changed = true;
    end
elseif Range == 6
    % FIXME: (2) do we need fine on range 6?
%     if Time_profile == "fine" || Time_profile == "most_accurate"
%         Time_profile = "common";
%         is_changed = true;
%     end
    if Time_profile == "most_accurate"
        Time_profile = "fine";
        is_changed = true;
    end
end

end







