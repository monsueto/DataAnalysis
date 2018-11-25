% ROTINA DE ANÁLISE DE DADOS 2018 - FORMULA SAE UFMG

% esta rotina é atualizada via controle de versões. Caso alguma alteração
% seja feita ao código, a mesma deve ser salva por meio da inserção da 
% seguinte linha de comando na 'Command Window':
% vcp DataAnalysis

% para plotar os gráficos aos quais deseja analisar, basta inserir a
% seguinte linha de comando na 'Command Window':
% plot(time, "variável desejada", time, "variável desejada", ...)

% valores máximo e mínimo dos dados de posição de volante e suspensão 
% (max = esquerda, min = direita)
VOLMIN = 345;
VOLMAX = 3770;
SUSPMAX = 2235;
SUSPMIN = 1790;

% frequência de aquisição (em Hz) dos pacotes
Fs = 40;
Fs2 = 20;
Fs3 = 2;

% importa o log desejado no formato '.txt' através da caixa de diálogo
nomeDoArquivo = uigetfile('*.txt');
teste = fileread(nomeDoArquivo);

% separa o log do teste em pacotes
teste = cellstr(teste);
teste = cellfun(@(newline) strsplit(newline, '\n'), teste, 'UniformOutput', false);
teste = [teste{:}];

% inicializando os contadores dos numeros de cada tipo de pacote
countP1 = 0;
countP2 = 0;
countP3 = 0;
countP4 = 0;
extReceive = 0;

% separa o pacote em dados e o identifica (pacote 1, 2, 3 ou 4)
for i = 1:length(teste) % varre todos os dados presentes no .txt
    pacoteCell = cell2mat(teste(1,i)); % converte os valores para char (string) 
    pacoteCell = split(pacoteCell); % distribui os dados dos pacotes em linhas
    pacote = str2double(pacoteCell); % converte de char para double
    pacote = pacote'; % transpõe 
    
    % pega tamanho do pacote e subtrai 1
    t = size(pacote);
    tam = t(1,2) -1;
    
    if ((pacote(1) == 1)&& (tam == 8)) % analisa o pacote 1
        countP1 = countP1+1; % indica a quantidade de pacotes (index)
        
        % depende da orientação do acelerômetro
        P1(countP1,1) = -pacote(2)/16384;     % aceleração eixo X [g]
        P1(countP1,2) = pacote(3)/16384;      % aceleração eixo Y [g]
        P1(countP1,3) = -pacote(4)/16384;     % aceleração eixo Z [g]
        P1(countP1,4) = pacote(5);            % velocidade [km/h]
        P1(countP1,5) = pacote(6);            % acionamento do sparkcut (On ou Off)
        P1(countP1,6) = (pacote(7) - SUSPMAX)*25.4/(SUSPMAX-SUSPMIN); % posição da suspensão [mm]
        timeP1(countP1) = (pacote(8)/Fs);     % tempo [ms]
    
    elseif ((pacote(1) == 2)&& (tam == 10)) % analisa o pacote 2
        countP2 = countP2+1; % indica a quantidade de pacotes (index)
        P2(countP2,1) = pacote(2)*0.001;    % pressão de óleo [Bar]
        P2(countP2,2) = pacote(3)*0.001;    % pressão de combustível [Bar]
        P2(countP2,3) = pacote(4)*0.1;      % tps [%]
        P2(countP2,4) = pacote(5)*0.02536;  % pressão do fluido de freio frontal [Bar]
        P2(countP2,5) = pacote(6)*0.02536;  % pressão do fluido de freio traseiro [Bar]
        P2(countP2,6) = -(pacote(7) - VOLMAX)*240/(VOLMAX-VOLMIN) - 120; % posição do volante [Degrees(º)]
        P2(countP2,7) = pacote(8);          % beacon
        P2(countP2,8) = (pacote(9)- 2048)*60/4095; % corrente [A]
        timeP2(countP2) = (pacote(10)/Fs);  % tempo [ms]
    
    elseif ((pacote(1) == 3)&& (tam == 9)) % analisa o pacote 3
        countP3 = countP3+1; % indica a quantidade de pacotes (index)
        P3(countP3,1) = pacote(2)*0.1;      % temperatura do motor [ºC]
        P3(countP3,2) = pacote(3)*0.01;     % tensão da bateria [Volts]
        P3(countP3,3) = pacote(4);          % acionamento do relé da bomba (On ou Off)
        P3(countP3,4) = pacote(5);          % acionamento do relé da ventoinha (On ou Off)
        P3(countP3,5) = pacote(6);          % temperatura da pdu [ºC]
        P3(countP3,6) = pacote(7);          % temperatura do disco 1 [ºC]
        P3(countP3,7) = pacote(8);          % temperatura do disco 2 [ºC]
        timeP3(countP3) = (pacote(9)/Fs);   % tempo [ms]

    elseif ((pacote(1) == 4)&& (tam == 10))  % analisa o pacote 4
        if (extReceive == 0)
            extReceive = 1;
        end
        countP4 = countP4+1; % indica a quantidade de pacotes (index)
        ext(countP4,1) = pacote(2);        % extensômetro 1 [MPa]
        ext(countP4,2) = pacote(3);        % extensômetro 2 [MPa]
        ext(countP4,3) = pacote(4);        % extensômetro 3 [MPa]
        ext(countP4,4) = pacote(5);        % extensômetro 4 [MPa]
        ext(countP4,5) = pacote(6);        % extensômetro 5 [MPa]
        ext(countP4,6) = pacote(7);        % extensômetro 6 [MPa]
        ext(countP4,7) = pacote(8);        % extensômetro 7 [MPa]
        ext(countP4,8) = pacote(9);        % extensômetro 8 [MPa]
        timeP4(countP4) = (pacote(10)/Fs); % tempo [ms]
    end
