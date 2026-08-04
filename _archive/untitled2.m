
% NOTE: something about phi shift for any_sin_fit

clc

Value = Median([1 2 3 10 11 -1000 -1000])



%%

clc

Est_phi = -[120 174 179 172 175 -177]
% Est_phi = [2 1 3 5 -4 -3]

Est_time = 1:numel(Est_phi);

Est_time_der = Est_time(2:end);
Est_phi_der = diff(Est_phi);

Range = Est_phi_der < -180;
Est_phi([false Range]) = Est_phi([false Range]) + 360;

Range = Est_phi_der > 180;
Est_phi([false Range]) = Est_phi([false Range]) - 360;

plot(Est_time, Est_phi)
% plot(Est_time_der, Est_phi_der)








%%
clc

Est_time = 0;

Est_phi = [17 174 179 172 175 -177]

Est_phi = Phi_est_shift(Est_time, Est_phi)



function Est_phi = Phi_est_shift(Est_time, Est_phi)


[phi_range_pos, Mean_pos, Span_pos] = get_range_and_stats(Est_phi, "pos");
[phi_range_neg, Mean_neg, Span_neg] = get_range_and_stats(Est_phi, "neg");

if isempty(Span_pos) || isempty(Span_neg)
    return;
end

Max_side_span = 30;
if Span_pos > Max_side_span
    Est_phi(phi_range_pos) = Median(Est_phi(phi_range_pos))
end

if Span_neg > Max_side_span
    error('Error 8002');
end

if Mean_neg < -170 && Mean_pos > 170
    if ~isempty(phi_range_neg)
        % NOTE: this code fixes Phi array in case of somthing like this:
        % [179.2 179.8 -179.8 178.7]
        % then mean() and fit() could no work on 180[deg] crossover
        Min_phi = min(Est_phi);
        Phi_shift = ceil(abs(Min_phi)/360)*360;
        Est_phi(phi_range_neg) = Est_phi(phi_range_neg) + Phi_shift;
    end
else
    warning('Error 8003');
end



end



function [Range, Mean, Span] = get_range_and_stats(Est_phi, side)
arguments
    Est_phi
    side {mustBeMember(side, ["pos", "neg"])}
end

if side == "pos"
    Range = Est_phi >= 0;
else
    Range = Est_phi < 0;
end

Mean = mean(Est_phi(Range));
Max = max(Est_phi(Range));
Min = min(Est_phi(Range));
Span = abs(Max-Min);

end


function Value = Median(Arr)
N = numel(Arr);
if N == 1
    Value = Arr;
elseif N == 2
    Value = mean(Arr);
else
    Arr = sort(Arr);
    if rem(N, 2) == 1
        ind = floor(N/2)+1;
        Value = Arr(ind);
    else
        ind = floor(N/2);
        Value = mean([Arr(ind) Arr(ind+1)]);
    end
end

end






