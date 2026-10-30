% Author: Gavin Moceri (gjmoceri@mtu.edu)
% Date: 10/30/2026

% Connect
clear
a = arduino();

% Initialize
voltage = 5;
resistance = 1000;
toohigh = 750;
toolow = 200;
Time = []; tic();
LightMeasurement = [];

% Measure
disp("Start")
for i = 1:500
    Time(i) = toc();
    LightMeasurement(i) = a.readVoltage("A0");
end
disp("end")

% Convert voltage to lux
R10 = 140000; % photoresistor resistance at 10 lux
gamma = 1.06; % photoresistor slope
Rldr = resistance * (voltage ./ LightMeasurement - 1);
LuxMeasurement = 10 * (R10 ./ Rldr).^(1/gamma);

% Plot
figure;
plot(Time, LuxMeasurement, 'b*')
hold on;
plot([min(Time), max(Time)], [toohigh, toohigh],'y--');
plot([min(Time), max(Time)], [toolow, toolow],'r--');
f = fit(Time',LuxMeasurement','poly1');
plot(f, 'g-')
ylim([0 inf])
title('Light Levels of a Study Location')
xlabel('Time (t) [sec]')
ylabel('Light (l) [lx]')
legend('Measurements','Too High','Too low','Average')

% Analysis
Lux = sum(LuxMeasurement)/length(LuxMeasurement);
if Lux > toohigh
    LightCondition = 'too bright';
elseif Lux < toolow
    LightCondition = 'too dark';
else
    LightCondition = 'optimal';
end

% Output a user-readable result
LightStatus = sprintf("The light level in this room is %s for studying, with an average of %.0f lux", LightCondition, Lux);
disp(LightStatus);