end

% a função hampel remove outliers (como, por exemplo: picos indesejados)
timeP1 = hampel(timeP1);
timeP2 = hampel(timeP2);
timeP3 = hampel(timeP3);

P1(:,1) = hampel(P1(:,1));
P1(:,2) = hampel(P1(:,2));
P1(:,3) = hampel(P1(:,3));
P1(:,4) = hampel(P1(:,4));
P1(:,5) = hampel(P1(:,5));
P1(:,6) = hampel(P1(:,6));

P2(:,1) = hampel(P2(:,1));
P2(:,2) = hampel(P2(:,2));
P2(:,3) = hampel(P2(:,3));
P2(:,4) = hampel(P2(:,4));
P2(:,5) = hampel(P2(:,5));
P2(:,6) = hampel(P2(:,6));
P2(:,7) = hampel(P2(:,7));
P2(:,8) = hampel(P2(:,8));

P3(:,1) = hampel(P3(:,1));
P3(:,2) = hampel(P3(:,2));
P3(:,3) = hampel(P3(:,3));
P3(:,4) = hampel(P3(:,4));
P3(:,5) = hampel(P3(:,5));
P3(:,6) = hampel(P3(:,6));
P3(:,7) = hampel(P3(:,7));

% idealTimeArray size é o tamanho do vetor de tempo considerando que nenhum
% dado foi perdido
lastTimeVal = timeP1(size(timeP1,2));
firstTimeVal = timeP1(1);
elapsedTime = lastTimeVal-firstTimeVal;
idealTimeArraySize = int16((elapsedTime)*Fs);
elapsedTimeP2 = timeP2(size(timeP2,2)) - timeP2(1);
elapsedTimeP3 = timeP3(size(timeP3,2)) - timeP3(1);
idealTimeArraySize2 = int16((elapsedTimeP2)*Fs2);
idealTimeArraySize3 = int16((elapsedTimeP3)*Fs3);

% caso tenha mais pacotes 1 do que 2 ou 3, estabelece tamanho do vetor de 
% tempo ideal dos pacotes 1 e 2, baseado no pacote 3
if idealTimeArraySize ~= (idealTimeArraySize2*2)
 
  idealTimeArraySize = idealTimeArraySize2*2;
end
if idealTimeArraySize ~= (idealTimeArraySize3*2)  

   idealTimeArraySize = idealTimeArraySize3*Fs/Fs3;
   idealTimeArraySize2 = idealTimeArraySize3*Fs2/Fs3;
end

% cria vetores das variaveis do tamanho do vetor de tempo ideal para todos
% os pacotes. Inicializa os valores como -200 para facilitar a
% identificação posteriormente, caso haja perda de pacotes
time = zeros(1,idealTimeArraySize);
xAccel = -200*ones(1,idealTimeArraySize);  
yAccel = -200*ones(1,idealTimeArraySize);
zAccel = -200*ones(1,idealTimeArraySize);
velocidade = -200*ones(1,idealTimeArraySize);
acioSparkcut = -200*ones(1,idealTimeArraySize);
posSusp = -200*ones(1,idealTimeArraySize);

