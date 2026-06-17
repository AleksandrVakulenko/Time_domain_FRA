function [Estimations] = do_estimations(Estimations, T_arr, V_arr, ...
    Freq, Periods_counter)

Period = 1/Freq;

% FIXME: do we need this?
if isempty(Estimations) && Periods_counter >= 1.0
    Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
    Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
        Freq, Init_values);
    Estimations = Result;
end

switch signal_per_duration(Periods_counter)
    case "invalid" % 0 : 0.45
        % DO SOMETHING:
        % - noise analysis
        % pause(0.05*Period)

    case "get_lucky" % 0.45 : 0.5
        if isempty(Estimations)
            Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Init_values);
            Result.legacy_status = "extra";
            Estimations = Result;
        else
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Result.legacy_status = "extra";
            Estimations = [Estimations Result];
        end

    case "min" % 0.5 : 1.0
        if isempty(Estimations)
            Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Init_values);
            Result.legacy_status = "low";
            Estimations = Result;
        else
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Result.legacy_status = "low";
            Estimations = [Estimations Result];
        end

    case "single" % 1.0 : 2
        Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
            Freq, Estimations);
        Estimations = [Estimations Result];
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result2 = fit_core.DFT_estimation(out_time, out_sig, Period);
        if ~isempty(Result2)
            Estimations = [Estimations Result2];
        end


    case "long" % 2 : 10 FIXME: same as above?
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result1 = fit_core.simple_sin_fit_f(out_time, out_sig, ...
            Freq, Estimations);
        Estimations = [Estimations Result1];
        Result2 = fit_core.DFT_estimation(out_time, out_sig, Period);
        if ~isempty(Result2)
            Estimations = [Estimations Result2];
        end


    case "max" % 10 : inf
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result = fit_core.DFT_estimation(out_time, out_sig, Period);
        if ~isempty(Result)
            Estimations = [Estimations Result];
        end

end

end


function state = signal_per_duration(Periods_counter)

    state = "invalid";

    if Periods_counter > 0 && Periods_counter <= 0.45
        state = "invalid";
    end
    
    if Periods_counter > 0.45 && Periods_counter <= 0.5
        state = "get_lucky";
    end

    if Periods_counter > 0.5 && Periods_counter <= 1.0
        state = "min";
    end

    if Periods_counter > 1.0 && Periods_counter <= 2.0
        state = "single";
    end

    if Periods_counter > 2.0 && Periods_counter <= 10.0
        state = "long";
    end

    if Periods_counter > 10.0
        state = "max";
    end
end
