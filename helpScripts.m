% clearvars -except Data patient;

% test = detectedBeats( Data, patient );
figure;
plot(Beat.bp, 0,'b*');
hold on;
plot(Beat.cuff, 1, 'r*');
plot(Beat.clip, 2, 'g*');
plot(detections, 3, 'c*');
axis([0,2000,-5,10]);
plot(Data.Signals.Bp.data./20);

figure;
plot(Data.Signals.PpgClip.data);
hold on;
plot(Data.BeatDetections.BsBp.samplestamp, Data.Signals.Bp.data(Data.BeatDetections.BsBp.samplestamp),'c*');
