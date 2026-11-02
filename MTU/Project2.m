% Project Code
% Author: Chad Payba, Noah Keller, Gavin Moceri, Evan Thompson (cjpayba@mtu.edu, nmkeller@mtu.edu, gjmoceri@mtu.edu, egthomps@mtu.edu)
% Date: 10/28/2026

% House Keeping
clear, clc, close all

a = arduino('COM3', 'Uno', 'Libraries', {'Adafruit/DHTxx', 'Ultrasonic'}); % Connect to Arduino and add library
ts = addon(a, 'Adafruit/DHTxx', 'D6', 'DHT11'); % Connect to DHT11 sensor
UltrasonicObj = ultrasonic(a, 'D4', 'D5'); % Connect to UltraSonic Sensor D4 Trig, D5 Echo

%Initializing
voltage = 5;
resistance = 1000;
toohigh = 750;
toolow = 200;
tic();

Time = []; % Create a vector to store time data
TemperatureData = []; % Create a vector to store temperature data
HumidityData = []; % Create a vector to store humidity data
DistanceData = []; % Create a vector to store distance data
LightMeasurement = []; % Create a vector to store light data

disp("Start")
pause(2); % Notify user of Start
tic(); % Start a timer for measuring

for i = 1:100 % loop our measurement code to collect 100 points
    disp(i); % identify which measurement we are collecting
    Time(i) = toc(); % Save the time elapsed in seconds for each measurement
    TemperatureData(i) = readTemperature(ts); % Collect the Temperature Data
    HumidityData(i) = readHumidity(ts); % Collect the Humidity Data
    DistanceData(i) = readDistance(UltrasonicObj); % Corrected: Fixed function and variable name spaces
    LightMeasurement(i) = a.readVoltage("A0");
    pause(1); % pause to allow accurate readings
end
disp("end") % Notify user of end

% Convert voltage to lux
R10 = 140000; % photoresistor resistance at 10 lux
gamma = 1.06; % photoresistor slope
Rldr = resistance * (voltage ./ LightMeasurement - 1);
LuxMeasurement = 10 * (R10 ./ Rldr).^(1/gamma);

% Plotting Temperature
figure; % Create a new figure window for Temperature
plot(Time, TemperatureData, 'r*') % Place the temperature data in the figure (red stars)
hold on;
title('DHT11 Temperature Measurements Collected') % Add a Title
plot([min(Time), max(Time)], [24, 24],'y--'); %Plot the maximum
plot([min(Time), max(Time)], [21, 21],'r--'); %Plot the minimum
t = fit(Time',TemperatureData','poly1'); %Plot the average
plot(t, 'g-')
title('Temperature Levels of a Study Location')
xlabel('Time [s]'); % X Axis Label Time
ylabel('Temperature [°C]'); % Y Axis Label Temperature
legend('Measurements','Too High','Too low','Average')
grid on; % Add Grid Lines
hold off;

% Plotting Humidity
figure; % Create a new figure window for Humidity
plot(Time, HumidityData, 'b*') % Place the humidity data in the figure (blue stars)
hold on;
title('DHT11 Humidity Measurements Collected') % Add a Title
plot([min(Time), max(Time)], [60, 60],'y--'); %Plot the Maximum
plot([min(Time), max(Time)], [40, 40],'r--'); %Plot the Minimum
h = fit(Time',HumidityData','poly1'); %Plot the average
plot(h, 'g-')
title('Humidity Levels of a Study Location')
xlabel('Time [s]'); % X Axis Label Time
ylabel('Humidity [%]'); % Y Axis Label Humidity
legend('Measurements','Too High','Too low','Average')
grid on; % Add Grid Lines
hold off;

% Plotting Ultrasonic Distance
figure;
plot(Time, DistanceData, 'g*'); % Uses green stars for figure
hold on;
title('Ultrasonic Distance Measurements Collected'); % Add a Title
plot([min(Time), max(Time)], [12, 12],'y--'); %Plot the Maximum
plot([min(Time), max(Time)], [3, 3],'r--'); %Plot the Minimum
d = fit(Time',DistanceData','poly1'); %Plot the average
plot(d, 'g-')
title('Size of a Study Location')
xlabel('Time (s)'); % X Axis Label Time
ylabel('Distance [m]'); % Y Axis Label Distance
legend('Measurements','Too High','Too low','Average')
grid on;
hold off;

% Plotting Light Measurements
figure;
plot(Time, LuxMeasurement, 'b*') %Uses blue stars for figure
hold on;
plot([min(Time), max(Time)], [toohigh, toohigh],'y--'); %Plot the maximum
plot([min(Time), max(Time)], [toolow, toolow],'r--'); %Plot the minimum
f = fit(Time',LuxMeasurement','poly1'); %Plot the average
plot(f, 'g-')
ylim([0 inf])
title('Light Levels of a Study Location')
xlabel('Time (t) [sec]') % X Axis Label Time
ylabel('Light (l) [lx]') % Y Axis Label Light
legend('Measurements','Too High','Too low','Average')

averageTemperature = mean(TemperatureData); % Take average temperature from TemperatureData
averageHumidity = mean(HumidityData); % Take average humidity from Humidity Data
averageDistance = mean(DistanceData); % Take average distance from Distance Data

avgTempStatus = "";
avgHumStatus = "";
avgDistStatus = "";
optimalCount = 0;

% Output based on the average temperature
if averageTemperature < 21
    avgTempStatus = "Temperature is too cold for studying";
elseif averageTemperature >= 21 && averageTemperature <= 24
    avgTempStatus = "Temperature is optimal for studying";
    optimalCount = optimalCount + 1;
elseif averageTemperature > 24
    avgTempStatus = "Temperature is too hot for studying";
end

% Output based on the average humidity
if averageHumidity < 40
    avgHumStatus = "Humidity is too dry for studying";
elseif averageHumidity >= 40 && averageHumidity <= 60
    avgHumStatus = "Humidity is optimal for studying";
    optimalCount = optimalCount + 1;
else
    avgHumStatus = "Humidity is too wet for studying";
end

% Output based on the average distance parameters
if averageDistance < 3.0
    avgDistStatus = "Room space is too cramped for studying";
elseif averageDistance >= 8.0 && averageDistance <= 10.0
    avgDistStatus = "Room space is optimal for studying";
    optimalCount = optimalCount + 1;
elseif averageDistance > 12.0
    avgDistStatus = "Room space is too big for studying";
else
    avgDistStatus = "Room space is acceptable for studying";
end

% Output based on the light analysis
Lux = sum(LuxMeasurement)/length(LuxMeasurement);
if Lux > toohigh
    LightCondition = 'too bright';
elseif Lux < toolow
    LightCondition = 'too dark';
else
    LightCondition = 'optimal';
    optimalCount = optimalCount + 1;
end

% Determine Overall Condition
if optimalCount == 0
    status = 'terrible';
elseif optimalcount == 1
    status = 'poor';
elseif optimalcount == 2
    status = 'okay';
elseif optimalcount == 3
    status = 'good';
elseif optimalcount == 4
    status = 'perfect';
end

% Final output telling the average and if studying conditions are optimal
fprintf('\n--- Final Summary ---\n');
fprintf('Average Temperature: %.2f°C (%s)\n', averageTemperature, avgTempStatus);
fprintf('Average Humidity: %.2f%% (%s)\n', averageHumidity, avgHumStatus);
fprintf('Average Distance: %.2f m -> %s\n', averageDistance, avgDistStatus);
fprintf("The light level in this room is %s for studying, with an average of %.0f lux", LightCondition, Lux);
fprintf("This room is %s for studying.", optimalCount);