function [Bad_flag, Bad_freq, Bad_harm_num] = find_bad_freq(freq)

Signal_harms = [1:10]*freq;
Noise_harms = [1:20]*50;

Diff = (Signal_harms - Noise_harms')./repmat(Noise_harms, numel(Signal_harms), 1)';

ind = find(abs(Diff) < 0.03); % FIXME: magic constant
[~, j] = ind2sub(size(Diff), ind);

j = unique(j);

Bad_freq = Signal_harms(j);
Bad_harm_num = round(Signal_harms(j)/freq);

% Diff = Diff./round(Diff);
Bad_flag = any(Bad_harm_num == 1);
end