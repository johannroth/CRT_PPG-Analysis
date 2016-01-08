cMode = 'AV';
patientId = 'Pt04';
cParameter = 'pulseHeight';
cSignal = 'PpgCuff';

fromRefScatterplotData = Results.(patientId).(cMode).FromRef.(cSignal).ScatterplotData.(cParameter);
toRefScatterplotData = Results.(patientId).(cMode).ToRef.(cSignal).ScatterplotData.(cParameter);
scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
x = scatterplotData(:,1);
y = scatterplotData(:,3);
[xR,yR,RS,~] = calculateRegression(x,y);
figure;
stairs(xR,yR);

[maxChange,  iMax] = max(yR);
[minChange, iMin] = min(yR);
cChangeSpan = (maxChange - minChange)*100;
hold on;
plot(xR(iMax),maxChange,'ro');
plot(xR(iMin),minChange,'go');
fprintf([num2str(cChangeSpan) '\n']);