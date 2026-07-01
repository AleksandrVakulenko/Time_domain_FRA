function Result = DFT_estimation(Time, Signal, Period)
    Start_time = Time(1);
    End_time = Time(end);
    Freq = 1/Period;


    Time_length = End_time - Start_time;
    Periods_counter = Time_length/Period;

    if Periods_counter < 0.98 % FIXME: magic constant NOTE: at least one full period
        Result = [];
    else
        [Amp_DFT, Phi_DFT, Mean] = fit_core.DFT_single_freq(Time, Signal, Freq);
    
        Result = fit_core.Estimation_type;
        Result.amp = Amp_DFT;
        Result.phi = Phi_DFT;
        Result.bg = Mean;
        % FIXME: add f_dev
        % FIXME: add errors
        Result.t_min = Start_time;
        Result.t_max = End_time;
        Result.z = 0; % NOTE: could not be calculated here; maybe set NaN (if poossible)
        Result.status = "ok";
        Result.source = "DFT";
    end
end