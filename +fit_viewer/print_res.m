function print_res(Res, Res_err)
arguments
    Res
    Res_err = []
end
    if abs(Res) >= 1e12
        unit = 'TOhm';
        scale = 1e-12;
    elseif abs(Res) >= 1e9
        unit = 'GOhm';
        scale = 1e-9;
    elseif abs(Res) >= 1e6
        unit = 'MOhm';
        scale = 1e-6;
    elseif abs(Res) >= 1e3
        unit = 'kOhm';
        scale = 1e-3;
    else
        unit = 'Ohm';
        scale = 1;
    end
    
    if ~isempty(Res_err)
        disp(['|R| = ' num2str(Res*scale, '%0.4f') ' ± ' ...
            num2str(Res_err*scale, '%0.4f') ' ' unit])
    else
        disp(['|R| = ' num2str(Res*scale, '%0.4f') ' ' unit])
    end
end