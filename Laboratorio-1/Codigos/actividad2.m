%MODULACIÓN PCM
clc; %limpiar la pantalla de comandos de Matlab
close; %cerrar las variables usadas
clear; %limpia estas variables
fc=1000; %Frecuencia de la sinusoidal
fm=100000; %Frecuencia de muestreo 1/1e5Hz
numBits = input("Ingrese numero el bits"); 
numMuestras = 30; 
M = 2^numBits; %Palabras codificadas o niveles de amplitud
t=0:1/fm:2/fc;% tiempo muestrado a 1e5 HZ, por 5 periodos de sinusoidal
coseno = cos(2*pi*fc*t);      %Señal de entrada
figure(1)
subplot(3,1,1);  %Posición de la gráfica
plot(t,coseno,'-o');         %Señal de entrada
title('Señal Analógica');
ylabel('Amplitud');
xlabel('Tiempo');

%Proceso de Cuantización para la generación de la señal PCM.
vmax=1; %Valor máximo de s
vmin=-vmax; %Valor mínimo
del=(vmax-vmin)/M;
part=vmin:del:vmax; %Valores que toma a lo largo de nuestra señal, dividiendo la Amplitud
code=vmin-(del/2):del:vmax+(del/2); %Conteo de valores cuantificados
[ind,q]=quantiz(coseno,part,code); %Proceso de Cuantización

l1=length(ind);
l2=length(q);
for i=1:l1
	if(ind(i)~=0);
		ind(i)=ind(i)-1;
	end
	i=i+1;
end
for i=1:l2;
	if(q(i)==vmin-(del/2))
		q(i)=vmin+(del/2);
	end
end
subplot(3,1,2);
plot(t,q,'-o')
title('Cuantificacion de la Señal' );
ylabel('Amplitud');
xlabel('Tiempo');

%Proceso de Codificación
code=de2bi(ind,'left-msb');
k=1;
for i=1:l1
	for j=1:numBits
		coded(k)=code(i,j);
		j=j+1;
		k=k+1;
	end
	i=i+1;
end
subplot(3,1,3);
%grid on;
%plot(length(coded),coded,'-o')
stairs(coded); %Toma los valores de un vector para poder graficarlas
axis([0 100 -2 3]);
%grid on;
title('Señal Codificada');
ylabel('Amplitud');
xlabel('Tiempo');


figure(2)
plot(t,coseno-q,'-o')
title('Error de cuantificacion')

%ARCHIVO

filedata = fopen("archivo.txt",'w');
formatspec = '%d';
tam = length(coded);
for i=1:tam - 2
    fprintf(filedata,formatspec,coded(i));
    if(mod(i,numBits) == 0)
        fprintf(filedata,'\n');
    end
end
fclose(filedata);
