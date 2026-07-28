

function stop = stop_check(button)
    if ~isempty(button)
        stop = button.UserData.stop;
    else
        stop = false;
    end
end

