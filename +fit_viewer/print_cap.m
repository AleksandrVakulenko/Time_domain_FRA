function print_cap(Cap, Cap_err)
arguments
    Cap
    Cap_err = []
end
    if abs(Cap) < 1e-9
        unit = 'pF';
        scale = 1e12;
    elseif abs(Cap) < 1e-6
        unit = 'nF';
        scale = 1e9;
    elseif abs(Cap) < 1e-3
        unit = 'uF';
        scale = 1e6;
    elseif abs(Cap) < 1
        unit = 'mF';
        scale = 1e3;
    else
        unit = 'F';
        scale = 1;
    end

    if ~isempty(Cap_err)
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ± ' ...
        num2str(Cap_err*scale, '%0.3f') ' ' unit])
    else
    disp(['C = ' num2str(Cap*scale, '%0.3f') ' ' unit])
    end
end