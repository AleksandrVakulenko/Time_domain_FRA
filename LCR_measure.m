

function [Result] = LCR_measure(Gen_freq, Gen_Voltage_level, LCR_serial_num)
arguments
    Gen_freq
    Gen_Voltage_level
    LCR_serial_num = []
end

    ignore_flag = false;
    
    LCR_gen_freq = Gen_freq;
    if LCR_gen_freq < 20 || LCR_gen_freq > 300e3
        ignore_flag = true;
    end
    
    LCR_gen_voltage = Gen_Voltage_level;
    if LCR_gen_voltage > 2
        LCR_gen_voltage = 2;
    end
    
    
    Z = [];
    Phi = [];
    if ~ignore_flag
        LCR_dev = LCR_E4980AL(LCR_serial_num); % FIXME: use any LCR type
        try
            LCR_dev.set_volt(LCR_gen_voltage);
            LCR_dev.set_freq(LCR_gen_freq);
            LCR_dev.set_speed('short', 1); % FIXME: magic constant
            LCR_dev.set_measurment_function("Z-thd");
            pause(0.1);
            for i = 1:5
                disp(i)
                [Z(i), Phi(i)] = LCR_dev.get_readings;
            end
        catch err
            delete(LCR_dev);
            rethrow(err);
        end
        
        delete(LCR_dev);
    end
    
    
    Result.res_abs = mean(Z);
    Result.res_abs_err = 3*std(Z);
    
    Result.phi = mean(Phi);
    Result.phi_err = 3*std(Phi);
    
    Result.cap_par = [];
    Result.r_scale = [];
    Result.current = [];
    Result.current_error = [];
    Result.voltage = [];
    Result.voltage_error = [];

end








