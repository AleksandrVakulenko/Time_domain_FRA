
% NOTE: now it is a part of +Aster_FRA

% FIXME: upgrade and put in some Fern module

function print_error_msg(ERR)
    Stack = ERR.stack;
    klog.disp(['Error in Aster_FRA.measure function:' newline ...
        '> ' ERR.message ' <'], "common", 'orange');
    for i = 1:numel(Stack)
        disp(' ')
        klog.disp(['File: ' char(Stack(i).file) newline ...
            'Func: ' Stack(i).name newline ...
            'Line: ' num2str(Stack(i).line)], "common", "orange");
    end
    disp(' ')
end


%% TEST

% clc
% 
% nyan
% disp('safsdfad')
% 
% 
% 
% function nyan()
% try
%     nyan2()
% catch ERR
%     Aster_FRA_helper.print_error_msg(ERR)
% end
% 
% 
% end
% 
% 
% 
% function nyan2()
% 
%     A = [1 2 3];
%     A(-2);
% end
