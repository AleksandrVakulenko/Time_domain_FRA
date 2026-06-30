
% FIXME: this is not an Astra specific function !

% FIXME: unused function

function Gen_initiate(Gen, Gen_Voltage_level, Gen_freq, DC_bias)
arguments
    Gen
    Gen_Voltage_level
    Gen_freq
    DC_bias = 0
end
    if class(Gen) == "SR860_dev"
        Gen.set_gen_config(Gen_Voltage_level, Gen_freq, DC_bias);
        Gen.initiate();
    elseif class(Gen) == "AFG1022_dev"
        Gen.set_func("sin");
        Gen.set_amp(Gen_Voltage_level, "amp");
        Gen.set_freq(Gen_freq);
        Gen.set_offset(DC_bias);
        Gen.initiate();
    elseif class(Gen) == "Aster_dev"
        Aster_FRA.gen_init(Gen, Gen_Voltage_level, Gen_freq, DC_bias);
    else
        error('Wong gen class')
    end

end