

function Signal = signal_saturation(Signal, Low, High)


High_range = Signal >= High;
Low_range = Signal <= Low;

Signal(High_range) = High;
Signal(Low_range) = Low;



end



