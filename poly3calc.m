
function y = poly3calc(poly, x)
    y1 = poly.p1;
    y2 = poly.p2;
    y3 = poly.p3;

    if ~isnan(y1) && ~isnan(y2)
        xf = poly.x;
        yf = [y1 y2 y3];
        fitres = fit(xf', yf', 'poly2');
        y = feval(fitres, x);
    elseif ~isnan(y2)
        xf = [poly.x(1) poly.x(3)];
        yf = [y2 y3];
        fitres = fit(xf', yf', 'poly1');
        y = feval(fitres, x);
    else
        y = repmat(y3, 1, numel(x));
    end

    y = reshape(y, 1, numel(y));
end