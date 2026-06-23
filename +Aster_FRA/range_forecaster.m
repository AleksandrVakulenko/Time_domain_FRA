

function [Range_num, Current_value] = range_forecaster(Ammeter, Zest, Amp, Freq)

if isempty(Zest)
    Range_num = [];
    Current_value = [];
    return;
end

if Zest.type == "cap"
    Res = 1/(2*pi*1i*Freq*Zest.value);
elseif Zest.type == "res"
    Res = Zest.value;
else

end

Current = Amp/Res;

Current_value = abs(Current);


if class(Ammeter) == "Aster_dev" || Ammeter == "Aster_dev"
    Res_list = [200 10e3 1e6 100e6 10e9 1e12]; % Ohm
    V2_max = 5; % V
    V_out = Current_value * Res_list;
    List = V_out <= V2_max;
    ind = find(List);
    if ~isempty(ind)
        Range_num = ind(end);
    else
        Range_num = [];
    end
else
    Range_num = [];
end

end










