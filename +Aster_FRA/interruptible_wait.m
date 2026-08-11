
function interruptible_wait(time_s, msg, Resources)
arguments
    time_s (1,1) {mustBeNumeric(time_s), mustBeGreaterThanOrEqual(time_s, 0)}
    msg (1,1) string
    Resources
end

% FIXME: debug
disp_mode = "normal";
Count_mode = "eco";

if ~isempty(Resources)
    stop_button = Resources.stop_button;
else
    stop_button = [];
end

msg = char(msg);
if msg ~= ""
    msg = [' (' msg ')'];
end

if time_s < 0.3
    if disp_mode == "normal"
        klog.disp(['Pause for ' num2str(round(time_s*100)/100) ' s' msg], "debug_light");
    end
    pause(time_s)
else
    if Count_mode == "eco"
        Num_of_disp = 10;
        FMT = '%0.1f';
    else
        Num_of_disp = inf;
        FMT = '%0.2f';
    end
  
    Pause_time = time_s/Num_of_disp;

    Timer = tic;
    stop = false;
    while ~stop
        Time = toc(Timer);

        stop_btn_flag = fit_gui.stop_check(stop_button);
        if stop_btn_flag
            return;
        end

        if Time > time_s
            stop = true;
        end
       
        if disp_mode == "normal"
            Time_disp = round(Time*100)/100;
            klog.disp([num2str(Time_disp, FMT) ' / ' num2str(time_s, FMT) msg], "debug_light")
        end

        Last = time_s - Time;
        if Pause_time > Last
            Pause_time = Last*0.95;
        end

        pause(Pause_time);
    end
end

end