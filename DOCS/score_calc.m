


%SCORE_CALC  Calculate quality scores for two fit results.
%
%   [Score1, Score2, Best_flag, Max_score] = score_calc(Result_1, Result_2, ...
%       Target)
%
%   This function evaluates the quality of two fitted sine‑wave results
%   (e.g. from two channels) relative to a target accuracy specification.
%   It delegates to fit_viewer.score_calc_ch for each result, then
%   determines which channel achieved the maximum score. The maximum
%   possible score is a fixed constant (currently 23) defined in
%   score_calc_ch.
%
%   INPUTS
%       Result_1, Result_2 - Fitting result structures (as produced by
%                            fit_core.fit_channel). Each must contain
%                            fields such as amplitude, phase, harmonics,
%                            etc. If empty, the score is -Inf.
%       Target            - Structure with target accuracy limits:
%           .amp_err_prc   - Target amplitude error in percent.
%           .phi_err_deg   - Target phase error in degrees.
%
%   OUTPUTS
%       Score1, Score2  - Numeric scores for each channel. Higher is
%                         better. Can be negative.
%       Best_flag       - Logical scalar: true if both channels achieved
%                         the same maximum score; false otherwise.
%       Max_score       - The maximum possible score constant (used for
%                         normalization or reference).
%
%   NOTES
%       * The scoring is heuristic and based on error thresholds and the
%         signal‑to‑range ratio. See fit_viewer.score_calc_ch for details.
%       * A result of empty yields a score of -Inf, effectively marking it
%         as unacceptable.
%
%   See also fit_viewer.score_calc_ch, fit_viewer.carrier_error_calc,
%            fit_viewer.get_amp_to_range_ratio.