time2 = zeros(1,idealTimeArraySize2);
oilP = -200*ones(1,idealTimeArraySize2);
fuelP = -200*ones(1,idealTimeArraySize2);
tps = -200*ones(1,idealTimeArraySize2);
frontBrakePressure = -200*ones(1,idealTimeArraySize2);
rearBrakePressure = -200*ones(1,idealTimeArraySize2);
posSteeringWheel = -200*ones(1,idealTimeArraySize2);
beacon = -200*ones(1,idealTimeArraySize2);
current = -200*ones(1,idealTimeArraySize2);

time3 = zeros(1,idealTimeArraySize3);
ect = -200*ones(1,idealTimeArraySize3);
batteryVoltage = -200*ones(1,idealTimeArraySize3);
acioFuelPump = -200*ones(1,idealTimeArraySize3);
acioCooler = -200*ones(1,idealTimeArraySize3);
pduTemperature = -200*ones(1,idealTimeArraySize3);
tempBrake1 = -200*ones(1,idealTimeArraySize3);
tempBrake2 = -200*ones(1,idealTimeArraySize3);

if (extReceive == 1)
    ext0 = -200*ones(1,idealTimeArraySize2);
    ext1 = -200*ones(1,idealTimeArraySize2);
    ext2 = -200*ones(1,idealTimeArraySize2);
    ext3 = -200*ones(1,idealTimeArraySize2);
    ext4 = -200*ones(1,idealTimeArraySize2);
    ext5 = -200*ones(1,idealTimeArraySize2);
    ext6 = -200*ones(1,idealTimeArraySize2);
    ext7 = -200*ones(1,idealTimeArraySize2);
end

% cria um vetor de tempo ideal (como se não houvesse perdido nenhum pacote)
% começando do primeiro tempo do pacote 3. Isso evita que erros que venham
% a ser gerados devido a diferença temporal
for i = 1: idealTimeArraySize
    % parte do primeiro valor de tempo e usa a taxa de amostragem para
    % calcular os valores seguintes
    a = double(i);
    time(i) = timeP3(1)+double(a/Fs); 
end
for i = 1: idealTimeArraySize2
    % parte do primeiro valor de tempo e usa a taxa de amostragem para
    % calcular os valores seguintes
    a = double(i);
    time2(i) = timeP3(1)+double(a/Fs2); 
end
for i = 1: idealTimeArraySize3
    % parte do primeiro valor de tempo e usa a taxa de amostragem para
    % calcular os valores seguintes
    a = double(i);
    time3(i) = timeP3(1)+double(a/Fs3); 
end

% monta vetores novos do pacote 1 e 2 no tempo ideal nas posições
% correspondentes. Caso não haja perda de pacotes, o resultado é um vetor
% igual ao original.
% Caso haja perda, as posições nas quais houveram perdas manterão o valor 
% de -200
for i = 1: size(timeP1,2)-1
   % diferença de tempo entre o pacote atual e o primeiro pacote
   deltaT = timeP1(i)-firstTimeVal;
   % preenche os vetores com dados nas posicões correspondentes de tempo
   if int16((deltaT)*Fs+1)<= idealTimeArraySize
        % com a diferença de tempo, calcula em qual posicão do vetor ideal
        % deve estar o dado
        xAccel(int16((deltaT)*Fs+1)) = P1(i,1);   
        yAccel(int16((deltaT)*Fs+1)) = P1(i,2); 
        zAccel(int16((deltaT)*Fs+1)) = P1(i,3); 
        velocidade(int16((deltaT)*Fs+1)) = P1(i,4); 
        acioSparkcut(int16((deltaT)*Fs+1)) = P1(i,5); 
        posSusp(int16((deltaT)*Fs+1)) = P1(i,6); 
   end
end
for i = 1: size(timeP2,2)-1
   deltaT = timeP2(i)-timeP2(1);
   if int16((deltaT)*Fs2+1)<= idealTimeArraySize2
        oilP(int16((deltaT)*Fs2+1)) = P2(i,1);   
        fuelP(int16((deltaT)*Fs2+1)) = P2(i,2); 
        tps(int16((deltaT)*Fs2+1)) = P2(i,3); 
        frontBrakePressure(int16((deltaT)*Fs2+1)) = P2(i,4); 
        rearBrakePressure(int16((deltaT)*Fs2+1)) = P2(i,5); 
        posSteeringWheel(int16((deltaT)*Fs2+1)) = P2(i,6);
        beacon(int16((deltaT)*Fs2+1)) = P2(i,7);
        current(int16((deltaT)*Fs2+1)) = P2(i,8);
   end
