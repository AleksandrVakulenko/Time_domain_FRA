function [Aster, Gen] = Connect_to_devices(Aster_addr, Gen_type, Gen_addr)
arguments
    Aster_addr
    Gen_type {mustBeMember(Gen_type, ...
        ["Aster_dev", "SR860_dev", "AFG1022_dev"])} = "Aster_dev"
    Gen_addr = [];
end

Aster = Aster_dev(Aster_addr);

switch Gen_type
    case "Aster_dev"
        Gen = Aster;
    case "SR860_dev"
        try
            Gen = SR860_dev(Gen_addr);
        catch err
            delete(Aster);
            rethrow(err);
        end
    case "AFG1022_dev"
        try
            Gen = AFG1022_dev(Gen_addr);
        catch err
            delete(Aster);
            rethrow(err);
        end
    otherwise
        error('Wrong Generator device type')
end

end