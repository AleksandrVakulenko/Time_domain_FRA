

%INIT_GATHER_AXES  Prepare a two‑axes layout for real‑time plotting.
%
%   Axes_arr = init_gather_axes(Fig_or_ax1)
%   Axes_arr = init_gather_axes(Fig_or_ax1, ax2)
%
%   This function returns a 1×2 array of axes handles suitable for plotting
%   the two channels during data gathering. It accepts either a figure
%   handle (in which case it ensures the figure contains exactly two axes
%   in a vertical stack, creating them if needed) or an explicit pair of
%   axes handles. If the input is invalid or empty, it returns [].
%
%   INPUTS
%       Fig_or_ax1 - Can be:
%                    * A matlab.ui.Figure handle. The function checks its
%                      children; if not exactly two axes, it deletes all
%                      children and creates two new subplots (2×1).
%                    * A 1×2 array of matlab.graphics.axis.Axes handles.
%                    * A single axes handle combined with a second axes
%                      handle (ax2).
%       ax2        - (Optional) Second axes handle. Only used if Fig_or_ax1
%                    is a single axes handle.
%
%   OUTPUTS
%       Axes_arr   - 1×2 array of axes handles, sorted with the top axes
%                    first. If no valid axes can be determined, returns [].
%
%   NOTES
%       * When creating axes from a figure, the function sets grid and
%         minor grid, box on, and holds on.
%       * The sorting of existing axes is based on their vertical position
%         (descending y).
%       * The function is intended for internal use by the measurement and
%         fitting routines to ensure consistent plotting.
%
%   See also fit_viewer.data_gather_plot, subplot.