end
for i = 1: size(timeP3,2)-1
   deltaT = timeP3(i)-timeP3(1);
   if int16((deltaT)*Fs3+1)<= idealTimeArraySize3
        ect(int16((deltaT)*Fs3+1)) = P3(i,1);
        batteryVoltage(int16((deltaT)*Fs3+1)) = P3(i,2);   
        acioFuelPump(int16((deltaT)*Fs3+1)) = P3(i,3); 
        acioCooler(int16((deltaT)*Fs3+1)) = P3(i,4); 
        pduTemperature(int16((deltaT)*Fs3+1)) = P3(i,5); 
        tempBrake1(int16((deltaT)*Fs3+1)) = P3(i,6); 
        tempBrake2(int16((deltaT)*Fs3+1)) = P3(i,7); 
   end
end 
if (extReceive == 1)
    for i = 1: size(timeP4,2)-1
       deltaT = timeP4(i)-timeP4(1);
       if int16((deltaT)*Fs2+1)<= idealTimeArraySize2
            ext0(int16((deltaT)*Fs2+1)) = ext(i,1);   
            ext1(int16((deltaT)*Fs2+1)) = ext(i,2); 
            ext2(int16((deltaT)*Fs2+1)) = ext(i,3); 
            ext3(int16((deltaT)*Fs2+1)) = ext(i,4); 
            ext4(int16((deltaT)*Fs2+1)) = ext(i,5); 
            ext5(int16((deltaT)*Fs2+1)) = ext(i,6);
            ext6(int16((deltaT)*Fs2+1)) = ext(i,7);
            ext7(int16((deltaT)*Fs2+1)) = ext(i,8);
       end
    end
end

