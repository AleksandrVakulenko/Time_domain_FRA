function Value = get_value(Filed_name)
Path = TDFRA_fit_settings.get_settings_path();
Filename = fullfile([char(Path) '/../' 'Settings.json']);
Data = TDFRA_fit_settings.read_json_file(Filename);
fields = fieldnames(Data);
if ~any(fields == Filed_name)
    % FIXME: replace file by default
end
Value = Data.(Filed_name);
end