%% 3c- Test EOQ Script to optimize (s,S) parameters
% Controlliamo i risultti ottenuti con 3b
% Questo è uno dei modi per verificare che quanto fatto è giusto o
% sbagliato

% Economics
unitCost = 10;
onHandCost = 0.1*unitCost;
lostPenalty = 2*unitCost;
fixedCharge = 10000;

% Make inSample scenario
rng default
horizonInSample = 80000;
D = 5;
inSampleDemand = D*ones(1,horizonInSample);
EOQ = sqrt(2*D*fixedCharge/onHandCost)
initialStock = EOQ;

% Create objfun
objfun = @(x) mean(SS_Simulation(x(1), x(1)+x(2), inSampleDemand, ...
    initialStock, onHandCost, lostPenalty, unitCost, fixedCharge));
upperBounds = [100*initialStock;100*initialStock];

% Use pattern search
xStar = patternsearch(objfun,upperBounds,[],[],[],[],zeros(2,1),upperBounds);
smallS_Pattern = xStar(1);
bigS_Pattern = xStar(1)+xStar(2);
fprintf(1,'Pattern Search: smallS = %.2f, bigS = %.2f\n', smallS_Pattern, bigS_Pattern);
