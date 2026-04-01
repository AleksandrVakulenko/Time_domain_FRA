
%% Fern load

Fern.load('aDevice')
Fern.load('FRA_tools')
Fern.load('Common') 

%%
% last date: 2026.03.28
% 
% TODO:
% 
% 1) 
% 2) Overrange timing
% 3) That is fit Result is empty?
% 4) Use residuals to estimate max possible quality
% 
% 5) Add accuracy setting to fit function
% 6) add options to dont use prefit
% 7) use different strategy for different periods
% 8) use Estimations for Properties
% 
% 9) Add non-realtime version of fit (use non real-time estimations)
% 10) use incoming estimations
% 11) refactor estimations fix
% 12) Add non-realtime version of fit (just incoming estimations)
% 
% 13) harm auto-detector
% 14) add input condition for harm measure or harm ignore
% 15) 
% 16) investigate "underrange" function behavior
% 
% 17) update data viewer (to both test or real data)
% 18) add data saver function
% 19) add absolute errors (hardware)
% 20) add more errors calculation (for colplex numbers)
% 
% 21) upgrade synth test
% 22) [sig_gen:] add underrange (span and mean) test signals
% 23) 
% 24) 
% 
% 25) Add DAC propertie of having simultaneous sampling
% 26) 
% 27) make Fern module
% 28) place fft functions to its own lib
% 
% 29) DFT vs fft problem (calculating many DFTs) (where?)
% 30) phase around -180[deg] problem
% 31) Remember about f = 0 on fft calc data
% 32) 
% 
% 
