

function Aster_switch_to_LCR(Aster_addr)

    Aster = Aster_dev(Aster_addr);
    
    err = [];
    try
        Aster.set_connection_mode("LCR");
    catch err
        delete(Aster);
        rethrow(err)
    end
    
    if isempty(err)
        delete(Aster);
    end

end