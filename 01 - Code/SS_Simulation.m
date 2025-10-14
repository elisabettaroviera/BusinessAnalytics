%% 3a-Simulation of (s,S) periodic review policy
% La generazione degli scenari deve essere fatta al di fuori della
% funzione, per questo come input abbiamo demandScenarios
% Io vorrei minimizzare il costro totale rispetto ai parametri, perchè è
% questo il mio problema di ottimizzazione. Quindi la funzione deve
% restituirmi il totalCost
function [totalCost, freqStockout] = SS_Simulation(smallS, bigS, demandScenarios, ...
    initialStock, onHandCost, lostPenalty, unitCost, fixedCharge)
% onHandCost := costo di giacenza
% lostPenalty := valore per le vendite perse
% unitCost := costo di unità della merce
% fixedCharge := valore minimo di merce nel riordino

% allocate sample path vectors
% Note: scenarios are stored along ROWS
[numScenarios, T] = size(demandScenarios); % Ogni realizzazione dura T periodi e scegliamo un numero di scenari
% T è la durata di ogni scenario, deve essere abbastanza grande
% Se il processo stocastico è ERGODICO, fare una simulazione lunga è uguale
% a farne tante prima
% Un processo stocastico è ergodico se, osservandolo per un tempo sufficientemente lungo, la media temporale di una sua realizzazione coincide con la media sull’insieme delle possibili realizzazioni (media statistica o ensemble).
% In altre parole:
% Guardare un singolo sistema per molto tempo dà le stesse informazioni che osservare molti sistemi uguali in un dato istante.
totalCost = zeros(numScenarios,1);
freqStockout = zeros(numScenarios,1);
onHand = zeros(T,1);    % on hand at beginning of period
aveOnHand = zeros(T,1); % average on hand in a period
lostSales = zeros(T,1);
stockOut = NaN(T,1);
ordered = zeros(T,1);   % at the end of period
% for each replication = scenario
for k = 1:numScenarios
    % inititalize system state
    endInv = initialStock;    % intitial stock
    onOrder = 0;              % nothing in transit from past periods
    demand = demandScenarios(k,:);
    % single replication FOR loop
    for t = 1:T % è un for sul tempo
        onHand(t) = endInv+onOrder;   % deliver items
        if demand(t) <= onHand(t)
            % no stockout
            stockOut(t) = false;
            lostSales(t) = 0;
            endInv = onHand(t) - demand(t);
        else
            % stockout
            stockOut(t) = true;
            lostSales(t) = demand(t) - onHand(t);
            endInv = 0;
        end % if else to check stockout
        % to evaluate holding cost, take average
        aveOnHand(t) = (onHand(t)+endInv)/2;
        if endInv <= smallS
            % order
            onOrder = bigS - endInv;
            ordered(t) = onOrder;
        else
            onOrder = 0;
            ordered(t) = 0;
        end
    end  % end single replication FOR loop
    % Quantifico il costo, il k è la replicazione
    totalCost(k) = onHandCost*sum(aveOnHand) + lostPenalty*sum(lostSales) + ...
        unitCost*sum(ordered) + fixedCharge*sum(ordered>0);
    % fixedCharge è la variabile che ci dirà quindi se riordino oppure no
    % ordered>0 infatti tramite questo abbiamo un vettore booleano di
    % riordino o no
    freqStockout(k) = sum(lostSales>0)/T; % Dividere per una costante, non va a cambiare il punto di minimo
end % end overall FOR loop
