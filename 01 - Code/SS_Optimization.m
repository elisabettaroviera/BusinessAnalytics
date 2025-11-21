%% 3b- Optimization: Script to optimize (s,S) parameters

% Economics
unitCost = 10;
onHandCost = 0.1*unitCost;
lostPenalty = 2*unitCost; % Penalità molto alta
fixedCharge = 1000;

% Demand distribution
% Con makedist crei un oggetto, in questo caso consideriamo l'oggetto come
% un variabile aleatoria con una distribuzione di probabilità
pd = makedist('NegativeBinomial','R',20,'P',.3); % Definiamo la distribuzione di probabilità della domanda
% Make inSample scenario
rng default
horizonInSample = 30000; % Unica replicazine, ma molto lunga
% Note: scenarios are stored along ROWS
inSampleDemand = random(pd,1,horizonInSample);
% Make outSample scenario (not used here, but fundamental to check robustness)
% horizonOutSample = 100*horizonInSample;
% outSampleDemand = random(pd,1,horizonOutSample);
% outSample puoi fare delle verifiche che quanto hai fatto è corretto

initialStock = mean(pd)+2*std(pd); % Il magazzino iniziale non inizia a 0, ma da un valore 

% Create objfun
% Questa è una funzione di ottimizzazine utilizzando la funzione 3a
objfun = @(x) mean(SS_Simulation(x(1), x(1)+x(2), inSampleDemand, ...
    initialStock, onHandCost, lostPenalty, unitCost, fixedCharge));
upperBounds = [mean(pd)+10*std(pd);50*mean(pd)];

% Use pattern search
% Utilizza l'algoritmo pattern search

xStar = patternsearch(objfun,[2*mean(pd);5*mean(pd)],[],[],[],[],zeros(2,1),upperBounds);
smallS_Pattern = xStar(1); % smallS_Pattern = sSmall
bigS_Pattern = xStar(1)+xStar(2); % bigS_Pattern = sBig
fprintf(1,'Pattern Search: smallS = %.2f, bigS = %.2f\n', smallS_Pattern, bigS_Pattern);

% Use surrogate opt
xStar = surrogateopt(objfun,zeros(2,1),upperBounds);
smallS_Surrogate = xStar(1);
bigS_Surrogate = xStar(1)+xStar(2);
fprintf(1,'Surrogate Opt: smallS = %.2f, bigS = %.2f\n', smallS_Surrogate, bigS_Surrogate);