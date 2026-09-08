

function [Result] = LCR_measure(LCR_type, Gen_freq, Gen_Voltage_level, Time_profile)
arguments
    LCR_type % FIXME: add type
    Gen_freq
    Gen_Voltage_level
    Time_profile string {mustBeMember(Time_profile, ...
        ["ultra_fast", "common", "fine", "most_accurate"])} = "common"
end

Result = Aster_FRA.LCR_result_type.empty();

LCR_dev = feval(LCR_type{1}, LCR_type{2});

if ~isa(LCR_dev, "adev_traits.LCR_meter_traits")
    delete(LCR_dev);
    error('Wrong type of LCR dev class, not an LCR_meter_traits')
end

try
    ignore_flag = false;

    Limits = LCR_dev.get_max_amp_and_freq();

    Min_amp = Limits.amp_min;
    Max_amp = Limits.amp_max;
    Min_freq = Limits.freq_min;
    Max_freq = Limits.freq_max;

    if Gen_freq < Min_freq || Gen_freq > Max_freq
        ignore_flag = true;
    end

    if Gen_Voltage_level > Max_amp
        Gen_Voltage_level = Max_amp;
    end

    if Gen_Voltage_level < Min_amp
        Gen_Voltage_level = Min_amp;
    end

    if ~ignore_flag
        Gen_Voltage_level = LCR_dev.set_amplitude(Gen_Voltage_level);
        Gen_freq = LCR_dev.set_freq(Gen_freq);
        [R_abs, Phi_deg, R_abs_err, Phi_deg_err] = ...
            LCR_dev.get_R_Phi_with_errors(Time_profile);

        Zfull = R_abs*cos(Phi_deg/180*pi) + R_abs*1i*sin(Phi_deg/180*pi);
        [C_par, R_par] = fit_viewer.RC_calc_parallel(Zfull, Gen_freq);
        

        Result = Aster_FRA.LCR_result_type;

        Result.freq = Gen_freq;
        Result.gen_amp = Gen_Voltage_level;
        Result.gen_dc = 0; % FIXME

        Result.res_abs = R_abs;
        Result.res_abs_err = R_abs_err;

        Result.phi = Phi_deg;
        Result.phi_err = Phi_deg_err;

        Result.harm = Aster_FRA.LCR_harm_result_type.empty;

        Result.cap_par = C_par;

        Result.r_scale = NaN;
        Result.range_n = NaN;
        Result.current = NaN;
        Result.current_error = NaN;
        Result.voltage = NaN;
        Result.voltage_error = NaN;

    end

catch err
    delete(LCR_dev);
    rethrow(err);
end

delete(LCR_dev);

end








