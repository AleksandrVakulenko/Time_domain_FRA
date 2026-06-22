% NOTE:
% 1) all Aster specific function are named with prefix "Aster_"
% 2) Limit time profile on range 5 up to "fine", on range 6 to "common"
% 3) 

% TO TEST
% 1) make_fs_lower function
% 2) 

% 22.06.2026
% 1) PROBLEM IN make Fs lower FUNCTION !!!!!!
% 2) 
% 3) 
% 4) 

% 23.06.2026
% 1) One more test
% 2) Add timer_callback
% 3) Add LCR meter class
% 4) Add set_freq and set_amp in Aster hardware
% 5) Add ADC and DAC scales in Aster hardware.

% 24.06.2026
% 1) Eliminate all magic constants
% 2) Use residuals to estimate max possible quality
% 3) harm auto-detector (ALREADY: fit_core.estimate_harms_from_res)
% 4) 

% 25.06.2026
% 1) Update Debug_msg module
% 2) Add accuracy setting to fit function
% 3) Add Temp controller class
% 4) Do refactor

% 26.06.2026
% 1) Add freq to ch_data (all previously saved data will be invalidate!)
% 2) add data saver function
% 3) One more test
% 4) 



% 29.06.2026
% 1) place fft functions to its own lib
% 2) make Fern module (exclude all Astra functions)
% 3) Exclude Astra from aDevice
% 4) 

% 30.06.2026
% 1) 
% 2) 
% 3) add more errors calculation (for colplex numbers)
% 4) update data viewer (to both test or real data)

% 01.07.2026
% 1) use incoming estimations
% 2) use Estimations for Properties
% 3) 
% 4) refactor estimations fix function

% 02.07.2026
% 1) use different strategy for different periods
% 2) investigate "underrange" function behavior
% 3) 
% 4) 

% 03.07.2026
% 1) 
% 2) 
% 3) 
% 4) 




% OTHER TODO:
% 1) upgrade synth test
% 2) [sig_gen:] add underrange (span and mean) test signals
% 3) DFT vs fft problem (calculating many DFTs) (where?)
% 4) Remember about f = 0 on fft calc data
% 5) 
% 6) 




