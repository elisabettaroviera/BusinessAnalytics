%% 7- roll Queque -> Es 3 tema 03 2024
% Choose 1 minute as the time unit
lowTime = 1.5;   % bounds on time to prepare roll -> della distribuzione uniforme
highTime = 2;
maxPlaces = 6;   % buffer size
meanInterTime = 4;  % customer mean interarrival time and max demand -> tempo medio iterativo
maxDemand = 3;
count = 0;   % number of served customers
toServe = 1000;

% State
clock = 0;

% Ci sono due eventi
nextArrival = exprnd(meanInterTime); % nuovo arrivo
nextRoll = unifrnd(lowTime,highTime); % quanti panini ordina

buffer = 3; % say that now there are 3 rolls ready
blocked = false; % buffer is not empty
joinTime = []; % when a queued customer arrived and -> teniamo traccia dei tempi di attesa
residualDemand = []; 
totalWaitingTime = 0;

while count<= toServe
    if nextRoll <= nextArrival  % manage roll completion event -> qual è l'evento?
        clock = nextRoll;
        if length(residualDemand) > 0  % customer in queue, serve demand
            residualDemand(1) = residualDemand(1)-1;
            if residualDemand(1) == 0 % service completed
                totalWaitingTime = totalWaitingTime + (clock - joinTime(1));
                count = count + 1;
                % dequeue
                joinTime(1) = [];
                residualDemand(1) = [];
            end
        else % no customer, increase buffer count
            buffer = buffer+1;
        end
        if buffer == maxPlaces
            blocked = true;
            nextRoll = inf;
        else
            nextRoll = clock + unifrnd(lowTime,highTime);
        end
    else % manage customer arrival event
        clock = nextArrival;
        nextArrival = clock + exprnd(meanInterTime);
        demand = unidrnd(maxDemand); % V.A. uniforme
        if length(residualDemand) > 0 % join queue
            residualDemand(end+1) = demand; % == append in ultima posizione
            joinTime(end+1) = clock;
        else % no one in queue, grab some roll
            if buffer >= demand % nel buffer c'è quantità per soddisfare la domanda
                buffer = buffer - demand;
                count = count + 1; % waiting time is zero
            else % wait for more rolls
                demand = demand - buffer; % non è sufficiente
                buffer = 0;
                residualDemand(1) = demand;
                joinTime(1) = clock;
            end
            if blocked % unblock roll preparation
                blocked = false; % sblocco il sistema, si possono produrre altri panini
                nextRoll = clock + unifrnd(lowTime,highTime);
            end
        end
    end % main IF
end % while
fprintf(1,'average waiting time = %.2f\n', totalWaitingTime/count);


