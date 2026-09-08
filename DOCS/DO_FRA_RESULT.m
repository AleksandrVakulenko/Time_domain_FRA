

%DO_FRA_RESULT  Compute the final impedance result from two channel fits.
%
%   Result = do_FRA_result(Result_1, Result_2, freq, Range_N)
%   Result = do_FRA_result(Result_1, Result_2, freq, Range_N, R_Scale)
%   Result = do_FRA_result(..., 'Name', Value)
%
%   This function takes the fitted parameters from two channels (typically
%   voltage and current‑converted voltage) and derives the fundamental
%   impedance (resistance and phase) along with error estimates. It
%   optionally applies calibration corrections and includes harmonic
%   information. The output is a structure of type Aster_FRA.LCR_result_type.
%
%   INPUTS
%       Result_1, Result_2 - Fitting result structures from
%                            fit_core.fit_channel. Result_1 is assumed to be
%                            the voltage channel, Result_2 the current
%                            channel (converted via R_Scale).
%       freq              - Measurement frequency (Hz).
%       Range_N           - Range number used for the measurement (to obtain
%                           default R_Scale and calibration).
%       R_Scale           - (Optional) Scale resistor value in Ohms.
%                           If omitted, it is computed from Range_N using
%                           Aster_r_scale.
%       options           - Name‑value pairs:
%           'calibration_set' - Calibration set identifier (passed to
%                               Aster_FRA.apply_calibration).
%           'disp_flag'       - 'on' (default) or 'off'. If 'on', prints
%                               results to the console.
%           'use_correction'  - 'both' (default), 'on', '1st', 'none',
%                               'off', or 'both'. Determines whether
%                               calibration and instrument error corrections
%                               are applied.
%
%   OUTPUTS
%       Result  - Structure of type Aster_FRA.LCR_result_type containing:
%           .freq, .gen_amp, .gen_dc - Frequency and generator settings.
%           .res_abs, .res_abs_err   - Impedance magnitude (Ohm) and error.
%           .phi, .phi_err           - Phase difference (degrees) and error.
%           .harm                    - Array of harmonic results (impedance
%                                      and phase for each harmonic present).
%           .cap_par, .r_scale       - Parallel capacitance and scale resistor.
%           .current, .current_error, .voltage, .voltage_error - (Placeholders,
%                                      often empty).
%           .range_n                 - Range number used.
%
%   NOTES
%       * The function uses fit_viewer.calc_output to extract amplitude,
%         phase, and their errors from each fit result.
%       * It adds extra errors based on signal‑to‑range ratio using
%         experimentally derived functions (Section A00 in code).
%       * Calibration corrections are applied only if use_correction is
%         not 'none' or 'off'.
%       * The output includes parallel and series RC equivalent values.
%       * Harmonic results are computed only for channel 2 (current) and
%         then cleaned of NaN/empty entries.
%
%   See also Aster_FRA.apply_calibration, Aster_FRA.get_instr_errors,
%            fit_viewer.calc_output, fit_viewer.RC_calc_parallel,
%            fit_viewer.RC_calc_series.


