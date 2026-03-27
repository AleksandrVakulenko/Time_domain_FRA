function [out_time, out_sig] = get_one_period(Time, Signal, Period, mode, Scale)
arguments
    Time
    Signal
    Period
    mode {mustBeMember(mode, ["first", "last"])} = first
    Scale = 1
end
if mode == "last"
    if Scale > 2
        Scale = 2;
    end
    Length = Time(end) - Time(1);
    if Length <= Period*Scale
        out_time = Time;
        out_sig = Signal;
    else
        range = Time >= (Time(end) - Period*Scale);
        out_time = Time(range);
        out_sig = Signal(range);
    end
else % first
    Length = Time(end) - Time(1);
    if Length <= Period*Scale
        out_time = Time;
        out_sig = Signal;
    else
        range = Time <= Time(1) + Period*Scale;
        out_time = Time(range);
        out_sig = Signal(range);
    end
end
end