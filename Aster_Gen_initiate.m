function Aster_Gen_initiate(Gen, Gen_Voltage_level, Gen_freq)

    if class(Gen) == "SR860_dev"
        Gen.set_gen_config(Gen_Voltage_level, Gen_freq, Gen_Offset_level);
        Gen.initiate();
    elseif class(Gen) == "AFG1022_dev"
        Gen.set_func("sin");
        Gen.set_amp(Gen_Voltage_level, "amp");
        Gen.set_freq(Gen_freq);
        Gen.set_offset(Gen_Offset_level);
        Gen.initiate();
    elseif class(Gen) == "Aster_dev"
        Aster_gen_init(Gen, Gen_Voltage_level, Gen_freq);
    else
        error('Wong gen class')
    end

end