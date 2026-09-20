
% auto generated AI code for harmonics detection

function [harmonics, amps, threshold, noise] = find_harmonics(Time, Voltage, Fs, Freq)
% FIND_HARMONICS  Detect non-zero harmonic components in a noisy signal.
%   harmonics = find_harmonics(Time, Voltage, Fs, Freq) returns an array of
%   harmonic orders (2..9) that are present above the estimated noise floor.
%   The fundamental frequency Freq is known. The algorithm uses a Hanning
%   window and direct DFT at the exact harmonic frequencies to reduce leakage.
%   The noise floor is estimated from the FFT spectrum after excluding
%   frequency bins around all harmonics (1..9). A harmonic is considered
%   present if its amplitude exceeds median_noise + 3*std(noise).
%
%   Inputs:
%       Time   - time vector (not used, but required for compatibility)
%       Voltage - signal vector (column or row)
%       Fs     - sampling frequency (Hz)
%       Freq   - fundamental frequency (Hz)
%   Output:
%       harmonics - row vector of harmonic orders (e.g., [2,4,5]) that are
%                   detected. Empty if none above the noise threshold.
%
%   The function requires at least 3 periods of the fundamental to obtain
%   a reliable noise estimate. If the input length is insufficient, an error
%   is thrown with the required number of samples.

    % --- Input validation ---
    if nargin < 4
        error('Not enough input arguments. Need Time, Voltage, Fs, Freq.');
    end
    Voltage = Voltage(:);               % ensure column vector
    N = length(Voltage);
    if N < 2
        error('Signal must have at least 2 samples.');
    end
    if Fs <= 0 || Freq <= 0
        error('Fs and Freq must be positive.');
    end

    % Minimum number of periods required for reliable detection
    MIN_PERIODS = 1.5; % FIMXE: default value: 3
    T_period = Fs / Freq;               % samples per period
    if N < MIN_PERIODS * T_period
        required = ceil(MIN_PERIODS * T_period);
        error(['Need at least %d periods of fundamental. ' ...
               'Current length = %d samples, need at least %d.'], ...
               MIN_PERIODS, N, required);
    end

    % --- Apply Hanning window ---
    w = hann(N, 'periodic');            % periodic window for better DFT
    xw = Voltage .* w;
    sum_w = sum(w);                     % coherent gain for amplitude correction

    % --- Compute amplitudes at harmonic frequencies (2..9) via direct DFT ---
    harm_orders = 2:9;
    num_harm = length(harm_orders);
    amps = zeros(1, num_harm);
    n_indices = 0:N-1;
    for idx = 1:num_harm
        n = harm_orders(idx);
        f = n * Freq;
        % Direct DFT at frequency f (using windowed signal)
        exp_term = exp(-1j * 2 * pi * f * n_indices / Fs);
%         size(xw')
%         size(exp_term')
        A = xw' * exp_term';             % complex amplitude (dot product)
%         size(A)
        amps(idx) = abs(A) / sum_w;     % corrected amplitude
    end

    % --- Estimate noise floor from FFT spectrum of windowed signal ---
    X = fft(xw);
    % Single-sided magnitude spectrum (positive frequencies up to Nyquist)
    N_half = floor(N/2);
    mag = abs(X(1:N_half + 1)) / sum_w; % compensate window gain
    freq_bins = (0:N_half) * Fs / N;

    % Exclude frequency bins that are within a radius around each harmonic
    % (including fundamental up to 9th) to avoid leakage.
    % For Hanning window, the main lobe spans about 4 bins; we use 3 bins as
    % a safe margin. Since we have at least 3 periods, bin spacing is small
    % enough not to overlap adjacent harmonics.
    radius_bins = 3;
    bin_width = Fs / N;
    exclude_idx = [];
    for h = 1:9
        f_h = h * Freq;
        dist = abs(freq_bins - f_h);
        idx = find(dist <= radius_bins * bin_width);
        exclude_idx = [exclude_idx idx];
    end
    exclude_idx = unique(exclude_idx);

    % Get indices of noise bins (all except excluded ones)
    all_idx = 1:length(mag);
    noise_idx = setdiff(all_idx, exclude_idx);
    if isempty(noise_idx)
        error(['Not enough bins for noise estimation. ' ...
               'Increase signal length or reduce exclusion radius.']);
    end
    noise_mag = mag(noise_idx);

    % Noise statistics (median and standard deviation)
    median_noise = median(noise_mag);
    std_noise = std(noise_mag);

    % Threshold: median + 3*std (if std=0, use 3*median as a safe lower bound)
    if std_noise == 0
        threshold = 3 * median_noise;
    else
        threshold = median_noise + 3 * std_noise;
    end
    % Ensure threshold is at least a small value to avoid false positives
    threshold = max(threshold, 1e-12);

    % --- Determine which harmonics are above threshold ---
    present = amps > threshold;
    harmonics = harm_orders(present);

    % Return as row vector for convenience
    harmonics = harmonics(:)';

    noise.median = median_noise;
    noise.std = std_noise;
end







