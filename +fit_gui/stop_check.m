

function stop = stop_check(button)
    if ~isempty(button) && isvalid(button)
        stop = button.UserData.stop;
    else
        klog.warning('Stop button is missing', 'debug_full')
        stop = false;
    end
end

