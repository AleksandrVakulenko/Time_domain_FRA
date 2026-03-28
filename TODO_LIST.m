
%% Fern load

Fern.load('aDevice')
Fern.load('FRA_tools')
Fern.load('Common') 

%%
% last date: 2026.03.28
% 
% TODO:
% 
% 1) use different strategy for different periods
% 2) Add non-realtime version of fit (use non real-time estimations)
% 3) Add non-realtime version of fit (just incoming estimations)
% 4) 
% 5) Use pre-fit to finish earlier
% 6) use Estimations for Properties
% 7) use incoming estimations
% 
% 8) add input condition for harm measure or harm ignore
% 9) update data viewer (to both test or real data)
%
% 10) investigate "underrange" function behavior
% 11) add data saver function
% 12) add absolute errors (hardware)
% 13) add more errors calculation (for colplex numbers)
%  
% 14) upgrade synth test
% 15) [sig_gen:] add underrange (span and mean) test signals
% 16) Add DAC propertie of having simultaneous sampling
% 17) 
%  
% 18) make Fern module
% 19) place fft functions to its own lib
% 20) DFT vs fft problem (calculating many DFTs) (where?)
% 21) phase around -180[deg] problem
% 22) Remember about f = 0 on fft calc data
% 23) 
% 
