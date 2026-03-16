
clc


figure('position', [44 506 560 420])
RUN_TEST(1)

figure('position', [636 501 560 420])
RUN_TEST(2)

figure('position', [1236 500 560 420])
RUN_TEST(3)



function RUN_TEST(Value)

x1 = 0;
x3 = 6;
x2 = (x1 + x3)/2;

y1 = 2;
y2 = 4;
y3 = 3;

x = linspace(x1 - 2, x3 + 2, 1000);

switch Value
    case 1
        [Eq1, Type] = fit_helper.func_constructor([x1], 'a');
        title('no params')
    case 2
        [Eq1, Type] = fit_helper.func_constructor([x1 x2], 'a');
        title('2 point line')
    case 3
        [Eq1, Type] = fit_helper.func_constructor([x1 x2 x3], 'a');
        title('3 point ploy2')
    otherwise
        error('Wrong Value')
end



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

hold on
plot(x, y)
plot([x1 x2 x3], [y1 y2 y3], '.r', 'MarkerSize', 12)

end







