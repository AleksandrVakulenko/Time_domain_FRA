
% FIXME: (1) add errors

function [C, R] = RC_calc(Z, Freq, option)
arguments
    Z complex
    Freq double
    option {mustBeMember(option, ["series", "parallel"])}
end

if option == "series"
    [C, R] = RC_calc_series(Z, Freq);
else
    [C, R] = RC_calc_parallel(Z, Freq);
end

end



function [C_par, R_par] = RC_calc_parallel(Z, Freq)
Abs_sq = real(Z).^2 + imag(Z).^2;
R_par = Abs_sq./real(Z);
C_par = -imag(Z)./(2*pi*Freq .* Abs_sq);
end


function [C_ser, R_ser] = RC_calc_series(Z, Freq)
R_ser = real(Z);
C_ser = -1./(2*pi*Freq.*imag(Z));
end