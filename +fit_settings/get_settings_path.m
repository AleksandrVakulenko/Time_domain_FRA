function Path = get_settings_path()
Path = which("fit_settings.get_settings_path");
ind = strfind(Path, "get_settings_path.m");
Path = char(Path);
Path = Path(1:ind-1);
end