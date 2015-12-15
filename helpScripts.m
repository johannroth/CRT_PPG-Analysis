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
                    Metadata.heartRate(iPatient), ...
                    true);
%% ########## Initialize test2 + plot
[test2,~, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Metadata.heartRate(iPatient), iPatient);

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
title(['Pt0' num2str(iPatient)]);
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
title(['Pt0' num2str(iPatient)]);
%% plot of all beats overlayed test
figure;
plot(test);
title(['Pt0' num2str(iPatient)]);
%% plot of calculated mean beat test + test2
figure;
subplot(2,1,1);
plot (mean(test,2));
title(['Pt0' num2str(iPatient)]);
subplot(2,1,2);
plot (mean(test2,2));
title(['Pt0' num2str(iPatient)]);
%% plot of calculated median beat test
figure;
plot(median(test,2));
title(['Pt0' num2str(iPatient)]);

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



%% initialize data to test extractModeChangeBeats script after running main
patientId = ['Pt0' num2str(iPatient)];
ModeAV = Results.(patientId).AV;
ModeVV = Results.(patientId).VV;
AV = ModeAV;
VV = ModeVV;
MAXBEATS = 8;
EXCLUDEBEATS = 2;
heartRate = Metadata.heartRate(iPatient);
rrInterval = 60/heartRate;
fs = Data.fs;
%% run test analysis for beat extraction
iChange = 1;
iInterval = 1;
%%
firstPossibleSample = AV.FromRef.stamps(iChange, iInterval) + ...
                      rrInterval*EXCLUDEBEATS*fs;
lastPossibleSample = AV.FromRef.stamps(iChange, iInterval) + ...
                     (MAXBEATS)*rrInterval*fs;                 
                 
detectionMask = logical( ...
    (Data.BeatDetections.Merged.samplestamp > firstPossibleSample) .* ...
    (Data.BeatDetections.Merged.samplestamp < lastPossibleSample)...
                );
detections = Data.BeatDetections.Merged.samplestamp(detectionMask);
while length(detections) > MAXBEATS-EXCLUDEBEATS
    detections = detections(1:end-1);
end

currentSignal = {'PpgClip'};

includedBeats = extractBeats(Data.Signals.(char(currentSignal)).data,...
                         detections,...
                         fs,...
                         heartRate,...
                         true);
