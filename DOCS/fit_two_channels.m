

%FIT_TWO_CHANNELS  Fit sine‑wave models to two acquired channels jointly.
%
%   [Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
%       fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
%       Harm_num, Max_points)
%
%   This function fits sine‑wave models to the data from two channels that
%   were acquired simultaneously (same time base and frequency). It first
%   fits channel 1 independently (with optional frequency deviation
%   estimation if more than two periods are available). Then it fits
%   channel 2 using the frequency deviation found in channel 1 as a fixed
%   parameter, thereby enforcing a common frequency drift for both
%   channels. The function also handles overload conditions by reducing the
%   number of harmonics for the affected channel.
%
%   INPUTS
%       Ch_data_1   - Structure with data for channel 1 (time, voltage,
%                     outliers, overload, fs, time_conf).
%       Ch_data_2   - Structure with data for channel 2 (same fields).
%       Properties_1 - Fit properties for channel 1 (from get_fit_props).
%       Properties_2 - Fit properties for channel 2.
%       Harm_num    - Number of harmonics to fit (common to both channels
%                     unless overloaded).
%       Max_points  - Maximum number of data points used in each fit.
%
%   OUTPUTS
%       Result_1, Result_2    - Structures with fitted parameters for each
%                               channel (including the field 'estimations').
%       Residuals_1, Residuals_2 - Residual vectors from the fits.
%       DEBUG_1, DEBUG_2      - Debug information for each fit.
%
%   NOTES
%       * If channel 1 fit fails, the function throws an error.
%       * If channel 2 fit fails, the function throws an error.
%       * The frequency deviation flag for channel 1 is set to true only
%         when the acquisition length is at least two periods.
%       * For channel 2, frequency deviation is fixed to the value obtained
%         from channel 1 (Fit_settings_2.freq_dev_const = Result_1.f_dev_ppm).
%       * The estimation structures (from fit_core.estimation_processing)
%         are attached to the results for later use.
%
%   See also fit_core.fit_one_channels, fit_core.fit_channel,
%            fit_core.estimation_processing, fit_core.get_fit_props.


