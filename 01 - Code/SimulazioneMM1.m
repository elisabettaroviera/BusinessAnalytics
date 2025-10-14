%% 1-SIMULAZIONE CODA M/M/1
% Script to check confidence intervals in the simulation of an M/M/1 queue
rng 'default' % Reset generatori numeri casuali

inRate = 1;
servRate = 1.1; % Il rapporto inRate/servRate <0 quindi il sistema è stabile
                % Cambiando questo valore a 2.1 i risultati saranno
                % migliori, infatti il vero valore appartiene agli
                % intervalli di confidenza che risultano anche essere
                % sovrapposti

fprintf(1,"True expected waiting time: %.4f\n\n",(inRate/servRate)/(servRate-inRate));

sampleSize = 600000; % Simula questo numero di clienti

fprintf(1,"Confidence intervals:\n");
for k = 1:10 % Simulo l'esperimento 10 volte, ottenendo così 10 intervalli di confidenza
    ww = MM1_Queue(inRate, servRate, sampleSize);
    [~,~,ci] = normfit(ww); % Intervallo di confidenza con quantili di T di student
                            % Fitta una normale -> intervallo di fiducia
    fprintf(1,"(%.4f, %.4f)\n",ci(1),ci(2));
end

% Nested function che alloca i tempi di attesa
function [waitTimes] = MM1_Queue(lambda, mu, howmany)
waitTimes = zeros(howmany,1); % Il primo cliente ha tempo di attesa 0
for j = 2:howmany % RICORDA: i vettori partono da 1
    intTime = exprnd(1/lambda); 
    servTime = exprnd(1/mu);

    % Applicazione della formula ricorsiva trovata in teoria
    % Ricorsiva perchè il tempo di attesa del cliente j dipende da quello
    % del cliente j-1
    waitTimes(j) = max(0, waitTimes(j-1) + servTime - intTime);
end
end

% Autocorrelazione
figure; 
autocorr(ww) % Plot autocorrelazione della 10 simulazione

% Istogramma
figure; 
hist(ww) % Per vedere che non va bene la distribuzione normale

% Media cumulata
figure; 
t = (1:sampleSize)';
plot(t, cumsum(ww(t))./t) % Vediamo che con 1000 otteniamo una media di 4.5, 
                          % quindi molto lontano dal regime stazionario

% NB Gli intervalli di confidenza non si sovrappongono --> male, bisogna
% risolvere il problema

% Cosa abbiamo sbagliato? normfit(ww)
% 1. Abbiamo assunto indipendenza tra i tempi di atteza, ma le variabili
% sono correlate, quindi in questo caso sottostimiamo la varianza
% campioaria perchè non teniamo in considerazione le covarianze
% Dal plot possiamo ben vedere che il sistema è ampiamente correlato
% Mettendo servRate più alto, otteniamo meno memoria del sistema, quindi il
% plot dell'autocorrelazione ci fa notare meno correlazione tra gli
% elementi -> autocorr(ww)
% 2. Stiamo assumendo una distribuzione normale, che NON è la distribuzione
% corretta da assumere -> hist
% 3. Il sistema dovrebbe andare a regime, ma non sappiamo se sampleSize è
% abbastanza grande per andare a regime o se siamo ancora nel periodo
% transitorio -> plot media cumulata 