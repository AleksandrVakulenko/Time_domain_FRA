


function [flag, R_sense, Range] = Aster_set_range(Aster, Range)

if Range < 1 || Range > 6
    flag = false;
    R_sense = [];
    Range = [];
else
    flag = true;

    Res_list = [200 10e3 1e6 100e6 10e9 1e12];
    Current_list = 2.5./Res_list;
    Current_pred = Current_list(Range);
    
    I_range_top = Aster.set_sensitivity(Current_pred);
    R_sense = 5/I_range_top;
    R_sense = 1/R_sense;
    
    disp([newline 'Aster range switched to: ' num2str(Range) newline])

    if Range == 5
        disp('Wait 1 sec ...')
        pause(1)
        disp('Ready')
    elseif Range == 6
        disp('Wait 5 sec ...')
        pause(5)
        disp('Ready')
    else
        pause(0.2);
    end

end

end






