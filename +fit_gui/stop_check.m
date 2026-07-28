

function stop = stop_check(button)
    if ~isvalid(button)
        stop = button.UserData.stop;
    else
        stop = false;
    end
end

