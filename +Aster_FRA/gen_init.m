
function gen_init(Aster, Gen_Voltage_level, Gen_freq, DC_bias)
arguments
    Aster
    Gen_Voltage_level
    Gen_freq
    DC_bias = 0
end

% FIXME: add DC_bias; now it is wrong settings

if Gen_Voltage_level >= 0.04
    High_voltage_mode(Aster, Gen_Voltage_level, Gen_freq, DC_bias)
else
    Low_voltage_mode(Aster, Gen_Voltage_level, Gen_freq)
end

end


function High_voltage_mode(Aster, Gen_Voltage_level, Gen_freq, DC_bias)

if Gen_freq < 2
    MUX_SETTING = 3;
elseif Gen_freq < 20
    MUX_SETTING = 2;
elseif Gen_freq < 500
    MUX_SETTING = 1;
else
    MUX_SETTING = 0;
end

Aster.Generator_waveform(Gen_Voltage_level, Gen_freq, "sin", DC_bias)
Aster.Gen_direction("Internal"); % FIXME: no effect if Aster.set_connection_mode("I2V");
Aster.Generator_out_active(1);
Aster.Generator_out_opamp("AD817");
Aster.Generator_out_mux(MUX_SETTING);

end



function Low_voltage_mode(Aster, Gen_Voltage_level, Gen_freq)

if Gen_Voltage_level > 10e-3
    MUX_SETTING = 1;
    Gen_Voltage_level = Gen_Voltage_level*100;
else
    Gen_Voltage_level = Gen_Voltage_level*1000;
    if Gen_freq > 40
        MUX_SETTING = 2;
    else
        MUX_SETTING = 3;
    end
end

Aster.Generator_waveform(Gen_Voltage_level, Gen_freq, "sin")
Aster.Gen_direction("Internal"); % FIXME: no effect if Aster.set_connection_mode("I2V");
Aster.Generator_out_active(1);
Aster.Generator_out_opamp("OPA182");
Aster.Generator_out_mux(MUX_SETTING);

end



















