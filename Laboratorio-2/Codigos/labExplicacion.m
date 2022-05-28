fo=1000;
T=1/fo;
fs = fo*10;
Ts=1/fs;
%a_n, valores que tendran los pulsos [-1,1]
valores=(2*randi([0,1],[1,10^1]))-1;
%Muestras para un periodo T
m=T/Ts;
%Tren de pulsos separados en T <=> m muestras
TrenImpulsos=upsample(valores,m)
t=[-(length(TrenImpulsos)/m)/2*T:Ts:(length(TrenImpulsos)/m)/2*T];

%Onda cajon con periodo T, funcion transferencia filtro trasmisor h_t(t)
h_t=t;
for index = 1 : length(h_t) 
    if(length(h_t)/2)- (m/2) <=index  && index<=(length(h_t)/2)+(m/2)
        h_t(index)=1;
    else
        h_t(index)=0;
    end
end

%Señal de entrada x(t)
x_t=conv(valores,h_t);
t2=[-((length(x_t)/2)/m)*T:Ts:+((length(x_t)/2)/m)*T];

figure(1)
subplot(3,1,1); stem(t, [TrenImpulsos 0]);title('Tren de Impulsos a distancias T=0,001(s)'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(3,1,2); plot(t, h_t, '-o'); title('h_t(t) funcion transferencia filtro transmisor');
subplot(3,1,3); plot(t2,[x_t 0], '-o'); title('Señal de entrada x(t) = TrenPulsos * h_t(t)');


%Coseno alzado
sincNum = sin(2*pi*fo*t);
sincDen = (2*pi*fo*t);
sincDenZero = find(abs(sincDen) < 10^-10);
sincOp = sincNum./sincDen;
sincOp(sincDenZero) = 1;

alpha = 0.22;
cosNum = cos(2*pi*alpha*fo*t);
cosDen = (1-(4*alpha*fo*t).^2);
cosDenZero = find(abs(cosDen)< 10^-10);
cosOp = cosNum./cosDen;
cosOp(cosDenZero) = pi/4;

%Respuesta impulso equivalente h_e(t)
h_et = 2*fo*sincOp.*cosOp; 
%Funcion equivalente de tranferencia H_e(t)
H_et=fft(h_et);
f=fs*(-(length(H_et)-1)/2:(length(H_et)-1)/2)/length(H_et)
figure(2)
subplot(2,1,1); plot(t, h_et);title('Respuesta impulso equivalente'); xlabel('t (segundos)'); ylabel('amplitud')
subplot(2,1,2); plot(f,abs(fftshift(H_et)), '-o'); title('Funcion equivalente de tranferencia en frecuencia');xlabel('f (Hz)'); ylabel('amplitud')


SecuenciaFiltrada=conv(TrenImpulsos,h_et);

tfiltrada=[-((length(SecuenciaFiltrada)/m)/2*T):Ts:(length(SecuenciaFiltrada)/m)/2*T];
figure(3)
subplot(3,1,1); stem(t, [TrenImpulsos 0]);title('Tren de Impulsos a distancias T=0,001(s)'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(3,1,2); plot(tfiltrada, [SecuenciaFiltrada 0]);title('Secuencia filtrada con Coseno alzado, recortada en tiempo'); xlabel('t (segundos)');xlim([-5*T 5*T]); ylabel('amplitud');
subplot(3,1,3); plot(tfiltrada, [SecuenciaFiltrada 0]);title('Secuencia filtrada con Coseno alzado'); xlabel('t (segundos)'); ylabel('amplitud');
filtro = reshape(SecuenciaFiltrada,2*m,[]);  
figure(4);
plot(filtro,'b');  
title('eye diagram with alpha=0.22'); 
xlabel('time')
ylabel('amplitude')
grid on

y=awgn(filtro,20,'measured');
figure(5);
plot(y,'b');  
title('eye diagram with alpha=0.22'); 
xlabel('time')
ylabel('amplitude')
grid on
