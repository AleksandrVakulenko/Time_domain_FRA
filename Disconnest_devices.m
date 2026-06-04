function Disconnest_devices(Aster, Gen)
    if class(Gen) == "Aster_dev"
        Aster_gen_terminate(Aster);
    else
        Gen.terminate();
        delete(Gen);
    end
    Aster.terminate();
    delete(Aster);
end