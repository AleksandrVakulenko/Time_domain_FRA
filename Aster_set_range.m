


function [flag, R_sense, Range] = Aster_set_range(Aster, Range)

if Range < 1 || Range > 6
    flag = false;
    R_sense = [];
    Range = [];
else
    flag = true;

    [R_num, R_time, FB_res] = Aster.get_current_range;
    R_sense = 1/FB_res;

    if R_num ~= Range
        Res_list = [200 10e3 1e6 100e6 10e9 1e12];
        Current_list = 2.5./Res_list;
        Current_pred = Current_list(Range);

        I_range_top = Aster.set_sensitivity(Current_pred);
        R_sense = 5/I_range_top;
        R_sense = 1/R_sense;

        R_time = 0;

        disp([newline 'Aster range switched to: ' num2str(Range) newline])
    end

    if Range == 5
        disp('Wait 1 sec ...')
        pause(1-R_time)
        disp('Ready')
    elseif Range == 6
        disp('Wait 5 sec ...')
        pause(5-R_time)
        disp('Ready')
    else
        pause(0.2);
    end

end

end






