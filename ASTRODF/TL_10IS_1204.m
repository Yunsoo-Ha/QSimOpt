%% Traffic light problem
% INPUTS
% x: a column vector equaling the decision variables theta
% runlength: the number of longest paths to simulate
% problemRng: a cell array of RNG streams for the simulation model 
% seed: the index of the first substream to use (integer >= 1)

% RETURNS: fn (total profit from making road improvements), FnVar
clear;
clc;
%% #1
x1 = 0:1:0;
x2 = 0:1:120;

Macro_rep = 1;
y_total = zeros(length(x1),length(x2));

for q = 1:Macro_rep 
    for wtsim1 = 1:length(x1)

        s = RandStream('mt19937ar','Seed', q);
        RandStream.setGlobalStream(s);

        T=5000; %length of simulation time
        NumInt = 10; %number of intersections

        % Decidion variable - offset.
        OS1 = x1(wtsim1);

        % 이 람다가 앱스트랙 제출한 람다
        lambda =  1.5; % Arrival rate
        SIGT = 40;
        SGT = 60 - SIGT;
        %lambda =  1/75; % Arrival rate

        % GreenLight On 이 현재 어떤 상태인지 알아내는 코드 필요
         
        for i = 1:NumInt
            if i == 1
                GT(i) = 60 + (i-1)*OS1;
                IGT(i) = SIGT + (i-1)*OS1;
            else
                GT(i) = 60 + OS1;
                IGT(i) = SIGT + OS1;
            end
            
            G_on(3*i-1) = 0;
            G_on(3*i-2) = 0;
            G_on(3*i) = 1;
            while 1        
                if GT(i) - 60 >= 0 
                    GT(i) = GT(i) - 60;
                else
                    break
                end
                if IGT(i) - 60 >= 0 
                    IGT(i) = IGT(i) - 60;
                else
                    break
                end
            end

            if GT(i) == 0 
                G_on(3*i-1) = 0;
                G_on(3*i-2) = 0;
                G_on(3*i) = 1;
            elseif GT(i) <= SIGT
                G_on(3*i-1) = 1;
                G_on(3*i-2) = 1;
                G_on(3*i) = 0;
            else
                G_on(3*i-1) = 0;
                G_on(3*i-2) = 0;
                G_on(3*i) = 1;
            end
        end

        %time -- 10 mile/hour → 0.17 mile/min → 0.1 miles takes about 35 secs
        %     0.05 miles → 1 min == 17.5 secs
        %     0.1 miles → 2 min == 35 secs
        %     Average car length: 4.7 m → 5 m
        %     Safety distance: 3 m 
        %     Hence, capacity become each 20 and 10.
        % 20대 지나는데 35초 
        % T1은 2대 지나는데 걸리는 시간.
        % T2는 T1 + 0.5

        T1 = 2;
        T2 = 2.5;
        Travel_time1 = 35;
        delay = 0.1;
        TVTpV = 35/20;

        % Phase order - Using only straight line
        for i = 1:3*NumInt
            Q_exist(i) = 0;
            Q{i} = [];
            QA{i} = [];
            QD{i} = [];
            Q_NoA{i} = [];
            QD_tempt{i} = [];
            Q_NoD{i} = [];
            nQ(i) = 0;
            binary_on(i) = 0;
        end

        % Distance 
        DM = [0 1 Inf 1 inf inf inf inf inf inf;
            inf 0 1 Inf inf inf inf inf inf inf;
            inf 1 0 1 inf 1 inf inf inf inf;
            1 Inf inf 0 1 inf inf inf inf inf;
            inf inf inf 1 0 1 inf 1 inf inf;
            inf inf 1 inf inf 0 1 inf inf inf;
            inf inf inf inf inf 1 0 1 inf 1;
            inf inf inf inf 1 inf inf 0 1 inf;
            inf inf inf inf inf inf inf 1 0 1;
            inf inf inf inf inf inf 1 inf inf 0];

        next = [1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;
                1 2 3 4 5 6 7 8 9 10;];

        for k = 1:10
            for i = 1:10
                for j = 1:10
                    if DM(i,j) > DM(i,k) + DM(k,j)
                        DM(i,j) = DM(i,k) + DM(k,j);
                        next(i,j) = next(i,k);
                    end
                end
            end
        end


        WT = [];

        t = 0;

        quelength = 0;
        NumArr = 1;

        nAE = 1;
        nAI = 0;

        Vdict = struct('Node_A', [],'Node_D', [],'tA', [], 'tDend', [], 'nAE',nAE);
        tA = -log(rand)/(NumArr*lambda); 
        tD = inf;

        % UPDATE ALL ARRIVING CARS
        while t < T    
            t = min([tA tD min(GT) min(IGT)]); 

            % External arrival 
            if t == tA

                tA = t-log(rand)/(NumArr*lambda); 

                ExternalA = [1 2 5 7 13 19 25 27 30];
            
                %시작지 설정
                i = floor(9*rand(1)+1);
                i = ExternalA(i);

                if i == 1 || i == 2
                    x = 1;
                elseif i == 5
                    x = 2;
                elseif i == 7 
                    x = 3;
                elseif i == 13
                    x = 5;
                elseif i == 19
                    x = 7;
                elseif i == 25 || i == 27
                    x = 9;
                elseif i == 30
                    x = 10;
                end

                y = floor(10*rand(1)+1);
                %y = 2;
                P = PathF(x,y,next) + 30;
                Path = [i];

                if length(P) == 1
                else
                    for j = 2:length(P)
                        if P(j) - P(j-1) == 1 && mod(Path(j-1),2) == 0
                            if mod(P(j-1),2) == 0
                                Path = [Path Path(j-1)+4];
                            else
                                Path = [Path Path(j-1)+2];
                            end     
                        elseif P(j) - P(j-1) == 1 && mod(Path(j-1),2) == 1
                            if mod(Path(j-1),3) == 0
                                Path = [Path Path(j-1)+1];
                            else
                                Path = [Path Path(j-1)+3];
                            end
                        elseif P(j) - P(j-1) == -1 && mod(Path(j-1),3) == 1
                            Path = [Path Path(j-1)-1];
                        elseif P(j) - P(j-1) == -1 && mod(Path(j-1),3) == 0
                            Path = [Path Path(j-1)-3];
                        elseif P(j) - P(j-1) == 3 && mod(Path(j-1),2) == 0
                            Path = [Path Path(j-1)+9];
                        elseif P(j) - P(j-1) == 3 && mod(Path(j-1),2) == 1
                            Path = [Path Path(j-1)+10];
                        elseif P(j) - P(j-1) == -3 && mod(Path(j-1),3) == 0
                            Path = [Path Path(j-1)-9];
                        elseif P(j) - P(j-1) == -3 && mod(Path(j-1),3) == 1
                            Path = [Path Path(j-1)-7];
                        end
                    end
                end
                Path = [Path 31];

                Q_exist(i) = 1;
                Q{i} = [Q{i} t];
                QA{i} = [QA{i} [t nAE]'];
                %QA{i} = [QA{i}; nAE];
                Q_NoA{i} = [Q_NoA{i} i];
                Q_NoD{i} = [Q_NoD{i} Path(2)];
                nQ(i) = nQ(i) + 1;

                Vdict.Node_A = [Vdict.Node_A i];
                Vdict.Node_D = [Vdict.Node_D Path(2)];
                PATH{nAE} = Path;
                %Vdict.Node_D(nAE,:) = [Path];
                %Vdict.Path{len(Vdict.Node_A)} = Path;
                Vdict.tA = [Vdict.tA t];
                nAE = nAE + 1;

                % at first, check Green light on
                if binary_on(i) == 0 && G_on(i) == 1
                    j = length(QD_tempt{i}) + length(Q{i});
                    if j == 1
                        if mod(i,3) == 0 && t+T1 < IGT((i)/3)
                            QD_tempt{i} = [QD_tempt{i} t+T1];
                            QD{i} = [QD{i} t+T1];
                            %QD{i} = [QD{i} [t+T1 nAE]'];
                            Q{i}(end) = [];
                        elseif mod(i,3) == 2 && t+T1 < IGT(i/3 + 1/3)
                            QD_tempt{i} = [QD_tempt{i} t+T1];
                            QD{i} = [QD{i} t+T1];
                            %QD{i} = [QD{i} [t+T1 nAE]'];
                            Q{i}(end) = [];
                        elseif mod(i,3) == 1 && t+T1 < GT(i/3 + 2/3)
                            QD_tempt{i} = [QD_tempt{i} t+T1];
                            QD{i} = [QD{i} t+T1];
                            %QD{i} = [QD{i} [t+T1 nAE]'];
                            Q{i}(end) = [];
                        end
                    else
                        if mod(i,3) == 0 && t+T2+(j-1)*TVTpV < IGT((i)/3)
                            QD_tempt{i} = [QD_tempt{i} t+T2+(j-1)*TVTpV];
                            QD{i} = [QD{i} t+T2+(j-1)*TVTpV];
                            %QD{i} = [QD{i} [t+T2+(j-1)*TVTpV nAE]'];
                            Q{i}(end) = [];
                        elseif mod(i,3) == 2 && t+T2+(j-1)*TVTpV < IGT(i/3 + 1/3)
                            QD_tempt{i} = [QD_tempt{i} t+T2+(j-1)*TVTpV];
                            QD{i} = [QD{i} t+T2+(j-1)*TVTpV];
                            %QD{i} = [QD{i} [t+T2+(j-1)*TVTpV nAE]'];
                            Q{i}(end) = [];
                        elseif mod(i,3) == 1 && t+T2+(j-1)*TVTpV < GT(i/3 + 2/3)
                            QD_tempt{i} = [QD_tempt{i} t+T2+(j-1)*TVTpV];
                            QD{i} = [QD{i} t+T2+(j-1)*TVTpV];
                            %QD{i} = [QD{i} [t+T2+(j-1)*TVTpV nAE]'];
                            Q{i}(end) = [];
                        end
                    end
                end

            elseif t == tD
                for z = 1:3*NumInt
                    if tD == min(QD_tempt{z})
                        tempt = z;
                        break
                    end
                end
                I = tempt;

                % 몇 번째 들어온 차인지 찾기
                Z = QA{I}(2,find(QD{I} == tD));
                for i = 1:length(PATH{Z})
                    if PATH{Z}(i) == I
                        J = PATH{Z}(i+1);
                        break
                    end
                end

                QD_tempt{I}(1) = [];

                if J == 31
                    Vdict.tDend = [Vdict.tDend [tD Z]'];
                else            
                    j = length(QA{J})-length(QD{J});
                    Q_exist(J) = 1;
                    if isempty(QA{J}) == 0
                        if t+Travel_time1-j*TVTpV < max(QA{J}(1,:))
                            Q{J} = [Q{J} max(QA{J}(1,:))+0.1];
                            QA{J} = [QA{J} [max(QA{J}(1,:))+0.1 Z]'];
                            nQ(J) = nQ(J) + 1;  
                        else
                            Q{J} = [Q{J} t+Travel_time1-j*TVTpV];
                            QA{J} = [QA{J} [t+Travel_time1-j*TVTpV Z]'];
                            nQ(J) = nQ(J) + 1; 
                        end
                    else
                        Q{J} = [Q{J} t+Travel_time1-j*TVTpV];
                        QA{J} = [QA{J} [t+Travel_time1-j*TVTpV Z]'];
                        nQ(J) = nQ(J) + 1; 
                    end
                    Q_NoA{J} = [Q_NoA{J} I];
                    Q_NoD{I} = [Q_NoD{I} J];

                    nAI = nAI + 1;
                 end

            elseif t == min(GT)
                [~,I] = min(GT);
                G_on(3*I) = 1;
                G_on(3*I-1) = 1;
                G_on(3*I-2) = 0;
                %binary_on(I) = 1;

                if isempty(Q{3*I}) == 0 
                    IND1 = 0;
                    if Q{3*I}(1) <= GT(I) + SIGT
                        for j = 1:length(Q{3*I})
                            if GT(I)+T2+(j-1)*TVTpV + (j-1)*delay > GT(I) + SIGT
                                CHECK = 1;
                                break
                            end

                            if isempty(Q{3*I}) == 0
                                if GT(I)+T2+(j-1)*TVTpV + (j-1)*delay <= Q{3*I}(1) + 2.5 || IND1 == 1
                                    IND1 = 1;
                                    % 앞에 차 몇대 있나?
                                    Num_Q = length(QD{3*I}(QD{3*I}>Q{3*I}(1)));
                                    if Q{3*I}(1)+T1 <= GT(I) + SIGT && Num_Q == 0 
                                        QD_tempt{3*I} = [QD_tempt{3*I} Q{3*I}(1)+T1];
                                        QD{3*I} = [QD{3*I} Q{3*I}(1)+T1];
                                        Q{3*I}(1) = [];
                                    elseif Q{3*I}(1)+T2+Num_Q*TVTpV <= GT(I) + SIGT
                                        QD_tempt{3*I} = [QD_tempt{3*I} Q{3*I}(1)+T2+Num_Q*TVTpV];
                                        QD{3*I} = [QD{3*I} Q{3*I}(1)+T2+Num_Q*TVTpV];
                                        Q{3*I}(1) = [];
                                    end

                                else

                                    QD_tempt{3*I} = [QD_tempt{3*I} GT(I)+T2+(j-1)*TVTpV+(j-1)*delay];
                                    QD{3*I} = [QD{3*I} GT(I)+T2+(j-1)*TVTpV+(j-1)*delay];
                                    Q{3*I}(1) = [];
                                end
                            end


                        end
                    end
                end

                if isempty(Q{3*I-1}) == 0 
                    IND2 = 0;
                    if Q{3*I-1}(1) <= GT(I) + SIGT
                        for j = 1:length(Q{3*I-1})
                            if GT(I)+T2+(j-1)*TVTpV + (j-1)*delay > GT(I) + SIGT
                                CHECK = 1;
                                break
                            end

                            if isempty(Q{3*I-1}) == 0
                                if GT(I)+T2+(j-1)*TVTpV + (j-1)*delay <= Q{3*I-1}(1) + 2.5 || IND2 == 1
                                    IND2 = 1;
                                    % 앞에 차 몇대 있나?
                                    Num_Q = length(QD{3*I-1}(QD{3*I-1}>Q{3*I-1}(1)));
                                    if Q{3*I-1}(1)+T1 <= GT(I) + SIGT && Num_Q == 0 
                                        QD_tempt{3*I-1} = [QD_tempt{3*I-1} Q{3*I-1}(1)+T1];
                                        QD{3*I-1} = [QD{3*I-1} Q{3*I-1}(1)+T1];
                                        Q{3*I-1}(1) = [];
                                    elseif Q{3*I-1}(1)+T2+Num_Q*TVTpV <= GT(I) + SIGT 
                                        QD_tempt{3*I-1} = [QD_tempt{3*I-1} Q{3*I-1}(1)+T2+Num_Q*TVTpV];
                                        QD{3*I-1} = [QD{3*I-1} Q{3*I-1}(1)+T2+Num_Q*TVTpV];
                                        Q{3*I-1}(1) = [];
                                    end

                                else

                                    QD_tempt{3*I-1} = [QD_tempt{3*I-1} GT(I)+T2+(j-1)*TVTpV+(j-1)*delay];
                                    QD{3*I-1} = [QD{3*I-1} GT(I)+T2+(j-1)*TVTpV+(j-1)*delay];
                                    Q{3*I-1}(1) = [];
                                end
                            end


                        end
                    end
                end
                GT(I) = GT(I) + 60;
   
            elseif t == min(IGT)        
                [~,I] = min(IGT);
                G_on(3*I-2) = 1;
                G_on(3*I-1) = 0;
                G_on(3*I) = 0;
                IND = 0;
                Num = 1;

                if isempty(Q{3*I-2}) == 0 
                    if Q{3*I-2}(1) <= IGT(I) + SGT
                        for j = 1:length(Q{3*I-2})
                            if IGT(I)+T2+(j-1)*TVTpV + (j-1)*delay > IGT(I) + SGT
                                break
                            end
                            if isempty(Q{3*I-2}) == 0
                                if IGT(I)+T2+(j-1)*TVTpV + (j-1)*delay <= Q{3*I-2}(1) + 2.5 || IND == 1
                                    IND = 1;

                                    % 앞에 차 몇대 있나?
                                    Num_Q = length(QD{3*I-2}(QD{3*I-2}>Q{3*I-2}(1)));
                                    if Q{3*I-2}(1)+T1 <= IGT(I) + SGT && Num_Q == 0 
                                        QD_tempt{3*I-2} = [QD_tempt{3*I-2} Q{3*I-2}(1)+T1];
                                        QD{3*I-2} = [QD{3*I-2} Q{3*I-2}(1)+T1];
                                        Q{3*I-2}(1) = [];
                                    elseif Q{3*I-2}(1)+T2+Num_Q*TVTpV <= IGT(I) + SGT
                                        QD_tempt{3*I-2} = [QD_tempt{3*I-2} Q{3*I-2}(1)+T2+Num_Q*TVTpV];
                                        QD{3*I-2} = [QD{3*I-2} Q{3*I-2}(1)+T2+Num_Q*TVTpV];
                                        Q{3*I-2}(1) = [];
                                    end

                                else

                                    QD_tempt{3*I-2} = [QD_tempt{3*I-2} IGT(I)+T2+(j-1)*TVTpV + (j-1)*delay];
                                    QD{3*I-2} = [QD{3*I-2} IGT(I)+T2+(j-1)*TVTpV + (j-1)*delay];
                                    Q{3*I-2}(1) = [];
                                end
                            end
                        end
                    end
                end    

                IGT(I) = IGT(I) + 60;
            end

            tD = min([QD_tempt{1:end}]);
        end

            cycletime = [];
            for i = 100:length(Vdict.tDend(1,:))
                cycletime = [cycletime Vdict.tDend(1,i) - Vdict.tA(Vdict.tDend(2,i))];
            end
             
            result(q,wtsim1) = mean(cycletime);
    end
end
y_total = y_total/Macro_rep;
%%
Result = mean(result);
figure
plot(x1,result)
%contour(x1,x2,y_total)

%%

function path = PathF(u,v, next)
    path = [u];
    while u ~= v
        u = next(u,v);
        path = [path u];
    end
end

