
% NOTE:
% class for output data of all estimation functions
% bg - background 
% c_err for bg


classdef Estimation

properties (Access = public)
    amp double = NaN
    phi double = NaN
    bg double = NaN
    f_dev double = NaN

    a_err double = NaN
    p_err double = NaN
    c_err double = NaN
    fd_err double = NaN

    t_min double = NaN
    t_max double = NaN

    Period_counter double = NaN

    z double = NaN
    status string {mustBeMember(status, ["empty", "fixed", "ok"])} ...
        = "empty"
    legacy_status string {mustBeMember(legacy_status, ["", "low", "extra"])} ...
        = ""
    source string {mustBeMember(source, ["", "initial", "DFT", "simplefit"])} ...
        = ""

    fitres cfit = cfit
end

% NOTE: Z:
% 'A*sin(2*pi*F*t+P/180*pi) + C + Z*t'

end














