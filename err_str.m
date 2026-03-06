
% FIXME: put in Fern module

function [Str, Value, Err] = err_str(Value, Err)
if Err == 0
    Ne = 0;
else
    Ne = floor(log10(abs(Err)));
end
if Value == 0
    Nv = 0;
else
    Nv = floor(log10(abs(Value)));
end
if Nv <= Ne
    Nv = Nv-1;
else
    Nv = Ne-1;
end
Err = round(Err./10.^(Ne-1)).*10.^(Ne-1);
Value = round(Value./10.^(Nv)).*10.^(Nv);
Str = [num2str(Value) ' ± ' num2str(Err)];
end