function Result = DFT_estimation(Time, Signal, Period)
    Start_time = Time(1);
    End_time = Time(end);
    Freq = 1/Period;

    [Amp_DFT, Phi_DFT, Mean] = DFT_single_freq(Time, Signal, Freq);

    Result = fit_core.Estimation;
    Result.amp = Amp_DFT;
    Result.phi = Phi_DFT;
    Result.bg = Mean;
    % FIXME: add f_dev
    % FIXME: add errors
    Result.t_min = Start_time;
    Result.t_max = End_time;
    Result.z = 0;
    Result.status = "ok";
    Result.source = "DFT";
end