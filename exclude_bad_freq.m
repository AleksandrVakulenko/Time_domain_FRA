


% % freq_list = [328.3291  350.9986 373.3524];
% % exclude_list = [308 350 352];
% freq_list = Freq_list;
% exclude_list = Freq_exclude;
% Signal_f = freq_list;
% Bad_harms = exclude_list;
% 
% Diff = (Signal_f - Bad_harms')./repmat(Bad_harms, numel(Signal_f), 1)';
% 
% ind = find(abs(Diff) < 0.03) % FIXME: magic constant
% 
% [~, j] = ind2sub(size(Diff), ind);
% 
% 



function [Bad_num, new_freq_list] = exclude_bad_freq(freq_list, exclude_list)

Signal_f = freq_list;
Bad_harms = exclude_list;

Diff = (Signal_f - Bad_harms')./repmat(Bad_harms, numel(Signal_f), 1)';

ind = find(abs(Diff) < 0.03); % FIXME: magic constant
[~, j] = ind2sub(size(Diff), ind);

Bad_num = unique(j);

new_freq_list = freq_list;
new_freq_list(Bad_num) = [];

end