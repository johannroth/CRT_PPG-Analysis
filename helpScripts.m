clearvars -except Data iPatient;

%% plot PpgClip.data + beatDetections (plot + stairs)
figure;
plot(Data.Signals.PpgClip.data);
hold on;
plot(Data.BeatDetections.BsBp.samplestamp, Data.Signals.Bp.data(Data.BeatDetections.BsBp.samplestamp),'c*');

stairs(Data.Signals.Bp.data);


%% Plot for waveform comparison of extracted beats

%% Define range of samples to plot
% default for stamps: 100:109
stamp = Data.BeatDetections.Merged.samplestamp;

% use this mask to select a specific part of the signal
        startSecond = 830; % artifact in pt2
        stopSecond = 840;
samplestampmask = logical((stamp > startSecond*1000/5) .* (stamp < stopSecond*1000/5));

%% ########## Initialize test
test = extractBeats(Data.Signals.PpgCuff.data, ...
                    Data.BeatDetections.Merged.samplestamp(samplestampmask), ...
                    Data.Signals.PpgClip.fs, ...
                    Data.Metadata.heartRate(iPatient), ...
                    true);
%% ########## Initialize test2 + plot
[test2, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Data.Metadata.heartRate(iPatient), iPatient);

%% 3d plot of beats test2 (without excluded beats)
t = 0 : 1/Data.Signals.Bp.fs : (size(test2,1)-1)/Data.Signals.Bp.fs;
figure;
for i = 1:size(test2,2)
    plot3(t,i*ones(size(t)),test2(:,i),'k-');
    hold on;
end
view(60,30);
xlabel('Time [s]');
ylabel('Beat number');
zlabel('Amplitude [a.u.]');
grid on;
title(['Pt' num2str(iPatient)]);
%% 3d plot of beats test
t = 0 : 1/Data.Signals.Bp.fs : (size(test,1)-1)/Data.Signals.Bp.fs;
figure;
for i = 1:size(test,2)
    plot3(t,i*ones(size(t)),test(:,i),'k-');
    hold on;
end
view(60,30);
xlabel('Time [s]');
ylabel('Beat number');
zlabel('Amplitude [a.u.]');
grid on;
title(['Pt' num2str(iPatient)]);
%% plot of all beats overlayed test
figure;
plot(test);
title(['Pt' num2str(iPatient)]);
%% plot of calculated mean beat test + test2
figure;
subplot(2,1,1);
plot (mean(test,2));
title(['Pt' num2str(iPatient)]);
subplot(2,1,2);
plot (mean(test2,2));
title(['Pt' num2str(iPatient)]);
%% plot of calculated median beat test
figure;
plot(median(test,2));
title(['Pt' num2str(iPatient)]);

%% errorbar plot test2
figure;
m = mean(test2,2);
sd = std(test,0,2);
errorbar(m(1:2:end),sd(1:2:end));
title(['Pt' num2str(iPatient) ' raw']);
%% ########## compressed errorbar plot test + test2
figure;
subplot(2,1,1);
m = mean(test,2);
sd = std(test,0,2);
errorbar(m(1:2:end),sd(1:2:end));
title(['Pt' num2str(iPatient) ' raw']);
subplot(2,1,2);
m = mean(test2,2);
sd = std(test2,0,2);
errorbar(m(1:2:end),sd(1:2:end));
title(['Pt' num2str(iPatient) ' filtered']);
%% boxplot test2
figure;
boxplot(test2');

%% plot PpgClip.data
plot(Data.Signals.PpgClip.data);

%% plot showing median and 25%/75% quantiles
figure;
plot(test, 'g-');
hold on;
plot(quantile(test,0.75,2), 'b:');
plot(quantile(test,0.25,2), 'b:');
plot(quantile(test,0.75,2)+(quantile(test,0.75,2)-quantile(test,0.25,2)).*1.5, 'r:');
plot(quantile(test,0.25,2)-(quantile(test,0.75,2)-quantile(test,0.25,2)).*1.5, 'r:');
plot(median(test,2), 'k-');

mean(test(:,4) < quantile(test,0.25,2) - (quantile(test,0.75,2)-quantile(test,0.25,2)).*1.5);

%% Test for removal of single columns of a matrix
testBeats = [10 20 30 40 50;11 21 31 41 51; 12 22 32 42 52];
testGoodBeat = [1 0 3 4 0];
testGoodBeat(testGoodBeat == 0) = [];
testGoodBeats = testBeats(:,testGoodBeat);

%% example plot stimulation mode as stairs
stairs(Data.StimulationModes.AV.samplestamp, Data.StimulationModes.AV.value);


%% extractModes test: plot AV and VV.fromRef vs Stimulation mode in data
figure;
plot(AV.fromRef',AV.interval, 'cs');
hold on;
plot(AV.toRef',AV.interval, 'co');
stairs(Data.StimulationModes.AV.samplestamp, Data.StimulationModes.AV.value);
plot(VV.fromRef',VV.interval, 'ms');
plot(VV.toRef',VV.interval, 'mo');
stairs(Data.StimulationModes.VV.samplestamp, Data.StimulationModes.VV.value);