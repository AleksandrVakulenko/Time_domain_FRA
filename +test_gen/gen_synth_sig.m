

function [Synth_time, Synth_signal, Props, Noise] = ...
    gen_synth_sig(freq, Freq_dev_ppm, Duration, Profile, Traits, Seed, Fs)
arguments
    freq double
    Freq_dev_ppm double
    Duration double
    Profile {mustBeMember(Profile, ...
        ["strong", "mid", "weak", "const", "nobg"])} = "const"
    Traits {mustBeMember(Traits, ["", "nobg", "zerophi", "constphi", ...
        "nonoise", "lownoise", 'filter30' ...
        "noharm"])} = ""
    Seed string = ""
    Fs double = 10e3
end

Seed = test_gen.set_rand(Seed);

% FIXME: add time shift
% Time_shift = rand_range(0, 10e3); % [s]
% Synth_time = (0:1/Fs:Duration) + Time_shift;

Synth_time = (0:1/Fs:Duration);

[Amp, Phi, Background] = test_gen.sin_prog_gen(Synth_time, Profile, Traits);
F = freq*(1+Freq_dev_ppm/1e6);

Props.freq = F;
Props.freq_dev_ppm = Freq_dev_ppm;
Props.amp = Amp;
Props.phi = Phi;
Props.bg = Background;
Props.seed = Seed;
Props.duration = Duration;
Props.profile = Profile;
Props.traits = Traits;
Props.fs = Fs;

Synth_signal = Amp.*sin(2*pi*F.*Synth_time + Phi/180*pi) + Background;

% NOTE: gen predetermined seeds for variable parts
Seed_1 = test_gen.gen_string(6);
Seed_2 = test_gen.gen_string(6);
Seed_3 = test_gen.gen_string(6); % NOTE: unused
Seed_4 = test_gen.gen_string(6); % NOTE: unused
Seed_5 = test_gen.gen_string(6); % NOTE: unused

if ~any(Traits == "nonoise")
    test_gen.set_rand(Seed_1); % NOTE: use Seed_1 for noise gen
    Noise_gen = test_gen.current_noise_gen(Synth_time);
    % NOTE: scale for noise
    Scale = 3e-10;
    if any(Traits == "lownoise")
        Noise = Noise_gen/Scale*0.08;
    else
        Noise = Noise_gen/Scale*0.4;
    end
    Synth_signal = Synth_signal + Noise;
else
    Noise = [];
end

if ~any(Traits == "noharm")
    test_gen.set_rand(Seed_2); % NOTE: use Seed_2 for harm gen
    harm = struct('n', [], 'amp', [], 'phi', []);
    k = 0;
    N = round(rand(10, 1)*4)+2;
    for i = 2:N % FIXME
        [H_amp, H_phi] = harm_gen(Amp);
        y_harm = H_amp*sin(2*pi*i*freq*Synth_time + H_phi/180*pi);
        Synth_signal = Synth_signal + y_harm;
        k = k + 1;
        harm(k).n = i;
        harm(k).amp = H_amp;
        harm(k).phi = H_phi;
    end
else
    harm = [];
end
Props.harm = harm;

% FIXME: add saturation limit property
Synth_signal = test_gen.signal_saturation(Synth_signal, -5, 5);

if any(Traits == "filter30")
    load('+test_gen/Filter_LF_FIR_2_30.mat', 'Hd');
    Synth_signal = filter(Hd, Synth_signal-Synth_signal(1))+Synth_signal(1);
end

end





function [Amp, Phi] = harm_gen(Amp)

Max_amp = max(Amp);

Amp_scale = test_gen.rand_log_range(0.0001, 0.1);

Amp = Max_amp*Amp_scale;
Phi = test_gen.rand_range(-180, 180);
end




