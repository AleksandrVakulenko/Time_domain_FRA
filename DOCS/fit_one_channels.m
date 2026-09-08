

%FIT_ONE_CHANNELS  Fit a sine‑wave model to a single acquired channel.
%
%   [Result_1, Residuals_1, DEBUG_1] = fit_one_channels(Ch_data, Properties, ...
%       Harm_num, Max_points)
%
%   This function performs a non‑linear least‑squares fit of a sum of
%   sinusoids (fundamental plus harmonics) to the voltage data of one
%   channel. It first extracts estimation parameters from the raw data,
%   then calls the core fitting routine. If the channel contains overload
%   events, no harmonics are fitted (only the fundamental).
%
%   INPUTS
%       Ch_data     - Structure containing the acquired data for the channel:
%           .time           - Time vector (s).
%           .voltage        - Voltage samples (V).
%           .outliers_range - Logical mask marking outliers to be excluded.
%           .overload       - Overload information (count).
%           .fs             - Sampling frequency (Hz).
%           .time_conf      - Time configuration with field 'period'.
%       Properties  - Structure of fit properties (e.g. frequency deviation
%                     settings, initial guesses) produced by
%                     fit_core.get_fit_props.
%       Harm_num    - Number of harmonics to include in the model (if no
%                     overload). If overloaded, this is overridden to 0.
%       Max_points  - Maximum number of data points to use in the fit.
%
%   OUTPUTS
%       Result_1    - Structure with fitted parameters (amplitude, phase,
%                     frequency deviation, harmonics, etc.). Empty if fit
%                     fails.
%       Residuals_1 - Residual vector of the fit.
%       DEBUG_1     - Debug information from the fitting process.
%
%   NOTES
%       * The function calls fit_core.estimation_processing to obtain
%         starting values for the solver.
%       * The frequency deviation flag is set to false in this function
%         (no frequency drift estimated). For two‑channel fitting, a
%         shared frequency deviation is used.
%       * Overload events cause the harmonic number to be set to empty,
%         which is interpreted by fit_core.fit_channel as fitting only the
%         fundamental.
%
%   See also fit_core.estimation_processing, fit_core.fit_channel,
%            fit_core.fit_two_channels, fit_core.get_fit_props.

