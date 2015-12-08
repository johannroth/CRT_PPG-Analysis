% clearvars -except Data patient;


figure;
plot(Data.Signals.PpgClip.data);
hold on;
plot(Data.BeatDetections.BsBp.samplestamp, Data.Signals.Bp.data(Data.BeatDetections.BsBp.samplestamp),'c*');

stairs(Data.Signals.Bp.data);


%% Plot for waveform comparison of extracted beats

test = extractBeats(Data.Signals.PpgClip.data, ...
                    Data.BeatDetections.Merged.samplestamp(100:109), ...
                    Data.Signals.PpgClip.fs, ...
                    Data.Metadata.heartRate(patient), ...
                    true);
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
title(['Pt' num2str(patient)]);
figure;
plot(test);
title(['Pt' num2str(patient)]);
figure;
plot (mean(test,2));
title(['Pt' num2str(patient)]);

plot(Data.Signals.PpgClip.data);

% mean waveform for all beats:
figure;
plot (mean(test'));

figure;
plot(test);

mesh(test)