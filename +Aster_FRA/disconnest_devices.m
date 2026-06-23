
% FIXME: this function is also a part of FRA toolbox

function disconnest_devices(Aster, Gen)
    if class(Gen) == "Aster_dev"
        Aster_FRA.gen_terminate(Aster);
    else
        Gen.terminate();
        delete(Gen);
    end
    Aster.terminate();
    delete(Aster);
end