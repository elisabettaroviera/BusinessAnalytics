%% SIMULAZIONE CODA M/M/1
% Script to check confidence intervals in the simulation of an M/M/1 queue
rng 'default' % Reset generatori numeri casuali

inRate = 1;
servRate = 2.1; % Il rapporto inRate/servRate <0 quindi il sistema è stabile

fprintf(1,"True expected waiting time: %.4f\n\n",(inRate/servRate)/(servRate-inRate));

sampleSize = 100000; % Simula questo numero di clienti

fprintf(1,"Confidence intervals:\n");
for k = 1:10 % Simulo l'esperimento 10 volte, ottenendo così 10 intervalli di confidenza
    ww = MM1_Queue(inRate, servRate, sampleSize);
    [~,~,ci] = normfit(ww); % Intervallo di confidenza con quantili di T di student
    fprintf(1,"(%.4f, %.4f)\n",ci(1),ci(2));
end

% Nested function che alloca i tempi di attesa
function [waitTimes] = MM1_Queue(lambda, mu, howmany)
waitTimes = zeros(howmany,1); % Il primo cliente ha tempo di attesa 0
for j = 2:howmany % RICORDA: i vettori partono da 1
    intTime = exprnd(1/lambda); 
    servTime = exprnd(1/mu);

    % Applicazione della formula ricorsiva trovata in teoria
    waitTimes(j) = max(0, waitTimes(j-1) + servTime - intTime);
end
end

autocorr(ww) % Plot autocorrelazione della 10 simulazione

% NB Gli intervalli di confidenza non si sovrappongono --> male, bisogna
% risolvere il problema
% Cosa abbiamo sbagliato?
% 1. Abbiamo assunto indipendenza tra i tempi di atteza, ma le variabili
% sono correlate -> quindi in questo caso sottostimiamo la varianza
% campioaria perchè non teniamo in considerazione le covarianze
% Dal plot possiamo ben vedere che il sistema è ampiamente correlato
% Mettendo servRate più alto, otteniamo meno memoria del sistema, quindi il
% plot dell'autocorrelazione ci fa notare meno correlazione tra gli
% elementi
% 2.

% 3.