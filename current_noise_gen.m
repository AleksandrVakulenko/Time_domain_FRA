

function Signal_Noise = current_noise_gen(Time_data)

load('Data_for_noise_gen.mat', 'Peak_amp', 'Peak_freq')

Signal_Noise = zeros(size(Time_data));
for i = 1:numel(Peak_freq)
    F = Peak_freq(i);
    A = Peak_amp(i);
    Phi = rand()*2*pi;
    Harm = A*sin(2*pi*F*Time_data + Phi);
    Signal_Noise = Signal_Noise + Harm;
end


Amp_norm_noise = 0.1*max(Peak_amp);

Norm_noise = normrnd(0, Amp_norm_noise, size(Time_data));
Signal_Noise = Signal_Noise + Norm_noise;

Pink_noise = pinknoise(size(Time_data));

Pink_noise = Pink_noise * max(Peak_amp);

Signal_Noise = Signal_Noise + Pink_noise;


end








