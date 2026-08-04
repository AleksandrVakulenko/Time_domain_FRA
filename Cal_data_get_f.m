
% TODO:
% 1) add sort if more than one file for each range



function Calibration_set = Cal_data_get_f(Folder)
arguments
    Folder string = './Calibration_matfiles'
end

Files = find_files(Folder);
Calibration_set = [];
for i = 1:numel(Files)
%     disp([num2str(i) '/' num2str(numel(Files))])
    Data = load(Files(i).full_path, "calibration_obj");

    Calibration_set = [Calibration_set Data.calibration_obj];
end

end







