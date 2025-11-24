%% 4b- M/M/1 queue with balking (function version)
function lost = MM1_Balking(arrivalRate,serviceRate,toServe)

% state initialization
state.numInQueue = 0;   % we also count the customer being served
state.count = 0;   %number of served customers
state.lost = 0;    % number of lost customers due to balking
state.clock = 0;

% next event times
state.nextCompletion = inf;
state.nextArrival = exprnd(1/arrivalRate);
% Si potrebbe essere più flessibile e usare una lista di stati 
% magari con puntatori (per inserire seguendo la precedenza)
% Bisognerebbe definire classi e metodi all'interno per incapsulare
% la programmazione e la gestione
while state.count<= toServe % Ci sono due eventi possibili, quindi
                            % posso usare un if-else
    % Cliente a fine servizio
    if state.nextCompletion <= state.nextArrival
        state.clock = state.nextCompletion;
        state = manageService(state);
    else 
        state.clock = state.nextArrival;
        state = manageArrival(state); % Bisognerebbe definire una classe 
           % evento astratta e poi tutte le classi specifiche per i vari
           % eventi che si possono realizzare
    end 
end 
lost = state.lost;

% Nested functions
    function state = manageService(state) % manage service completion
        state.count = state.count + 1;
        if state.numInQueue == 0
            % get idle
            state.nextCompletion = inf;
        else
            % pick a customer from the queue
            state.numInQueue = state.numInQueue - 1;
            state.nextCompletion = state.clock + exprnd(1/serviceRate);
        end
    end % manageService

    function state = manageArrival(state)
        if state.numInQueue == 0
            % server idle, immediate start of service
            state.numInQueue = 1;
            state.nextCompletion = state.clock + exprnd(1/serviceRate);
        elseif state.numInQueue < 10
            % enqueue customer for sure
            state.numInQueue = state.numInQueue + 1;
        elseif state.numInQueue <= 15
            % enqueue customer with 50% probability
            if rand > 0.5
                % balk
                state.lost = state.lost + 1;
            else
                % enqueue customer
                state.numInQueue = state.numInQueue + 1;
            end
        else % more than 15 customers!
            % balk
            state.lost = state.lost + 1;
        end
        % schedule next arrival
        state.nextArrival = state.clock + exprnd(1/arrivalRate);
    end

end % main function