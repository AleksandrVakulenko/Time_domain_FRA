

function [Properties_1, Properties_2] = get_fit_props(Period_counter)

if Period_counter < 1.1
    Properties_1.Amp_type = "const";
    Properties_1.BG_type = "const";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "const";
    Properties_2.BG_type = "const";
    Properties_2.Phi_type = "const";

elseif Period_counter < 1.6
    Properties_1.Amp_type = "const";
    Properties_1.BG_type = "const";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "const";
    Properties_2.BG_type = "linear";
    Properties_2.Phi_type = "const";

elseif Period_counter < 2
    Properties_1.Amp_type = "const";
    Properties_1.BG_type = "linear";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "const";
    Properties_2.BG_type = "linear";
    Properties_2.Phi_type = "const";

elseif Period_counter < 3
    Properties_1.Amp_type = "const";
    Properties_1.BG_type = "linear";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "const";
    Properties_2.BG_type = "poly2";
    Properties_2.Phi_type = "const";

elseif Period_counter < 5
    Properties_1.Amp_type = "linear";
    Properties_1.BG_type = "linear";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "linear";
    Properties_2.BG_type = "poly2";
    Properties_2.Phi_type = "const";

else
    Properties_1.Amp_type = "linear";
    Properties_1.BG_type = "poly2";
    Properties_1.Phi_type = "const";

    Properties_2.Amp_type = "poly2";
    Properties_2.BG_type = "poly2";
    Properties_2.Phi_type = "const";
end


end
