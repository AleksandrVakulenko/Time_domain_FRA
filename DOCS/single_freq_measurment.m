
% FIXME: read and check this function info

%SINGLE_FREQ_MEASURMENT  Perform a single‑frequency impedance measurement.
%
%   [Fit_Result, Extra_data] = single_freq_measurment(Resources, Aster_addr, ...
%       Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Zest, Time_profile, ...
%       Fig_or_ax, Fixed_range, Self_cal_mode, Noisy_env)
%
%   This function drives an Aster frequency response analyser (FRA) to
%   measure the response of a device under test at one specific frequency.
%   It acquires two voltage channels, fits sine waves (including a specified
%   number of harmonics) to the data, optionally plots the measured data and
%   fitted curves, and returns the derived impedance (or transfer function)
%   together with extensive auxiliary information.
%
%   INPUTS
%       Resources           - Instrument resource object or identifier used
%                             to communicate with the Aster FRA (e.g. a VISA
%                             object). This is passed directly to the
%                             Aster_FRA.measure method.
%       Aster_addr          - Address (or identifier) of the Aster instrument
%                             within the resources. Passed to the measure
%                             method.
%       Gen_freq            - Generator frequency in Hz at which the
%                             measurement is performed.
%       Gen_Voltage_level   - Amplitude of the generator output voltage (V).
%       DC_bias             - DC offset voltage (V) applied to the generator.
%                             NOTE: Currently this value is stored in the
%                             settings structure but not actively used in
%                             the measurement. It is kept for compatibility.
%       Harm_num            - Number of harmonics to include in the sine‑fit
%                             model. A value of 1 fits a pure sine wave.
%       Zest                - Estimated impedance magnitude (Ohm) of the
%                             device under test. This is used by the
%                             instrument to select appropriate input ranges.
%       Time_profile        - Structure or parameter defining the acquisition
%                             time profile (e.g. number of periods, settling
%                             time). The exact format is defined by the
%                             Aster_FRA.measure function.
%       Fig_or_ax           - Handle to a figure or an array of axes handles
%                             where the measured data and fitted curves will
%                             be plotted. If empty or invalid, no plotting is
%                             performed.
%       Fixed_range         - Boolean or range specification to force the
%                             input ranges to a fixed value. If true (or a
%                             specific range), the automatic range selection
%                             is disabled.
%       Self_cal_mode       - Boolean flag to enable the instrument's self‑
%                             calibration routine before measurement.
%       Noisy_env           - Boolean flag indicating a noisy electrical
%                             environment. When true, a power‑line filter is
%                             enabled and the acquisition time is extended to
%                             allow the filter to settle.
%
%   OUTPUTS
%       Fit_Result          - Structure containing the final impedance (or
%                             transfer function) result calculated from the
%                             fitted sine waves. The exact fields are defined
%                             by Aster_FRA.do_FRA_result. If fitting fails,
%                             this output is an empty array.
%       Extra_data          - Structure with the following fields:
%           ch_data_1, ch_data_2  - Raw acquired data for channels 1 and 2,
%                                   including time, voltage, and outlier mask.
%           result_1, result_2    - Fitting result structures for each channel.
%           residuals_1, residuals_2 - Residuals of the fits.
%           score                  - Sub‑structure with fields:
%               score_1, score_2   - Quality scores (0–1) for each channel.
%               best_flag          - Flag indicating which channel was better.
%               max_score          - The higher of the two scores.
%           DEBUG                 - Sub‑structure with debug information:
%               DEBUG_1, DEBUG_2   - Debug data from the fitting process.
%           used_ranges           - Input ranges actually used by the
%                                   instrument after auto‑ranging.
%           aster_range           - Range setting of the Aster instrument.
%
%   NOTES
%       * The function internally sets:
%           - Harmonic profile: 'common'
%           - Use of power‑line filter: equal to Noisy_env
%       * The measurement is executed inside a try–catch block. If an error
%         occurs, the function prints an error message and returns empty
%         outputs.
%       * If the measurement exit flag equals 40, the function throws an
%         error indicating user termination.
%       * The maximum number of points used for fitting is hard‑coded to
%         50,000.
%       * Plotting is performed only when Fig_or_ax is a valid 2‑element
%         array of axes handles.
%
%   See also Aster_FRA.measure, fit_core.fit_two_channels, 
%            fit_viewer.score_calc, fit_gui.init_gather_axes,
%            Aster_FRA.do_FRA_result.

