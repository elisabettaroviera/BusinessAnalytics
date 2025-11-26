%% 6- Aircraft capacity and tariffs
% Aircraft capacity and tariffs
cap = 100;
price1 = 400;
price2 = 200;
% Time horizon (days)
T = 60;

% Arrival rates (per day) for the two classes (true and estimated)
trueArrivalRate1 = 0.4; % Rate di arrivo vero
trueArrivalRate2 = 2.2;

% Questo è il rate stimato su cui prendere le decisioni
hatArrivalRate1 = 0.5; % Rate stimato, su cui prendi le decisioni
hatArrivalRate2 = 2;

% find protection level (NOTE: the number of first class passengers is 
% Poisson with a rate depending on the time horizon!)
protectionLevel = poissinv(1-price2/price1, hatArrivalRate1*T);

% state initialization
count1 = 0;   %number of accepted requests for each class
count2 = 0;
full = false;

% next event times
% Varibaile di stato -> quanti posti sono ancora disponibli
% Simulo sui rate giusti
% Prendo la decisione sui rate sbagliati
nextArrival1 = exprnd(1/trueArrivalRate1); % Poisson
nextArrival2 = exprnd(1/trueArrivalRate2);
stop = min(nextArrival1,nextArrival2) > T; % Condizione di STOP

% simulation loop
% Il loop va avanti fino a quando l'aereo non è pieno o l'aereo parte
while ~stop && ~full
    if nextArrival1 < nextArrival2
        clock = nextArrival1; % Aggiorno il clock al prossimo evento
        % serve class 1
        count1 = count1 + 1; % Proteggo la classe 1
        nextArrival1 = clock + exprnd(1/trueArrivalRate1);
    else
        clock = nextArrival2;
        % serve class 2
        if count2 < cap - protectionLevel % POtrei non vendere la classe 2
            count2 = count2 + 1;
        end
        nextArrival2 = clock + exprnd(1/trueArrivalRate2); % Scheduli il prossimo arrivo 
    end % main if
    if count1 + count2 >= cap % I posti sono finiti?
        full = true;
    end
    stop = min(nextArrival1,nextArrival2) > T; % l'aereo è decolaato?
end %while
fprintf(1,'Total profit %d\n', count1*price1 + count2*price2); % Stampo i risultati che mi interessano

% IMPROVEMENTS and further developments
% 1) Stop class 2 arrivals after protection level is reached; then just draw a
% Poisson variable for class 1.
% 2) Build a function, accepting generic rates, so that we can run multiple
% replications, and compare ideal profit (under a dynamic model) with the
% actual one, on a sound statistical basis.
% 3) You could also check against the ideal static model (no need for
% simulation).
% 4) Note that we take a quantile of the Poisson distribution, but this
% might be questionable. What should you do?