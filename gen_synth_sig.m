

function [Synth_time, Synth_signal, Props] = ...
    gen_synth_sig(freq, Freq_dev_ppm, Duration, Profile, Traits, Seed, Fs)
arguments
    freq double
    Freq_dev_ppm double
    Duration double
    Profile {mustBeMember(Profile, ...
        ["strong", "mid", "weak", "const", "nobg"])} = "const"
    Traits {mustBeMember(Traits, ...
        ["", "nobg", "zerophi", "nonoise"])} = ""
    Seed string = ""
    Fs double = 10e3
end

Seed = set_rand(Seed);

% FIXME: ADD THIS
% Time_shift = rand_range(0, 10e3); % [s]
% Synth_time = (0:1/Fs:Duration) + Time_shift;


%------------------------------------
Scale = 3e-10;

%------------------------------------

Synth_time = (0:1/Fs:Duration);

[Amp, Phi, Background] = sin_prog_gen(Synth_time, Profile, Traits);
F = freq*(1+Freq_dev_ppm/1e6);

Props.freq = F;
Props.freq_dev_ppm = Freq_dev_ppm;
Props.amp = Amp;
Props.phi = Phi;
Props.bg = Background;
Props.seed = Seed;
Props.profile = Profile;
Props.traits = Traits;
Props.fs = Fs;

Synth_signal = Amp.*sin(2*pi*F.*Synth_time + Phi/180*pi) + Background;

if ~any(Traits == "nonoise")
    Noise_gen = current_noise_gen(Synth_time);
    Synth_signal = Synth_signal + Noise_gen/Scale*0.4;
end

Synth_signal = signal_saturation(Synth_signal, -5, 5);

end