[includedGoodBeats, quality] = extractGoodBeats(includedBeats, fs, heartRate, iPatient);
%% extractModes test: plot AV and VV.fromRef vs Stimulation mode in data
figure;
plot(Results.(['Pt0' num2str(iPatient)]).AV.FromRef.stamps',Results.(['Pt0' num2str(iPatient)]).AV.interval, 'cs');
hold on;
plot(Results.(['Pt0' num2str(iPatient)]).AV.ToRef.stamps',Results.(['Pt0' num2str(iPatient)]).AV.interval, 'co');
stairs(Data.StimulationModes.AV.samplestamp, Data.StimulationModes.AV.value);
plot(Results.(['Pt0' num2str(iPatient)]).VV.FromRef.stamps',Results.(['Pt0' num2str(iPatient)]).VV.interval, 'ms');
plot(Results.(['Pt0' num2str(iPatient)]).VV.ToRef.stamps',Results.(['Pt0' num2str(iPatient)]).VV.interval, 'mo');
stairs(Data.StimulationModes.VV.samplestamp, Data.StimulationModes.VV.value);

plot(firstPossibleSample,40,'r*');
plot(lastPossibleSample,40,'r*');
plot(detections,Data.Signals.PpgClip.data(detections),'rs');
plot(Data.Signals.PpgClip.data, 'k:');



%% test to put matrices in cell arrays
testCellArray = cell(3,5);
testMatrix = magic(4);
testCellArray{1,1} = magic(4);
% get frist element of first matrix
testCellArray{1,1}(1,1);
%% test for loop
testTarget1 = [1 2 3];
testTarget2 = [4 5 6];
for loopTarget = [{'testTarget1'},{'testTarget2'}]
    if strcmp(loopTarget, 'testTarget2')
        fprintf([char(loopTarget) '\n']);
    end
    switch char(loopTarget)
        case 'testTarget2'
            fprintf([char(loopTarget) '\n']);
        case 'testTarget1'
            fprintf([char(loopTarget) '\n']);
        otherwise
            fprintf('Error');
    end
end
%% test
testQuality = Results.Pt06.AV.FromRef.PpgClip.quality(:,1,:);
test = cell2mat(testQuality(:));
plot(Results.Pt06.AV.FromRef.PpgClip.quality{1,1,2})
%% test for invisible plotting
qualityPlot = figure('Visible','off');
plot(1:100)
set(qualityPlot, 'visible', 'on')
close(qualityPlot)
% saveas(gcf,'file.fig','fig')
% 
% openfig('file.fig','new','visible')

%% test for folders in working directory
try
    testfunction;
catch
    fprintf('first try failed');
end
addpath('testfolder');
testfunction;
rmpath('testfolder');
try
    testfunction;
catch
    fprintf('second try failed');
end


%% test for quality plots
% AV + VV plots. each ~10 intervals, 6 changes (3 fromRef, 3 toRef),
% before/after change each = 10*6*2 = 120 plots
% Organisation of subplots:
%   Rows: contain beats from certain intervals
%   Columns contain the 12
%
% beats{change, before/after, interval}
figure;
subplot(2,1,1);
testBeat = Results.Pt06.AV.FromRef.PpgClip.beats{1,1,1};
fs = Data.fs;
t = 0:1/fs:(length(testBeat)-1)/fs;
testBeatMean = mean(testBeat,2);
testBeatSd = std(testBeat,0,2);
errorbar(t(1:2:end),testBeatMean(1:2:end),testBeatSd(1:2:end));
axis([0,0.7,-inf,inf]);
quality = Results.Pt06.AV.FromRef.PpgClip.quality(1,1,1);
text(t(end)*0.9,max(testBeatMean)*0.9, {['Q = ' num2str(quality)], 'test'} , 'HorizontalAlignment','right');
ax = gca;
ax.XAxis.Visibility = 'off';

subplot(2,1,2);
testBeat = Results.Pt06.AV.FromRef.PpgClip.beats{2,2,4};
fs = Data.fs;
t = 0:1/fs:(length(testBeat)-1)/fs;
testBeatMean = mean(testBeat,2);
testBeatSd = std(testBeat,0,2);
errorbar(t(1:2:end),testBeatMean(1:2:end),testBeatSd(1:2:end));
axis([0,0.7,-inf,inf]);
quality = Results.Pt06.AV.FromRef.PpgClip.quality(2,2,4);
text(t(end)*0.9,max(testBeatMean)*0.9, ['Q = ' num2str(quality)] , 'HorizontalAlignment','right');

%% get a beat from results struct

beats = Results.(patientId).AV.ToRef.PpgCuff.beats{ ...
                                             1, ... % change (1...3)
                                             2, ... % position (1... before, 2... after)
                                             1 ...  % interval (1...x)
                                            };              % ( x = length(Results.(patientId).(stimMode).interval ))
figure();
plot(beats, 'k:');
hold on;
plot(mean(beats,2),'g-');
hold on;
plot(median(beats,2),'r-');

figure2 = figure();
set(groot,'CurrentFigure',figure1);
plot(1:100);

%% Get minimum quality (to check if all beats have been excluded at least once)
stimModes = [{'AV'},{'VV'}];
directions = [{'FromRef'},{'ToRef'}];
positions = [{'beforeChange'},{'afterChange'}];
signals = [{'PpgClip'},{'PpgCuff'}];
quality = [];
for i = 1:length(patient)
    id = ['Pt0' num2str(patient(i))];
    for currentMode = stimModes
        for currentDirection = directions
            for currentSignal = signals
                if isempty(quality)
                    quality = Results.(char(id)).(char(currentMode)).(char(currentDirection)).(char(currentSignal)).quality(:);
                else
                    quality = [ quality; Results.(char(id)).(char(currentMode)).(char(currentDirection)).(char(currentSignal)).quality(:)];
                end
            end
        end
    end
end
min(quality), mean(quality)
figure;
plot(sort(quality));
hold on;
plot(1:length(quality),ones(1,length(quality)).*mean(quality));


                
                
                
                
%% test to get all qualities
beats = Results.(patientId).AV.ToRef.PpgCuff.quality{ ...
                                             1, ... % change (1...3)
                                             2, ... % position (1... before, 2... after)
                                             1 ...  % interval (1...x)
                                            };
beats(:)


%% remove all beats from results
stimModes = [{'AV'},{'VV'}];
directions = [{'FromRef'},{'ToRef'}];
positions = [{'beforeChange'},{'afterChange'}];
signals = [{'PpgClip'},{'PpgCuff'}];
quality = [];
for i = 1:length(patient)
    id = ['Pt0' num2str(patient(i))];
    for currentMode = stimModes
        for currentDirection = directions
            for currentSignal = signals
                ResultsShort.(char(id)).(char(currentMode)).(char(currentDirection)).(char(currentSignal)).beats = [];
            end
        end
    end
end



%% DEbug for getPulseWidth

%% DEBUG
beat = Results.Pt02.AV.ToRef.PpgCuff.meanBeat{1,1,3};
fs = 200;
t = 0:1/fs:(length(beat)-1)/fs;
plot(t,beat);
hold on;
stairs(t,beat,'c-');
plot(t(firstPass), beat(firstPass),'bo');
plot(t(lastPass), beat(lastPass),'ro');
plot(t, ones(1,length(t)).*beatMax/2 ,'k:');


%% test ableitung

% beat = Results.Pt02.AV.ToRef.PpgCuff.meanBeat{3,2,1}; % nice beat with dias max
beat = Results.Pt02.AV.ToRef.PpgCuff.meanBeat{3,2,2}; % beat with no 2nd max
% beat = Results.Pt03.AV.FromRef.PpgCuff.meanBeat{3,2,2}; % ugly beat

df = designfilt('differentiatorfir','FilterOrder',20,...
                'PassbandFrequency',20,'StopbandFrequency',30,...
                'SampleRate',200);
% hfvt = fvtool(df,[1 -1],1,'MagnitudeDisplay','zero-phase','Fs',200);
% legend(hfvt,'50th order FIR differentiator','Response of diff function');

D = mean(grpdelay(df)); % filter delay
slope = filter(df,[beat; zeros(D,1)]);
slope = slope(D+1:end);

% slope = getDerivative(beat);
% curvature = getDerivative(slope);

figure;
plot(beat);
hold on;
plot(slope*10,'r-');
plot(1:length(beat),zeros(1,length(beat)),'k:');

t1 = slope(1:end-1);
t2 = slope(2:end);
tt = t1.*t2;
zeroPassings = find(tt < 0);
plot(zeroPassings, beat(zeroPassings),'ro');





%%
fs = 200;
t = 0:1/fs:(length(beat)-1)/fs;
figure;
stairs(t,beat);
hold on;
beat400 = interp(beat,2);
t400 = 0:1/400:(length(beat400)-1)/400;
stairs(t400,beat400);
[beatDerivative, beatDerivative2] = getDerivatives( beat );

beat = beat400;
fs = 400;
t = t400;

stairs(t,20*beatDerivative);

plot(t,zeros(1,length(t)),'k:');

% % fir_order = 9; % uneven order required!
% % if mod(fir_order,2)==1 % is odd
% %     m=fix((fir_order-1)/2);
% %     h=[-ones(1,m) 0 ones(1,m)]/m/(m+1);
% % else % is even
% %     m=fix(fir_order/2);
% %     h=[-ones(1,m) ones(1,m)]/m^2;
% % end
% % D = mean(grpdelay(h));
% fir_order = 4; % uneven order required!
%     h=[-ones(1,fir_order) 0 ones(1,fir_order)]/fir_order/(fir_order+1);
%     D = mean(grpdelay(h));
% %%
% beatDerivative = filter(-h,1,[beat; zeros(D,1)]);
% beatDerivative = beatDerivative(D+1:end);

% 
% fir_order = 31; % uneven order required!
% if mod(fir_order,2)==1 % is odd
%     m=fix((fir_order-1)/2);
%     h=[-ones(1,m) 0 ones(1,m)]/m/(m+1);
% else % is even
%     m=fix(fir_order/2);
%     h=[-ones(1,m) ones(1,m)]/m^2;
% end
% D = mean(grpdelay(h));
% beat2ndDerivative = filter(-h,1,[beatDerivative; zeros(D,1)]);
% beat2ndDerivative = beat2ndDerivative(D+1:end);


beat = Results.Pt05.VV.ToRef.PpgCuff.meanBeat{2,2,3};
slope = getDerivative(beat);
getIPA(beat, slope, 200);



