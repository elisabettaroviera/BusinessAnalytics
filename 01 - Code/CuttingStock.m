%% 8a- Cutting stock problem - Kantorovich model formulation
% Generazione casuale di un'istanza del problema
rng 'default'
rollLength = 1000;
numLenghts = 8;
lenghts = randsample(10:800,numLenghts);  
demand = 20+unidrnd(150,numLenghts,1); % a caso genero la domanda
fudgeFactor = 2; % valore di controllo, sicuramente molto pessimistico
numRolls = ceil(fudgeFactor*(dot(lenghts,demand)/rollLength)); % quanti rotoli utilizzabili

% Symmetric model formulation
cutStock = optimproblem("ObjectiveSense","minimize");
delta = optimvar("delta",numRolls,1,"Type","integer","LowerBound",0,"UpperBound",1);
numCut = optimvar("numCut",numLenghts,numRolls,"Type","integer","LowerBound",0);
cutStock.Objective = sum(delta,'all'); % funzione obiettivo -> limitare la somma delle delta
cutStock.Constraints.meetDemand = sum(numCut,2) >= demand; % per ogni prodotto metto i vincoli in maniera vettoriale
cutStock.Constraints.useLog = lenghts*numCut <= rollLength*delta';
% showproblem(cutStock);
fprintf(1,"Running symmetric model formulation\n")
solve(cutStock); % risolvo il modello

% showproblem(cutStock);
breaking = optimconstr(numRolls-1,1);
for k=1:(numRolls-1)
    breaking(k) = delta(k+1) <= delta(k);
end
cutStock.Constraints.breaking = breaking;
fprintf(1,"Running symmetry breaking model formulation\n")
solve(cutStock);

%% Problema piccolo 
% Limiti -> se non ho un algoritmo molto performante non funziona per nulla
% bene questa tipologia di formazione 
% passiamo agli algo di generazione di colonne (prossimo notebook 08b)