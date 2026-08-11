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