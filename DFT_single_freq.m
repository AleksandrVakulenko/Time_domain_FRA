function [Amp, Phi, Mean] = DFT_single_freq(T_arr, V_arr, Freq)
    Period = 1./Freq;
    Length = T_arr(end) - T_arr(1);
    
    % figure
    % hold on
    % plot(T_arr, V_arr, 'xb')
    
    Periods_counter = Length/Period;
    if Periods_counter < 1
        Amp = NaN;
        Phi = NaN;
        Mean = NaN;
        flag = 2;
    elseif Periods_counter < 0.98 % FIXME: magic constant
        flag = 1;
    else
        flag = 0;
    end

    % FIXME: flag unused
    if flag == 0 || flag == 1
        Periods_counter = floor(Periods_counter);
        Length_max = Periods_counter*Period;
        T_max = T_arr(1) + Length_max;
        range = T_arr < T_max;
        T_arr = T_arr(range);
        V_arr = V_arr(range);
        %     plot(T_arr, V_arr, '--r')

        Sin = sin(2*pi*Freq*T_arr);
        Cos = cos(2*pi*Freq*T_arr);

        Sin = V_arr.*Sin;
        Cos = V_arr.*Cos;

        % hold on
        % plot(T_arr, Sin)
        % plot(T_arr, Cos)

        Sin_sum = mean(Sin);
        Cos_sum = mean(Cos);

        Cplx = 1i*Cos_sum + 1*Sin_sum;

        Amp = abs(Cplx)*2;
        Phi = angle(Cplx)/pi*180;
        Mean = mean(V_arr);
    end

end