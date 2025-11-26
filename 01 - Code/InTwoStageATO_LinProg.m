%% 5a - Two Stages ATP int Lin Prog
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
demand = [   % Scenari di domanda
    100 50 120 
     50 25 60 
    100 110 60 ];
probs = ones(numScenarios,1)/numScenarios;
demandAverage = mean(demand,2);

% AVERAGE DEMAND MODEL (integer vars)
% Decision variables are [make; sell] 
% Objective function
objCoeff = [compCost; -endPrice]; % note the change in sign !
% lower and upper bounds
lb = zeros(numComp+numItems,1);
ub = [repmat(Inf,numComp,1); demandAverage];
% Si costruiscono le matrici dei vincoli piano piano
% component inequalities
A1 = [-eye(numComp), gozinto'];
b1 = zeros(numComp,1);
% machine inequalities
A2 = [needRes', zeros(numResources,numItems)]; 
b2 = availRes;
% put matrices together
A = [A1;A2];
b = [b1;b2];
% Solve model
[xVar, aux] = intlinprog(objCoeff,1:length(objCoeff),A,b,[],[],lb,ub)
profit = -aux;
display(xVar);
display(profit);

% STOCHASTIC DEMAND MODEL (continuous vars)
% Decision variables are [make; sell_1; ....; sell_S] 
% Objective function
objCoeff = [compCost]; % note the change in sign !
for s=1:numScenarios
    objCoeff=[objCoeff; -probs(s)*endPrice];
end
% lower and upper bounds
lb = zeros(numComp+numScenarios*numItems,1);
ub = [repmat(Inf,numComp,1); reshape(demand,numItems*numScenarios,1)];
% setup coefficient matrix
A = zeros(numResources+numScenarios*numComp, numComp+numScenarios*numItems);
% machine inequalities
A(1:numResources, 1:numComp) = needRes';
% component inequalities
baseRow = numResources;
baseCol = numComp;
for s=1:numScenarios % Modello stocastica con struttura a blocchi della matrice del problema a due stadi
    A(baseRow+(1:numComp), 1:numComp) = -eye(numComp);
    A(baseRow+(1:numComp), baseCol+(1:numItems)) = gozinto';
    baseRow = baseRow + numComp;
    baseCol = baseCol + numItems;
end
% setup RHS
b = [availRes; zeros(numScenarios*numComp,1)];
% Solve model
[xVarS, aux] = intlinprog(objCoeff,1:length(objCoeff),A,b,[],[],lb,ub);
profitS = -aux;
display(xVarS);
display(profitS);



