



function [Phase, Status] = estimate_phi_part_sin(Time, Signal, Period)

Time_len = Time(end) - Time(1);
Fraction = Time_len/Period;

if Fraction <= 0.4
    Phase = [];
    Status = "too short";
    return 
end

if Fraction > 0.4 && Fraction <= 0.7
    Phase = short_sig_phase_calc(Time, Signal, Period);
    Status = "OK";
    return
end

if Fraction > 0.7 && Fraction <= 1.4
    N = round(numel(Time)/2);
    Phase1 = short_sig_phase_calc(Time(1:N), Signal(1:N), Period);
    Phase2 = short_sig_phase_calc(Time(N+1:end), Signal(N+1:end), Period);
    Phase = mean([Phase1 Phase2]);
    Status = "OK";
    return
end


if Fraction > 1.4 && Fraction <= 2.0
    N1 = round(numel(Time)*1/3);
    N2 = round(numel(Time)*2/3);
    Phase1 = short_sig_phase_calc(Time(1:N1), Signal(1:N1), Period);
    Phase2 = short_sig_phase_calc(Time(N1+1:N2), Signal(N1+1:N2), Period);
    Phase3 = short_sig_phase_calc(Time(N2+1:end), Signal(N2+1:end), Period);
    Phase = mean(medfilt1([Phase1 Phase2 Phase3]));
    Status = "OK";
    return
end

Phase = [];
Status = "too long";


end
