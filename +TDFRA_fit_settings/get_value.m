function Value = get_value(Filed_name)
Path = TDFRA_fit_settings.get_settings_path();
Filename = fullfile([char(Path) '/../' 'Settings.json']);
Data = TDFRA_fit_settings.read_json_file(Filename);
fields = fieldnames(Data);
if ~any(fields == Filed_name)
    % FIXME: (3) replace file by default settings for this case
end
Value = Data.(Filed_name);
end