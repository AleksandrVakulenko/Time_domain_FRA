
clc

x1 = 0;
x3 = 6;
x2 = (x1 + x3)/2;

y1 = 2;
y2 = 4;
y3 = 3;

x = linspace(x1 - 2, x3 + 2, 1000);

% y = y1*(x-x2).*(x-x3)/(x1-x2)/(x1-x3) + y2*(x-x1).*(x-x3)/(x2-x1)/(x2-x3) + y3*(x-x1).*(x-x2)/(x3-x1)/(x3-x2);


Period = 1;


[Eq1, Type] = func_constructor([x1 x2], 'a', Period)


switch Type
    case "const"
%         y = feval(ft, y1, x);
        y = 0;
    case "linear"
        ft = fittype(Eq1, 'independent', 'x');
        y = feval(ft, y1, y2, x);
    case "poly2"
        ft = fittype(Eq1, 'independent', 'x');
        y = feval(ft, y1, y2, y3, x);
    otherwise
        error('unreachable')
end


figure
hold on
plot(x, y)
plot([x1 x2 x3], [y1 y2 y3], '.r', 'MarkerSize', 12)



%%







