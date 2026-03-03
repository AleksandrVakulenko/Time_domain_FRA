




x = 0:0.01:1000;

PP1 = ones(size(x))*0;
PP2 = ones(size(x))*50;
PP3 = (PP2(end)-PP1(1))*x/(x(end)-x(1)) + PP1(1);

% plot(x, PP3)

Freq = 0.01;

y1 = sin(2*pi*Freq*x + PP1/180*pi);
y2 = sin(2*pi*Freq*x + PP2/180*pi);
y3 = sin(2*pi*Freq*x + PP3/180*pi);

figure
hold on
plot(x, y1, '-b')
plot(x, y2, '-r')
plot(x, y3, '-k')




