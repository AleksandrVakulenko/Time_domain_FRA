
% FIXME: add info header
% FIXME: add class constructor

classdef LCR_harm_result_type

    methods (Access = public, Static)
        function v = get_version()
            v = [1 0 0];
        end
    end

    properties (Access = public)

        % FIXME: Maybe add basic freq
        n double;
        res double;
        res_err double;
        phi double;
        phi_err double;

    end

end










