
%% Fern load

Fern.load('aDevice')
Fern.load('FRA_tools')
Fern.load('Common') 

%%
% last date: 2026.03.27               
% 
% TODO:
% 
% 1) upgrade estimations in data gathering
% 2) do more estimations by DFT
% 3) use different strategy for different periods
% 4) Add non-realtime version of fit (use non real-time estimations)
% 5) Add non-realtime version of fit (just incoming estimations)
% 6) Add pref for accuracy, and measure accuracy somehow
% 7) Use pre-fit to finish earlier
% 
% 8) investigate "underrange" function behavior
% 9) Aster connection error (add delay and retry)
%
% 10) use incoming estimations
% 11) use Estimations for Properties
% 12) add input condition for harm measure or harm ignore
% 13) update data viewer (to both test or real data)
% 14) add data saver function
%  
% 15) add absolute errors (hardware)
% 16) add more errors calculation (for colplex numbers)
% 17) upgrade synth test
% 18) [sig_gen:] add underrange (span and mean) test signals
%  
% 19) do functions structure refactor
% 20) make Fern module
% 21) place fft functions to its own lib
% 22) 
%  
% 23) DFT vs fft problem (calculating many DFTs) (where?)
% 24) phase around -180[deg] problem
% 25) Remember about f = 0 on fft calc data
% 26) 
