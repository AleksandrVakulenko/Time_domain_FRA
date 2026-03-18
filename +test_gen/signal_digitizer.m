
function Signal = signal_digitizer(Signal, Amp, Bits)

Scale = 1/Amp * 2^Bits;

Signal_scaled = Signal*Scale;
Signal_rounded = round(Signal_scaled);
Signal = Signal_rounded/Scale;
end