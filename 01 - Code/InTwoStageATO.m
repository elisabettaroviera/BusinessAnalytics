%% 5b - In Two Stage ATO

format bank
typeVar = 'integer'; % Soluzione nel continuo 
%typeVar = 'continuous'; % Soluzione a variabili intere

% PROBLEM DATA 
numItems = 3;
numComp = 5;
numScenarios = 3;
numResources = 3;
compCost = [20; 30; 10; 10 ; 10];
gozinto = [ 1 1 1 0 0
            1 1 0 1 0
            1 1 0 0 1];
needRes = [ 
 1 2 1 
 1 2 2 
 2 2 0 
 1 2 0 
 3 2 0 ];
availRes = [800; 700; 600];
endPrice = [80; 70; 90];
demand = [   
    100 50 120 
     50 25 60 
    100 110 60 ];
probs = ones(numScenarios,1)/numScenarios;

% 1- PROBLEMA AI VALORI ATTESI
demandAverage = mean(demand,2);
probEV = optimproblem('ObjectiveSense','max'); % Creazione oggetto di una classe
x = optimvar('x', numComp, 1,  'LowerBound', 0, 'Type',typeVar); % Componenti
y = optimvar('y', numItems, 1,  'LowerBound', 0, 'UpperBound', demandAverage, 'Type',typeVar); % Prodotti finiti

probEV.Objective = -dot(compCost,x) + dot(endPrice,y); % Funzione obiettivo con il prodotto interno di due vettori
probEV.Constraints.cons1 = needRes' * x <= availRes;  % Vettore di vincoli di capacità
probEV.Constraints.cons2 = gozinto' * y <= x; % Vincolo che lega x e y

showproblem(probEV) % Ti fa vedere il modello che si è costruito

[solEV, profitEV] = solve(probEV); % Risoluzinoe del modello

solEV.x
solEV.y
profitEV % Modello ai valori attesi

% 2- STOCHASTIC DEMAND MODEL (integer vars)
probRP = optimproblem('ObjectiveSense','max');
x = optimvar('x', numComp, 1,  'LowerBound', 0, 'Type',typeVar);
y = optimvar('y', numItems, numScenarios,  'LowerBound', 0, 'UpperBound', demand, 'Type',typeVar);
probRP.Objective = -dot(compCost,x) + dot(endPrice'*y,probs); % Trovo il ricavo per ogni scenario
probRP.Constraints.cons1 = needRes' * x <= availRes; % Vincoli al primo stadio
compConstr = optimconstr(numScenarios,numComp); % Pre-alloco la matrice di vincoli
% Riempio la matrice dei vincoli al secondo stadio
for s=1:numScenarios
    compConstr(s,:) = gozinto' * y(:,s) <= x;
end

probRP.Constraints.cons2 = compConstr;
showproblem(probRP)

[solRP, profitRP] = solve(probRP);
solRP.x
solRP.y
profitRP % Soluzione stocastica

% AVERAGE DEMAND MODEL (integer vars)
% Check actual performance 
probRP.Constraints.fixFirstStage = x == solEV.x; % Modello stocastico a cui aggiungo un vincolo, cioè fisso le soluzione x del secondo modello nel primo
[solRP2, profitRP2] = solve(probRP);
solRP2.y
profitRP2 % Profitto della soluzione del modello deterministico 
VSS = profitRP - profitRP2 % Differenza tra soluzione deterministica e stocastica
format
