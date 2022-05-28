%Frecuencia y periodo de sincronizacion
fs=1000;
Ts=1/fs;
%Frecuencia de muestreo de Nyquist fn>=2Frecuencia max
fm=10*fs;
Tm=1/fm;

%a_n, valores que tendran los pulsos [-1,1] antipoda binaria
valores=(2*randi([0,1],[1,10^5]))-1;

%Muestras para un periodo de sincronizacion
m=Ts/Tm;

%Vector de tiempo, respecto a los impulsos que tenga el Tren.
t=[-(length(valores)/2)*Ts:Tm:(length(valores)/2)*Ts];

%Tren de Impulsos separados en Ts => por m muestras
TrenImpulsos=t;
contador=m-1;
indiceValores=1;
for index=1 : (length(t)-1)
    if(indiceValores<=length(valores))
        if(contador == (m-1) )
            TrenImpulsos(index)=valores(indiceValores);
            indiceValores=indiceValores+1;
            contador=0;
        else
            TrenImpulsos(index)=0;
            contador=contador+1;
        end
    else 
        TrenImpulsos(index)=0;
    end
end

%Onda cajon con periodo Ts, funcion transferencia filtro trasmisor h_t(t)
h_t=t;
for index = 1 : length(h_t) 
    if( (length(h_t)/2)- (m/2) <= index && index <= (length(h_t)/2)+(m/2)) %Bonito
        h_t(index)=1;
    else
        h_t(index)=0;
    end
end

%Señal de entrada x(t)
x_t=conv(TrenImpulsos,h_t);
t2=[-((length(x_t)/2)/m)*Ts:Tm:+((length(x_t)/2)/m)*Ts];

figure(1)
subplot(3,1,1); stem(t, TrenImpulsos);title('Tren de Impulsos a distancias Ts=0,001(s), solo 10 Ts'); xlabel('t (segundos)');xlim([-5.6*Ts 4.5*Ts]);ylabel('amplitud');
subplot(3,1,2); plot(t, h_t, '-o');  xlabel('t (segundos)');ylabel('amplitud'); title('h_t(t) funcion transferencia filtro trasmisor');;xlim([-6*Ts 6*Ts]);
subplot(3,1,3); plot(t2,[x_t 0], '-o'); title('Señal de entrada x(t) = TrenImpulsos * h_t(t), solo 10 Ts'); xlabel('t (segundos)');xlim([-5.6*Ts 4.5*Ts]);ylabel('amplitud');


%Coseno alzado
%Frecuencia de ancho de banda de 6dB, mitad de velocidad de simbolos
fo=fs/2;% fo=1000/2=500 Hz
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
f=fs*(-(length(H_et)-1)/2:(length(H_et)-1)/2)/length(H_et);


figure(2)
subplot(2,1,1); plot(t, h_et);title('Respuesta impulso equivalente'); xlabel('t (segundos)'); ylabel('amplitud');xlim([-6*Ts 6*Ts]);
subplot(2,1,2); plot(f,abs(fftshift(H_et)), '-o'); title('Funcion equivalente de tranferencia en frecuencia');xlabel('f (Hz)'); ylabel('amplitud')


SecuenciaFiltrada=conv(TrenImpulsos,h_et);
tfiltrada=[-((length(SecuenciaFiltrada)/m)/2*Ts):Tm:(length(SecuenciaFiltrada)/m)/2*Ts];

figure(3)
subplot(3,1,1); stem(t, TrenImpulsos);title('Tren de Impulsos a distancias T=0,001(s), solo 10 Ts'); xlabel('t (segundos)'); ylabel('amplitud');xlim([-5.6*Ts 4.5*Ts])
subplot(3,1,2); plot(t2,[x_t 0], '-o'); title('Señal de entrada x(t) = TrenImpulsos * h_t(t), solo 10 Ts'); xlabel('t (segundos)');xlim([-5.6*Ts 4.5*Ts]);ylabel('amplitud');
subplot(3,1,3); plot(tfiltrada, [SecuenciaFiltrada 0]);title('Secuencia filtrada con Coseno alzado, solo 10 Ts'); xlabel('t (segundos)'); ylabel('amplitud');xlim([-5.6*Ts 4.5*Ts]);


SecuenciaFiltradaRecortada=[1:length(valores)*m];
shift=length(SecuenciaFiltrada)-length(x_t);
for i=1:length(valores)*m
    SecuenciaFiltradaRecortada(i)=SecuenciaFiltrada(shift+i);
end

filtro = reshape(SecuenciaFiltradaRecortada,2*m,[]);
y=awgn(filtro,18,'measured'); 

figure(5);
subplot(2,1,1);plot(filtro,'b');  title('Diagrama de ojo'); xlabel('time');ylabel('amplitude');grid on
subplot(2,1,2);plot(y,'b');title('Diagrama de ojo con AWGN');
