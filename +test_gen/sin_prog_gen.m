
function [Amp_value, Phi_value, Bg_value] = sin_prog_gen(Time_arr, Profile, Traits)
arguments
    Time_arr double
    Profile {mustBeMember(Profile, ...
        ["strong", "mid", "weak", "const"])} = "const"
    Traits {mustBeMember(Traits, ...
        ["", "nobg", "zerophi", "nonoise", "lownoise", "constphi"])} = ""
end


switch Profile 
    case "strong"
        Amp = test_gen.rand_log_range(0.01, 3);
        Amp_rdiv_pmin = test_gen.rand_range(0.5, 1.5);

        Phi = test_gen.rand_range(-180, 180);
        Phi_adiv_pmin = 20;

        Background = test_gen.rand_range(-5, 5);
        Bg_rdiv_pmin = test_gen.rand_range(0.75, 1.25);
        Bg_adiv_pmin = test_gen.rand_range(-2, 2);
    case "mid"
        Amp = test_gen.rand_log_range(0.05, 3);
        Amp_rdiv_pmin = test_gen.rand_range(0.85, 1.15);

        Phi = test_gen.rand_range(-180, 180);
        Phi_adiv_pmin = 5;

        Background = test_gen.rand_range(-2, 2);
        Bg_rdiv_pmin = test_gen.rand_range(0.93, 1.07);
        Bg_adiv_pmin = test_gen.rand_range(-1, 1);
    case "weak"
        Amp = test_gen.rand_log_range(0.05, 3);
        Amp_rdiv_pmin = test_gen.rand_range(0.98, 1.02);

        Phi = test_gen.rand_range(-180, 180);
        Phi_adiv_pmin = 1;

        Background = test_gen.rand_range(-2, 2);
        Bg_rdiv_pmin = test_gen.rand_range(0.98, 1.02);
        Bg_adiv_pmin = test_gen.rand_range(-0.1, 0.1);
    case "const"
        Amp = test_gen.rand_range(0.05, 3);
        Amp_rdiv_pmin = 1;

        Phi = test_gen.rand_range(-180, 180);
        Phi_adiv_pmin = 0;
        
        Background = test_gen.rand_range(-3, 3);
        Bg_rdiv_pmin = 1;
        Bg_adiv_pmin = 0;
end

if any(Traits == "nobg")
    disp('nobg active')
    Background = test_gen.rand_range(0, 0);
    Bg_rdiv_pmin = 1;
    Bg_adiv_pmin = 0;
end

if any(Traits == "zerophi")
    disp('zerophi active')
    Phi = 0;
end

[Bg_value, bv] = test_gen.poly3_gen(Time_arr, Background, Bg_rdiv_pmin, Bg_adiv_pmin);
[Amp_value, av] = test_gen.poly3_gen(Time_arr, Amp, Amp_rdiv_pmin, 0);
if any(Traits == "constphi")
    [Phi_value, ~] = test_gen.poly3_gen(Time_arr, Phi, 1, 0);
else
    [Phi_value, ~] = test_gen.poly3_gen(Time_arr, Phi, 1, Phi_adiv_pmin);
end

% bv
% av
% pv
Bg_value = Bg_value';
Amp_value = Amp_value';
Phi_value = Phi_value';

end

