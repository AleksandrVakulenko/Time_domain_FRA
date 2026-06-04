function out = Harm_calc(Result_in, Time)
Harm = Result_in.harm;
if ~isempty(Harm)
    Freq = Result_in.freq;
    Freq_dev = Result_in.f_dev_ppm;
    Freq = Freq * (1 + Freq_dev/1e6);
    out = zeros(size(Time));
    for i = 1:numel(Harm)
        hn = Harm(i).n;
        A = Harm(i).amp;
        P = Harm(i).phi;
        H_value = A*sin(2*pi*hn*Freq*Time + P/180*pi);
        out = out + H_value;
    end
else
    out= [];
end

end