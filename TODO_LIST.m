
%% Fern load

Fern.load('aDevice')
Fern.load('FRA_tools')
Fern.load('Common') 

%%
% last date: 2026.03.28
% 
% TODO:
% 
% 1) Add data type for fit result
% 2) Convert fit result to estimation
% 3) Add Fs lowering setting to fit function
% 4) Add accuracy setting to fit function
% 5) Use prefit result as estimations
% 6) refactor estimations fix
% 7) add options to dont use prefit
% 
% 
% 8) use different strategy for different periods
% 9) Add non-realtime version of fit (use non real-time estimations)
% 10) Add non-realtime version of fit (just incoming estimations)
% 11) use Estimations for Properties
%
% 12) use incoming estimations
% 13) add input condition for harm measure or harm ignore
% 14) investigate "underrange" function behavior
% 15) update data viewer (to both test or real data)
%
% 16) add data saver function
% 17) add absolute errors (hardware)
% 18) add more errors calculation (for colplex numbers)
% 19) 
%
% 20) 
% 21) upgrade synth test
% 22) [sig_gen:] add underrange (span and mean) test signals
% 23) Add DAC propertie of having simultaneous sampling
%
% 24) make Fern module
% 25) place fft functions to its own lib
% 26) DFT vs fft problem (calculating many DFTs) (where?)
% 27) phase around -180[deg] problem
% 28) Remember about f = 0 on fft calc data
% 29) 

