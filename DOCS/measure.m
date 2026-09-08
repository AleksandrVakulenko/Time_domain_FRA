

%MEASURE  Perform a full impedance measurement with the Aster FRA.
%
%   [Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
%       Used_ranges, Last_used_range] = measure(Resources, Aster_addr, ...
%       Settings, Fig, Zest, Fixed_range, Self_cal_mode)
%
%   This function drives the Aster frequency response analyser through all
%   phases of a measurement: connecting to devices, generator setup, ADC
%   configuration, range selection (automatic or fixed), data acquisition,
%   and post‑processing. It returns raw data for two channels, the scale
%   resistor value, accuracy configuration, and the ranges used.
%
%   INPUTS
%       Resources       - Instrument resource object used for communication
%                         and for reading a stop button (if provided).
%       Aster_addr      - Address (or identifier) of the Aster instrument.
%       Settings        - Structure with measurement settings:
%           .amp                    - Generator amplitude (V).
%           .freq                   - Generator frequency (Hz).
%           .dc                     - DC offset (unused).
%           .harm_num               - Number of harmonics for fitting.
%           .time_profile           - Acquisition time profile parameter.
%           .harm_profile           - Harmonic profile ('common' etc.).
%           .use_power_line_filter  - Boolean to enable line filter.
%       Fig             - (Optional) Handle to a figure or axes array for
%                         real‑time plotting during acquisition.
%       Zest            - (Optional) Estimated impedance (Ohm) used for
%                         initial range forecasting.
%       Fixed_range     - (Optional) If not empty and one of the allowed
%                         range numbers, forces a fixed input range and
%                         disables auto‑ranging.
%       Self_cal_mode   - (Optional, default false) When true, the instrument
%                         performs a self‑calibration sequence before
%                         measurement.
%
%   OUTPUTS
%       Exit_flag       - Integer code indicating the outcome:
%                           0 or 30  - Successful measurement.
%                           40       - User stop requested.
%                           101/201  - Over/under range (accepted best).
%                           102/202  - Need range switch (handled internally
%                                      if auto‑ranging).
%       Ch_data_1       - Structure with data for channel 1 (time, voltage,
%                         outliers, overload, etc.). If user stops, it is an
%                         empty object of type fit_core.Ch_data_type.
%       Ch_data_2       - Structure with data for channel 2 (same fields).
%       R_Scale         - Scale resistor value (Ohm) corresponding to the
%                         current range (used to convert voltage to current).
%       Accuracy_conf   - Structure with accuracy configuration derived from
%                         the final time profile.
%       Used_ranges     - Array of range numbers that were tried during
%                         auto‑ranging (unique). If fixed range, it contains
%                         only that range.
%       Last_used_range - The range number used for the final successful
%                         acquisition.
%
%   NOTES
%       * The function connects to the Aster and generator, then always
%         disconnects them before returning (even on error).
%       * Auto‑ranging iterates until the exit flag indicates success or a
%         non‑recoverable condition.
%       * A stop button (if available in Resources) can abort the loop,
%         producing Exit_flag = 40.
%       * If Self_cal_mode is true, the instrument is set to calibration
%         mode (external generator, GND current) and then restored.
%       * The function calls fit_core.get_time_config to compute timing
%         parameters and updates them if the range changes.
%
%   See also Aster_FRA.connect_to_devices, Aster_FRA.Gen_initiate,
%            Aster_FRA.ADC_init, Aster_FRA.set_range,
%            data_gathering_loop, fit_core.get_time_config.


