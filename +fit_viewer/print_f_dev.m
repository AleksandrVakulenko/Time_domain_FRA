function print_f_dev(f_dev, f_dev_err)
    disp(['Δf = ' num2str(f_dev, '%0.1f') ' ± ' ...
        num2str(f_dev_err, '%0.1f') ' ppm'])
end