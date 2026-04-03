close all; clear; clc;
data = readtable('data_motor (1).csv');

% Convertimos los datos a números puros
time = double(data.time_t_);
respuestadelsistema = double(data.system_response_y_);
signaldeingreso = double(data.ex_signal_u_);

% Línea a 100% 
promedio_estabilidad = mean(respuestadelsistema(time > 2));

% GANANCIA km
K_comun = promedio_estabilidad / 1.5; 

% RECTA TANGENTE 
y2 = 0.7859;   x2 = 1.2121;  
y1 = 0.18444;  x1 = 0.50505;  
pendiente = (y2 - y1) / (x2 - x1);  
y_tangente = pendiente * (time - x1) + y1;  

% Ziegler & Nichols 
theta_z = 0.1;
tau_z = 1.46465 - theta_z;  
sys_z = tf(K_comun, [tau_z 1], 'InputDelay', theta_z);  
respuesta_z = lsim(sys_z, signaldeingreso, time);  

% Miller 
theta_m = 0.1;
tau_m = 0.9256 - theta_m; 
sys_m = tf(K_comun, [tau_m 1], 'InputDelay', theta_m);
respuesta_m = lsim(sys_m, signaldeingreso, time);  

% Metodo Analítico 
theta_a = 0.1;  
tau_a = 0.60615; 
sys_a = tf(K_comun, [tau_a 1], 'InputDelay', theta_a);
respuesta_a = lsim(sys_a, signaldeingreso, time);

%%  FIT y ajuste
promedio_y = mean(respuestadelsistema);
fit_ZN = 100 * (1 - norm(respuestadelsistema - respuesta_z) / norm(respuestadelsistema - promedio_y));
fit_Miller = 100 * (1 - norm(respuestadelsistema - respuesta_m) / norm(respuestadelsistema - promedio_y));
fit_Analitico = 100 * (1 - norm(respuestadelsistema - respuesta_a) / norm(respuestadelsistema - promedio_y));

fprintf('\n--- RESULTADOS FIT ---\n');
fprintf('Ziegler-Nichols: %.2f%%\n', fit_ZN);
fprintf('Miller: %.2f%%\n', fit_Miller);
fprintf('Analitico: %.2f%%\n\n', fit_Analitico);

figure;
plot(time, respuestadelsistema, 'r', 'LineWidth', 1.5) % 1. Respuesta del sistema
hold on
plot(time, respuesta_z, 'LineWidth', 1.5);             % 2. Ziegler y Nichols
plot(time, respuesta_m, 'LineWidth', 1.5);             % 3. Miller
plot(time, respuesta_a, 'LineWidth', 1.5);             % 4. Analitico
plot(time, signaldeingreso, 'b', 'LineWidth', 1.5)     % 5. Señal de Ingreso

% --- RECTA TANGENTE EN COLOR NARANJA LLAMATIVO ---
plot(time, y_tangente, 'Color', [1 0.5 0], 'LineStyle', '--', 'LineWidth', 2); 

% Linea de estabilidad
yline(promedio_estabilidad, 'g--', 'LineWidth', 1.5);  

% Ajuste de límites
ylim([0 promedio_estabilidad*1.2]);

legend('Respuesta del sistema', 'Salida Ziegler y Nichols', 'Miller', 'Metodo Analitico', 'Señal de Ingreso', 'Recta Tangente', 'Linea de estabilidad', 'Location', 'best');
title('Respuesta del sistema y Aproximación');
xlabel('Tiempo (s)');
ylabel('Amplitud');
grid on;
hold off;