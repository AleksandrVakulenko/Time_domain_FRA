

function stop = stop_check(button)
    if isvalid(button)
        stop = button.UserData.stop;
    else
        warning('Stop button is missing') % FIXME: debug disp
        stop = false;
    end
end