% caso haja perda de pacotes interpola linearmente
if(idealTimeArraySize ~= size(timeP1,2))
    cnt = 0;
    % varre, para cada dado, o vetor em busca de valores -200 (regiões de
    % perda). Caso encontre um, conta até achar um valor diferente de -200.
    % Dessa forma, tem-se o intervalo no qual houve perda de pacotes. Esses
    % pontos de -200 são substituídos por uma reta que liga o valor
    % anterior ao primeiro ponto -200 e ao primeiro valor diferente de -200.
    for i = 1:idealTimeArraySize
        if xAccel(i) == -200
            cnt = cnt+1;
        % acabou a contagem, novo valor corretamente encontrado
        elseif cnt ~= 0
            deltaValue = xAccel(i)-xAccel(i-cnt-1);
            % dv é a inclinacao da reta que liga os pontos
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               % soma dv a cada ponto, de forma a interpolar linearmente
               xAccel(j) = xAccel(i-cnt-1) + dv*k;
               k=k+1;
            end
            % passa para o próximo dado
            deltaValue = yAccel(i)-yAccel(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               yAccel(j) = yAccel(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = zAccel(i)-zAccel(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               zAccel(j) = zAccel(i-cnt-1) + dv*k;
               k=k+1;
            end        
            deltaValue = velocidade(i)-velocidade(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               velocidade(j) = velocidade(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = acioSparkcut(i)-acioSparkcut(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               acioSparkcut(j) = acioSparkcut(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = posSusp(i)-posSusp(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               posSusp(j) = posSusp(i-cnt-1) + dv*k;
               k=k+1;
            end
        
            cnt = 0;
        end
    end
end
if(idealTimeArraySize2 ~= size(timeP2,2))
    cnt = 0;
    teste = oilP;
    for i = 1:idealTimeArraySize2
        if oilP(i) == -200
            cnt = cnt+1;
        elseif cnt ~= 0
            deltaValue = oilP(i)-oilP(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               oilP(j) = oilP(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = fuelP(i)-fuelP(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               fuelP(j) = fuelP(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = tps(i)-tps(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               tps(j) = tps(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = frontBrakePressure(i)-frontBrakePressure(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               frontBrakePressure(j) = frontBrakePressure(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = rearBrakePressure(i)-rearBrakePressure(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               rearBrakePressure(j) = rearBrakePressure(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = posSteeringWheel(i)-posSteeringWheel(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               posSteeringWheel(j) = posSteeringWheel(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = beacon(i)-beacon(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               beacon(j) = beacon(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = current(i)-current(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               current(j) = current(i-cnt-1) + dv*k;
               k=k+1;
            end
        
            cnt = 0;
        end
    end
end
if(idealTimeArraySize3 ~= size(timeP3,2))
    cnt = 0;
    teste = ect;
    for i = 1:idealTimeArraySize3
        if ect(i) == -200
            cnt = cnt+1;
        elseif cnt ~= 0
            deltaValue = ect(i)-ect(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               ect(j) = ect(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = batteryVoltage(i)-batteryVoltage(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               batteryVoltage(j) = batteryVoltage(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = acioFuelPump(i)-acioFuelPump(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               acioFuelPump(j) = acioFuelPump(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = acioCooler(i)-acioCooler(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               acioCooler(j) = acioCooler(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = pduTemperature(i)-pduTemperature(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               pduTemperature(j) = pduTemperature(i-cnt-1) + dv*k;
               k=k+1;
            end
            deltaValue = tempBrake1(i)-tempBrake1(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               tempBrake1(j) = tempBrake1(i-cnt-1) + dv*k;
               k=k+1;
            end
          deltaValue = tempBrake2(i)-tempBrake2(i-cnt-1);
            dv = (deltaValue)/(cnt+1);
            k = 1;
            for j = i-cnt:i-1
               tempBrake2(j) = tempBrake2(i-cnt-1) + dv*k;
               k=k+1;
            end
            
            cnt = 0;
        end
    end
end

% interpola os pacotes 2 e 3 para que tenham o mesmo numero de pontos que o 
% pacote 1
oilP = interp(oilP,Fs/Fs2);
fuelP = interp(fuelP,Fs/Fs2);
tps = interp(tps,Fs/Fs2);
frontBrakePressure = interp(frontBrakePressure,Fs/Fs2);
rearBrakePressure = interp(rearBrakePressure,Fs/Fs2);
posSteeringWheel = interp(posSteeringWheel,Fs/Fs2);
current = interp(current,Fs/Fs2);

ect = interp(ect,Fs/Fs3);
batteryVoltage = interp(batteryVoltage,Fs/Fs3);
pduTemperature = interp(pduTemperature,Fs/Fs3);
tempBrake1 = interp(tempBrake1,Fs/Fs3);
tempBrake2 = interp(tempBrake2,Fs/Fs3);

% sinais digitais, como os de indicação de acionamento, não funcionam bem 
% com a função de interpolar. Portanto, ao invés de usá-la, insire-se zeros
% e completa-se com 1 onde necessário

% upsample insere zeros
acioCooler = upsample(acioCooler,Fs/Fs3);
for(i=1:20:idealTimeArraySize)
    if(acioCooler(i) == 1)
       for(j=1:Fs/Fs3-1)
        acioCooler(i+j) = 1;
      end
    end
end
acioFuelPump = upsample(acioFuelPump,Fs/Fs3);
for(i=1:20:idealTimeArraySize)
    if(acioFuelPump(i) == 1)
       for(j=1:Fs/Fs3-1)
        acioFuelPump(i+j) = 1;
      end
    end
end
beacon = upsample(beacon,Fs/Fs2);
for(i=1:20:idealTimeArraySize)
    if(beacon(i) == 1)
       for(j=1:Fs/Fs3-1)
        beacon(i+j) = 1;
      end
    end
end

% caso tenha recebido pacotes de extensometria
if (extReceive == 1)
    ext0 = hampel(ext0);
    ext1 = hampel(ext1);
    ext2 = hampel(ext2);
    ext3 = hampel(ext3);
    ext4 = hampel(ext4);
    ext5 = hampel(ext5);
    ext6 = hampel(ext6);
    ext7 = hampel(ext7);

    ext0 = interp(ext0,Fs/Fs2);
    ext1 = interp(ext1,Fs/Fs2);
    ext2 = interp(ext2,Fs/Fs2);
    ext3 = interp(ext3,Fs/Fs2);
    ext4 = interp(ext4,Fs/Fs2);
    ext5 = interp(ext5,Fs/Fs2);
    ext6 = interp(ext6,Fs/Fs2);
    ext7 = interp(ext7,Fs/Fs2);
end

% limpa variáveis que não interessam ao workspace
clearvars a cnt countP1 countP2 countP3 countP4 deltaT deltaValue dv 
clearvars elapsedTimeP2 elapsedTimeP3 extReceive firstTimeVal Fs2 Fs3 i j
clearvars k lastTimeVal P1 P2 P3 pacote pacoteCell SUSPMAX SUSPMIN t tam 
clearvars teste time2 time3 timeP1 timeP2 timeP3 timeP4 VOLMAX VOLMIN