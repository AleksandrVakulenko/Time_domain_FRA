

% NOTE: test of AFG1022_dev
% FIXME: place to Fern:aDevice

clc

Gen = AFG1022_dev();


Gen.set_freq(30.2)
Gen.set_amp(1)
Gen.set_offset(0)
Gen.set_func("sin")

delete(Gen)







