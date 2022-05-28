% mt: Onda sinusoidal  ;  SNt : PAM muestro natural;

%Parametros generales 
fc=1000; %Frecuencia de la sinusoidal
fm=100000; %Frecuencia de muestreo 1/1e5Hz
Tm=1/fm;
fs= fc*5;   %Frecuencia de la cuadrada
L=200; %Muestras
t=(0:L-1)*Tm;%tiempo muestrado a 1e5 HZ.

%Señal analogica sinusoidal
mt=cos(2*pi*fc*t); 

%---------------------------Modulacion PAM Natural--------------------------------------
%d=0.7e-2*fs; %(tau / Ts) <=> (tau * fs) 
d=75;%Parametro, ciclo de trabajo 'd'
RECt=0.5*square(2*pi*fs*t,d)+0.5; %Señal cajon.
SNt=mt.*RECt; %SNt : PAM muestro natural

%-------------------------Modulacion PAM Instantaneo --------------------------------------
SIt = SNt;   %SIt : PAM muestreo instantaneos, falta que sea modificado por el for
for i = 2: length(t)
    if RECt(i) == 1 && RECt(i-1) == 0 %Si hay un ascenso  
        SIt(i) = RECt(i) * mt(i); %sampling
    elseif RECt(i) == 1 && RECt(i-1) == 1 %La señal cajon se mantiene en 1.
        SIt(i) = SIt(i-1); %Se mantiene el valor anterior del SIt
    else 
        SIt(i) = 0; %Cualquier otro caso es 0
    end
end


%-------------------------Transformada de Fourier --------------------------------------
Y=fft(mt);
magTF = 2*(abs(Y(1:L/2)/L)); %Se utiliza solo la parte real, y se soluciona la mitad de la amplitud
f = fm*(0:L/2-1)/L; %Vector de frecuencias positivas

figure(1)
subplot(2,2,1); plot(t,mt,'-o'); title('Señal analogica'); xlabel('t (segundos) '); ylabel('amplitud');
subplot(2,2,2); plot(f,magTF,'-o'); title('Transformada Fourier analogica'); xlabel('f(Hz)'); ylabel('amplitud');    
subplot(2,2,3); plot(t,SNt,'-o'); title('Pam muestreo Natural'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(2,2,4); plot(t,SIt,'-o'); title('Pam muestreo Instantaneo'); xlabel('t(segundos)'); ylabel('amplitud');


%%%%%%%%%%%%%%%%%1a.-Que pasa si se disminuye la frecuencia de muestreo?%%%%%%%%%%%%
%La funcion pierde suavidad, y comienza a tener una forma de funcion triangular, hasta que termina completamente desfigurada.
%% L = 200 -> fm 100.0000
%% L1a = x  ->  fmMin 12.000  => x=24;

fmMin=(fc+fs)*1.2; %(1000+5000)*2 =12.000 < 100.000
L1a=(fmMin*L)/fm;
t1a=(0:L1a-1)*(1/fmMin);% tiempo muestrado a 1e5 HZ, por 2 periodos de sinusoidal
mt1a=cos(2*pi*fc*t1a); %Onda analogica sinusoidal
RECt1a=0.5*square(2*pi*fs*t1a,80)+0.5;%Forma de onda de conmutación de ondas rectangulares
SNt1a=mt1a.*RECt1a;
SIt1a = SNt1a;
%%%%%%%%%%%%%%%%%%%%%%%  PAM mueSNtreo inSNtantaneo %%%%%%%%%%%%%%%%%%%%
for i = 2: length(t1a)
    if RECt1a(i) == 1 && RECt1a(i-1) == 0 %if the rising edge is deteRECt_encoding    
        SIt1a(i) = RECt1a(i) * mt1a(i); %sampling occurs
    elseif RECt1a(i) == 1 && RECt1a(i-1) == 1 %and while the carrier signal is 1
        SIt1a(i) = SIt1a(i-1); %the value of y1 remains conSNtant
    else 
        SIt1a(i) = 0; %otherwise, SNt is zero
    end
end
Y1a=fft(mt1a);
magTF1a = 2*(abs(Y1a(1:L1a/2)/L1a)); %Se utiliza solo la parte real, y se soluciona la mitad de la amplitud
f1a = fmMin*(0:L1a/2-1)/L1a; %Vector de frecuencias positivas

figure(2)
subplot(2,3,1); plot(t1a,mt1a,'-o'); title('señal de mensaje'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(2,3,2); plot(f1a,magTF1a,'-o'); title('Transformada Fourier Señal'); xlabel('f (hz)'); 
subplot(2,3,3); plot(t1a,SNt1a,'-o'); title('Pam muestreo Natural'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(2,3,4); plot(t1a,RECt1a,'-o'); title('Cajon'); xlabel('t (segundos)'); ylabel('amplitud');
subplot(2,3,5); plot(t1a,SIt1a,'-o'); title('Pam muestreo Instantaneo'); xlabel('t (segundos)'); ylabel('amplitud');


%---------------------------1b.-¿Hay algún lı́mite? Si lo hay, ¿Cuál es?
%%%%%%EL limite es que la frecuencia de muestreo tiene que ser el doble del componente de interés de frecuencia más alto en la señal medida, y esta frecuencia se denomina Frecuencia de Nyquist. Teorema de Teorema de Muestreo de Nyquist

%-----------------------------1c¿Porque existe este lı́mite?
%%Porque a esta frecuencia de muestro, la señal se asemeja a una señal triangular.

%-----------------------------1d.¿Que pasa si supera este lı́mite?
%%Comienza generarse Aliasing, que es que los componentes de frecuencias falsas mas bajas aparecen en los datos muestreados, y ya la señal graficada, resulta en otra señal.

%-------------------¿Por qué la transformada de Fourier tiene esa forma para cada una de las señales ?

Ysn=fft(SNt);%Transformada de  Fourier de PAM natural
Ysi=fft(SIt);%Transformada de  Fourier de PAM instantanea
magTFsn = 2*(abs(Ysn(1:L/2)/L)); %Se utiliza solo la parte real, y se soluciona la mitad de la amplitud
magTFsi = 2*(abs(Ysi(1:L/2)/L));


figure(3)
subplot(3,2,1); plot(t,mt,'-o'); title('señal de mensaje'); xlabel('t (Segundos)'); ylabel('amplitud');
subplot(3,2,2); plot(f,magTF,'-o'); title('Transformada Fourier Señal'); xlabel('f (hz)'); ylabel('amplitud'); 

subplot(3,2,3); plot(t,SNt,'-o'); title('Pam muestreo Natural'); xlabel('t (segundos) '); ylabel('amplitud');
subplot(3,2,4); plot(f,magTFsn,'-o'); title('Transformada Fourier Pam Natural'); xlabel('f (hz)'); 
subplot(3,2,5); plot(t,SIt,'-o'); title('Pam muestreo Instantaneo'); xlabel('t(segundos)'); ylabel('amplitud');
subplot(3,2,6); plot(f,magTFsi,'-o'); title('Transformada Fourier Pam Instantaneo'); xlabel('f (hz)');

%Porque al modularla, se reduce el ancho de banda, para que sea mas facil su transporte