function Result = DFT_estimation(Time, Signal, Period)
    Start_time = Time(1);
    End_time = Time(end);
    Freq = 1/Period;


    Time_length = End_time - Start_time;
    Periods_counter = Time_length/Period;

%     FIXME: why check with 0.98?
%     NOTE: at least one full period
    if Periods_counter < 0.98 
        Result = [];
    else
        [Amp_DFT, Phi_DFT, Mean] = TDFRA_fit_core.DFT_single_freq(Time, Signal, Freq);
    
        Result = TDFRA_fit_core.Estimation_type;
        Result.amp = Amp_DFT;
        Result.phi = Phi_DFT;
        Result.bg = Mean;
        % FIXME: (3) add f_dev
        % FIXME: (3) add errors
        Result.t_min = Start_time;
        Result.t_max = End_time;
        Result.z = 0; % NOTE: could not be calculated here; maybe set NaN (if poossible)
        Result.status = "ok";
        Result.source = "DFT";
    end
end