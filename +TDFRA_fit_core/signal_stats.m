function [Mean, Span, Min, Max] = signal_stats(Signal)
    Signal = medfilt1(Signal);

    Min = min(Signal);
    Max = max(Signal);
    Mean = mean(Signal);
    Span = abs(Max-Min);
end
