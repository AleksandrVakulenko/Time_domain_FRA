function Result = do_initial_estimation(T_arr, V_arr, Period)
    [Mean, Span, ~, ~] = fit_core.singal_stats(V_arr);
    
    Start_Phi = fit_core.estimate_phi_part_sin(T_arr, V_arr, Period);
    if isempty(Start_Phi)
        Start_Phi = 0;
    end

    Result = fit_core.Estimation;
    Result.amp = Span;
    Result.phi = Start_Phi;
    Result.bg = Mean;
    Result.status = "ok";
    Result.source = "initial";
end