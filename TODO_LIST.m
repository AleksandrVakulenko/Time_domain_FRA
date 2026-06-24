

% 24.06.2026
% 1) 
% 2) Eliminate all magic constants
% 3) Add timer_callback
% 4) Use residuals to estimate max possible quality (50 Hz rej)
% 5) 
% 6) Add Temp controller class
% 7) Add accuracy setting to fit function
% 8) Update Debug_msg module
% 9) Add freq to ch_data2 (all previously saved data (with ch_data) will be invalidate!)
% 10) Fit_settings_1.freq_dev_flag in fit_one_channels
% 11) if RMS_Ratio > 5 in Harm_refit
% 12) Replace FRA_dev by function handle in data_gathering_loop

% 25.06.2026
% 1) Add set_freq and set_amp in Aster hardware
% 2) Add ADC and DAC scales in Aster hardware.
% 3) Add DC offset in Aster hardware
% 4) Add I input protection in Aster hardware
% 5) Exclude Astra from aDevice
% 6) Update LCR_measure function


% 26.06.2026
% 1) 
% 2) add data saver function
% 3) One more test
% 4) Refactor Aster class



% 29.06.2026
% 1) place fft functions to its own lib
% 2) make Fern module (exclude all Astra functions)
% 3) 
% 4) Do final refactor


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




