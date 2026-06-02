

function [Range_num, Current_value] = Range_forecaster(Ammeter, Cap, Amp, Freq)

if isempty(Cap)
    Range_num = [];
    Current_value = [];
    return;
end

Res = 1/(2*pi*1i*Freq*Cap);

Current = Amp/Res;

Current_value = abs(Current);


if class(Ammeter) == "Aster_dev"
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










