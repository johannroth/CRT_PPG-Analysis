testSignal = Data.Signals.Bp.data(signalStart:signalEnd);
sample = signalStart:signalEnd;
figure;
plot(sample*5/1000, testSignal);

intervalStamps = Data.StimulationModes.AV.samplestamp;
intervalValues = Data.StimulationModes.AV.value;
hold on;
stairs(intervalStamps*5/1000,intervalValues);

axis([signalStart*5/1000 signalEnd*5/1000 -inf inf]);


