%% 2-EXTREMELY NAIVE script to simulate (s,S) periodic review policy
% L'obbiettivo è capire se la politica è buona oppure no -> ma cosa vuol
% dire buona o cattiva? Bisogna decidere una regola per capire se siamo
% soddisfatti o no

% Policy parameters
smallS = 50;
bigS = 100;

% Demand parameters -> Diamo per scontato una simulazione normale
mu = 60;
sigma = 10;

% Allocate sample path vectors
T = 50;                 % simulation horizon
onHand = zeros(T,1);    % on hand at beginning of period
aveOnHand = zeros(T,1); % average on hand in a period
lostSales = zeros(T,1); % Assunzione -> ho vendite perse
stockOut = NaN(T,1);    
ordered = zeros(T,1);   % at the end of period

% Sample demand scenario
demand = repmat(10,T,1); % Costruisce un vettore in cui la domanda è sempre 10 costamte
                         % è il caso semplice per debug per programma
% demand = normrnd(T,1,mu,sigma); % Qui non c'è la minima idea di
                                  % modularità
                                  % La deviazione standard non deve essere
                                  % molto grande altrimenti assumo anche
                                  % domande negative, che ovviamente non ha
                                  % senso

% Define system STATE -> non è detto che faccio partire il sistema vuoto
% Definisco lo stato inizale del sistema
endInv = bigS;     % state initialization
onOrder = 0;       % from past period

% simulation FOR loop -> SIMULAZIONE TEMPO DISCRETO: modello a tempo
% discreto, successione regolare, il tempo simulato avanza di delta_t
% sempre nello stesso modo
for t = 1:T
    onHand(t) = endInv+onOrder;   % deliver items -> livello di magazzino on hand
    if demand(t) <= onHand(t) % Confronto la domanda
        % no stockout
        stockOut(t) = false;
        lostSales(t) = 0;
        endInv = onHand(t) - demand(t); % All'inizio - quello che ho venduto
    else
        % stockout
        stockOut(t) = true;
        lostSales(t) = demand(t) - onHand(t); % Capisco qual è stata la vendita persa
        endInv = 0;
    end % if else to check stockout
    % to evaluate holding cost, take average
    aveOnHand(t) = (onHand(t)+endInv)/2;

    % Controllo il livello di magazzino
    if endInv <= smallS % Sottosoglia -> riodino
        % order
        onOrder = bigS - endInv;
        ordered(t) = onOrder;
    else % Altrimenti non riodino
        onOrder = 0;
        ordered(t) = 0;
    end
end  % end main simulation FOR loop
