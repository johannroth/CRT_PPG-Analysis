test1 = magic(4);
figure;
imagesc(test1);

xLabels = {
    'Pt 1'
    'Pt 2'
    'Pt 3'
    'Pt 4'};
set(gca,'XtickLabel', listParameters(1:4));
set(gca,'XTick', 1:4);