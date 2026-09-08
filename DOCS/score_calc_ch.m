

%SCORE_CALC_CH  Compute a quality score for a single fit result.
%
%   [Score, max_score] = score_calc_ch(Result, Target)
%
%   This function implements a heuristic scoring system that evaluates how
%   well a fitted sine‑wave result meets a target accuracy specification.
%   The score is based on the relative errors of the carrier amplitude,
%   carrier phase, and a constant (DC) term, as well as a bonus depending on
%   the amplitude‑to‑range ratio. The maximum achievable score is 23
%   (hard‑coded). A result that is empty yields -Inf.
%
%   INPUTS
%       Result  - Fitting result structure containing at least:
%           .amp_poly   - Polynomial coefficients for amplitude vs time.
%           .phi        - Carrier phase (degrees).
%           .amp_err_prc, .phi_err_deg, .const_err_prc (or similar fields
%                         obtained via fit_viewer.carrier_error_calc).
%                 (The function internally calls carrier_error_calc.)
%       Target  - Structure with target accuracy limits:
%           .amp_err_prc - Target amplitude error in percent.
%           .phi_err_deg - Target phase error in degrees.
%
%   OUTPUTS
%       Score       - Numeric score (can be negative). Higher is better.
%       max_score   - The constant maximum possible score (23).
%
%   NOTES
%       * The scoring thresholds are magic numbers tuned experimentally.
%       * The amplitude‑to‑range ratio is computed using the mean fitted
%         amplitude over the measurement window divided by a fixed maximum
%         voltage (10 V). It rewards measurements that use a larger fraction
%         of the input range.
%       * The function assumes a maximum input voltage of 10 V.
%
%   See also fit_viewer.carrier_error_calc, fit_viewer.score_calc,
%            fit_viewer.poly3calc.



