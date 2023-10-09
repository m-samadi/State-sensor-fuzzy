% Simulation of the Fuzzy Active Sleep method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
InitialNodeEnergy=2;
RoundsOutputSelect=3; % OutputSelect (Total=1, Random=2, both=3)

RoundCount=1000000;
ShowRandom_ShowSequential_StartNumber=15;
ShowRandom_ShowSequential_StepNumber=10;
ShowRandom_ShowSequential_FinishNumber=45;
ShowRandom_StepNumber=500;
TotalRoundList=zeros(RoundCount,9); % 1: RoundNumber | 2: Minimum distance between nodes | 3: Maximum distance between nodes | 4: Average distance between nodes | 5: Average remaining energy of the nodes | 6: Total consumption energy of the nodes | 7: Average consumption energy of the nodes | 8: Live nodes count | 9: Dead nodes count
TotalRoundList_Index=0;
RandomRoundList=zeros(RoundCount,9); % 1: RoundNumber | 2: Minimum distance between nodes | 3: Maximum distance between nodes | 4: Average distance between nodes | 5: Average remaining energy of the nodes | 6: Total consumption energy of the nodes | 7: Average consumption energy of the nodes | 8: Live nodes count | 9: Dead nodes count
RandomRoundList_Index=0;
RandomRoundList_Flag=zeros(RoundCount,1);

Network_Length=200;
Network_Width=200;

NodeNumber=40;
NodeList=zeros(NodeNumber,9); % ID | X | Y | RemainingEnergy | Data | Dead RandomRound | ActiveSleep: 1=Active, 0=Sleep | Section Number | Number of Active State
MaximumTemperatureValue=40;
NodeSenseIntervalTime=10;
SendNodeDataIntervalTime=5;
ChangeActiveSleepIntervalTime=25;

Sink_X=100;
Sink_Y=100;
SinkBufferSize=10000;
Sink=[Sink_X Sink_Y]; % X | Y
SinkBuffer=zeros(1:SinkBufferSize,1);
SinkBuffer_Index=0;
SendSinkAggregatedDataIntervalTime=20;

BaseStation_X=500;
BaseStation_Y=500;
BaseStationBufferSize=10000;
BaseStation=[BaseStation_X BaseStation_Y]; % X | Y
BaseStationBuffer=zeros(1:BaseStationBufferSize,1);
BaseStationBuffer_Index=0;

RemainingEnergy_ShapeFactor=InitialNodeEnergy;
NumberOfActiveState_ShapeFactor=360;
SelectionPriority_ShapeFactor=100;

RemainingEnergy_Type='b';
NumberOfActiveState_Type='i';
SelectionPriority_Type='b';

PacketSize=30000;
NodeThresholdEnergy=5*(10^(-9))*PacketSize;
RoundAverageRemainingEnergy=zeros(RoundCount,2);
d0=87.7;





%%%%% Membership functions of the fuzzy decision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Input fuzzy
InputFuzzy_Number=50;
%%% Remaining energy
MaximumRemainingEnergy=InitialNodeEnergy;
U_RemainingEnergy=0:(MaximumRemainingEnergy/(InputFuzzy_Number-1)):MaximumRemainingEnergy;
Interval=1:floor(length(U_RemainingEnergy)/4):length(U_RemainingEnergy);
% VeryLow
Crisp=U_RemainingEnergy(Interval(1));
Type='i';
ShapeFactor=round(MaximumRemainingEnergy*(160/200));
mu_RemainingEnergy_VeryLow=fuzzifysn(U_RemainingEnergy,Crisp,Type,ShapeFactor);
% Low
Crisp=U_RemainingEnergy(Interval(2));
Type='i';
ShapeFactor=round(MaximumRemainingEnergy*(180/200));
mu_RemainingEnergy_Low=fuzzifysn(U_RemainingEnergy,Crisp,Type,ShapeFactor);
% Middle
Crisp=U_RemainingEnergy(Interval(3));
Type='i';
ShapeFactor=round(MaximumRemainingEnergy*(140/200));
mu_RemainingEnergy_Middle=fuzzifysn(U_RemainingEnergy,Crisp,Type,ShapeFactor);
% High
Crisp=U_RemainingEnergy(Interval(4));
Type='i';
ShapeFactor=round(MaximumRemainingEnergy*(120/200));
mu_RemainingEnergy_High=fuzzifysn(U_RemainingEnergy,Crisp,Type,ShapeFactor);
% VeryHigh
Crisp=U_RemainingEnergy(Interval(5));
Type='i';
ShapeFactor=round(MaximumRemainingEnergy*(200/200));
mu_RemainingEnergy_VeryHigh=fuzzifysn(U_RemainingEnergy,Crisp,Type,ShapeFactor);

%%% Number of active state
MaximumActiveState=360;
U_NumberOfActiveState=0:(MaximumActiveState/(InputFuzzy_Number-1)):MaximumActiveState;
Interval=1:floor(length(U_NumberOfActiveState)/4):length(U_NumberOfActiveState);
% VeryFew
Crisp=U_NumberOfActiveState(Interval(1));
Type='i';
ShapeFactor=round(MaximumActiveState*(50/50));
mu_NumberOfActiveState_VeryFew=fuzzifysn(U_NumberOfActiveState,Crisp,Type,ShapeFactor);
% Few
Crisp=U_NumberOfActiveState(Interval(2));
Type='i';
ShapeFactor=round(MaximumActiveState*(35/50));
mu_NumberOfActiveState_Few=fuzzifysn(U_NumberOfActiveState,Crisp,Type,ShapeFactor);
% Middle
Crisp=U_NumberOfActiveState(Interval(3));
Type='i';
ShapeFactor=round(MaximumActiveState*(40/50));
mu_NumberOfActiveState_Middle=fuzzifysn(U_NumberOfActiveState,Crisp,Type,ShapeFactor);
% Many
Crisp=U_NumberOfActiveState(Interval(4));
Type='i';
ShapeFactor=round(MaximumActiveState*(45/50));
mu_NumberOfActiveState_Many=fuzzifysn(U_NumberOfActiveState,Crisp,Type,ShapeFactor);
% VeryMany
Crisp=U_NumberOfActiveState(Interval(5));
Type='i';
ShapeFactor=round(MaximumActiveState*(30/50));
mu_NumberOfActiveState_VeryMany=fuzzifysn(U_NumberOfActiveState,Crisp,Type,ShapeFactor);

%%%%% Output fuzzy
OutputFuzzy_Number=50;
%%% Selection priority
MaximumPriority=100;
U_SelectionPriority=0:(MaximumPriority/(OutputFuzzy_Number-1)):MaximumPriority;
Interval=1:floor(length(U_SelectionPriority)/4):length(U_SelectionPriority);
% VeryLow
Crisp=U_SelectionPriority(Interval(1));
Type='b';
ShapeFactor=30;
mu_SelectionPriority_VeryLow=fuzzifysn(U_SelectionPriority,Crisp,Type,ShapeFactor);
% Low
Crisp=U_SelectionPriority(Interval(2));
Type='b';
ShapeFactor=20;
mu_SelectionPriority_Low=fuzzifysn(U_SelectionPriority,Crisp,Type,ShapeFactor);
% Middle
Crisp=U_SelectionPriority(Interval(3));
Type='b';
ShapeFactor=10;
mu_SelectionPriority_Middle=fuzzifysn(U_SelectionPriority,Crisp,Type,ShapeFactor);
% High
Crisp=U_SelectionPriority(Interval(4));
Type='b';
ShapeFactor=20;
mu_SelectionPriority_High=fuzzifysn(U_SelectionPriority,Crisp,Type,ShapeFactor);
% VeryHigh
Crisp=U_SelectionPriority(Interval(5));
Type='b';
ShapeFactor=40;
mu_SelectionPriority_VeryHigh=fuzzifysn(U_SelectionPriority,Crisp,Type,ShapeFactor);





%%%%% Fuzzy rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Rule 1
mu_ABCD=fuzzyand(mu_RemainingEnergy_VeryHigh,mu_NumberOfActiveState_VeryFew);
R1=rulemakem(mu_ABCD,mu_SelectionPriority_VeryHigh);
%%% Rule 2
mu_ABCD=fuzzyand(mu_RemainingEnergy_High,mu_NumberOfActiveState_Few);
R2=rulemakem(mu_ABCD,mu_SelectionPriority_High);
%%% Rule 3
mu_ABCD=fuzzyand(mu_RemainingEnergy_Middle,mu_NumberOfActiveState_Middle);
R3=rulemakem(mu_ABCD,mu_SelectionPriority_Middle);
%%% Rule 4
mu_ABCD=fuzzyand(mu_RemainingEnergy_VeryHigh,mu_NumberOfActiveState_VeryMany);
R4=rulemakem(mu_ABCD,mu_SelectionPriority_Low);
%%% Rule 5
mu_ABCD=fuzzyand(mu_RemainingEnergy_High,mu_NumberOfActiveState_Many);
R5=rulemakem(mu_ABCD,mu_SelectionPriority_Low);
%%% Rule 6
mu_ABCD=fuzzyand(mu_RemainingEnergy_Low,mu_NumberOfActiveState_VeryMany);
R6=rulemakem(mu_ABCD,mu_SelectionPriority_Low);
%%% Rule 7
mu_ABCD=fuzzyand(mu_RemainingEnergy_VeryLow,mu_NumberOfActiveState_Few);
R7=rulemakem(mu_ABCD,mu_SelectionPriority_High);
%%% Rule 8
mu_ABCD=fuzzyand(mu_RemainingEnergy_Low,mu_NumberOfActiveState_VeryFew);
R8=rulemakem(mu_ABCD,mu_SelectionPriority_High);
%%% Rule 9
mu_ABCD=fuzzyand(mu_RemainingEnergy_Middle,mu_NumberOfActiveState_Many);
R9=rulemakem(mu_ABCD,mu_SelectionPriority_Low);
%%% Rule 10
mu_ABCD=fuzzyand(mu_RemainingEnergy_VeryHigh,mu_NumberOfActiveState_Middle);
R10=rulemakem(mu_ABCD,mu_SelectionPriority_VeryLow);

%%% Aggregation of rules 
R=totalrule(R1,R2,R3,R4,R5,R6,R7,R8,R9,R10);





%%%%% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Node
for i=1:NodeNumber
    NodeList(i,1)=i;
    NodeList(i,4)=InitialNodeEnergy;  
end;
%
NodeList(1,2)=19;  
NodeList(1,3)=24;

NodeList(2,2)=23;  
NodeList(2,3)=1;

NodeList(3,2)=4;  
NodeList(3,3)=6;

NodeList(4,2)=82;  
NodeList(4,3)=34;

NodeList(5,2)=78;  
NodeList(5,3)=12;

NodeList(6,2)=34;  
NodeList(6,3)=78;
 
NodeList(7,2)=23;  
NodeList(7,3)=56;

NodeList(8,2)=1;  
NodeList(8,3)=9;

NodeList(9,2)=34;  
NodeList(9,3)=87;

NodeList(10,2)=34;  
NodeList(10,3)=78;

NodeList(11,2)=119;  
NodeList(11,3)=24;

NodeList(12,2)=123;  
NodeList(12,3)=1;

NodeList(13,2)=104;  
NodeList(13,3)=6;

NodeList(14,2)=182;  
NodeList(14,3)=34;

NodeList(15,2)=178;  
NodeList(15,3)=12;

NodeList(16,2)=134;  
NodeList(16,3)=78;
 
NodeList(17,2)=123;  
NodeList(17,3)=56;

NodeList(18,2)=101;  
NodeList(18,3)=9;

NodeList(19,2)=134;  
NodeList(19,3)=87;

NodeList(20,2)=134;  
NodeList(20,3)=78;

NodeList(21,2)=19;  
NodeList(21,3)=124;

NodeList(22,2)=23;  
NodeList(22,3)=101;

NodeList(23,2)=4;  
NodeList(23,3)=106;

NodeList(24,2)=82;  
NodeList(24,3)=134;

NodeList(25,2)=78;  
NodeList(25,3)=112;

NodeList(26,2)=34;  
NodeList(26,3)=178;
 
NodeList(27,2)=23;  
NodeList(27,3)=156;

NodeList(28,2)=1;  
NodeList(28,3)=109;

NodeList(29,2)=34;  
NodeList(29,3)=187;

NodeList(30,2)=34;  
NodeList(30,3)=178;

NodeList(31,2)=119;  
NodeList(31,3)=124;

NodeList(32,2)=123;  
NodeList(32,3)=101;

NodeList(33,2)=104;  
NodeList(33,3)=106;

NodeList(34,2)=182;  
NodeList(34,3)=134;

NodeList(35,2)=178;  
NodeList(35,3)=112;

NodeList(36,2)=134;  
NodeList(36,3)=178;
 
NodeList(37,2)=123;  
NodeList(37,3)=156;

NodeList(38,2)=101;  
NodeList(38,3)=109;

NodeList(39,2)=134;  
NodeList(39,3)=187;

NodeList(40,2)=134;  
NodeList(40,3)=178;
%
NodeList(1,8)=1;
NodeList(2,8)=1;
NodeList(3,8)=1;
NodeList(4,8)=1;
NodeList(5,8)=1;
NodeList(6,8)=1;
NodeList(7,8)=1;
NodeList(8,8)=1;
NodeList(9,8)=1;
NodeList(10,8)=1;
NodeList(11,8)=2;
NodeList(12,8)=2;
NodeList(13,8)=2;
NodeList(14,8)=2;
NodeList(15,8)=2;
NodeList(16,8)=2;
NodeList(17,8)=2;
NodeList(18,8)=2;
NodeList(19,8)=2;
NodeList(20,8)=2;
NodeList(21,8)=3;
NodeList(22,8)=3;
NodeList(23,8)=3;
NodeList(24,8)=3;
NodeList(25,8)=3;
NodeList(26,8)=3;
NodeList(27,8)=3;
NodeList(28,8)=3;
NodeList(29,8)=3;
NodeList(30,8)=3;
NodeList(31,8)=4;
NodeList(32,8)=4;
NodeList(33,8)=4;
NodeList(34,8)=4;
NodeList(35,8)=4;
NodeList(36,8)=4;
NodeList(37,8)=4;
NodeList(38,8)=4;
NodeList(39,8)=4;
NodeList(40,8)=4;

%%% Set RandomRoundList_Flag
i=ShowRandom_ShowSequential_StartNumber;
while i<=ShowRandom_ShowSequential_FinishNumber
    RandomRoundList_Flag(i,1)=1;
        
    i=i+ShowRandom_ShowSequential_StepNumber;
end;
for i=1:RoundCount
    if mod(i,ShowRandom_StepNumber)==0
        RandomRoundList_Flag(i,1)=1;
    end;
end;





%%%%% Cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Continue_Flag=1;
RoundNumber=1;
while Continue_Flag==1

    %%% NodeConsumptionEnergy
    NodeConsumptionEnergy=zeros(NodeNumber,1);
    for i=1:NodeNumber
        NodeConsumptionEnergy(i,1)=NodeList(i,4);
    end;
    
    %%% Sense data
    for i=1:NodeNumber
        if (mod(RoundNumber,NodeSenseIntervalTime)==0)&&(NodeList(i,4)>NodeThresholdEnergy)
            NodeList(i,5)=round(rand(1)*MaximumTemperatureValue);

            % Decrease consumption energy of the nodes to sense data              
            NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize); 
            
            if NodeList(i,4)<0
                NodeList(i,4)=0;
            end;            
        end;
    end;
    
    %%% Set active and sleep states of the nodes
    if mod(RoundNumber,ChangeActiveSleepIntervalTime)==0
        
        % Set sleep state of all nodes
        for i=1:NodeNumber
            NodeList(i,7)=0;  
        end;
        
        % Set active state of selected nodes
        %\ Section A
        Nodes_SelectionPriority=zeros(NodeNumber,2);
        Nodes_SelectionPriority_Index=0;        
        
        for i=1:NodeNumber
            if NodeList(i,8)==1
                
                %%% Remaining energy
                RemainingEnergy=NodeList(i,4);                                                      
                if RemainingEnergy<=MaximumRemainingEnergy
                    Crisp=RemainingEnergy; 
                else
                    Crisp=MaximumRemainingEnergy;
                end;                            
                mu_RemainingEnergy=fuzzifysn(U_RemainingEnergy,Crisp,RemainingEnergy_Type,RemainingEnergy_ShapeFactor); 

                %%% Number of active state
                NumberOfActiveState=NodeList(i,9);
                if NumberOfActiveState<=MaximumActiveState
                    Crisp=NumberOfActiveState; 
                else
                    Crisp=MaximumActiveState;
                end;
                mu_NumberOfActiveState=fuzzifysn(U_NumberOfActiveState,Crisp,NumberOfActiveState_Type,NumberOfActiveState_ShapeFactor);                                       
                    
                %%% Selection priority
                mu_SelectionPriority=ruleresp(R,fuzzyand(mu_RemainingEnergy,mu_NumberOfActiveState));
                SelectionPriority=defuzzyg(U_SelectionPriority,mu_SelectionPriority);
                    
                %%% Update Nodes_SelectionPriority
                Nodes_SelectionPriority_Index=Nodes_SelectionPriority_Index+1;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1)=i;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,2)=SelectionPriority; 
            
            end;
        end;
        
        Nodes_SelectionPriority=Nodes_SelectionPriority(1:Nodes_SelectionPriority_Index,:);
        Nodes_SelectionPriority=sortrows(Nodes_SelectionPriority,2);                                   
        SelectedNode_ID=Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1);
        
        NodeList(SelectedNode_ID,7)=1;
        NodeList(SelectedNode_ID,9)=NodeList(SelectedNode_ID,9)+1;
        
        %\ Section B
        Nodes_SelectionPriority=zeros(NodeNumber,2);
        Nodes_SelectionPriority_Index=0;        
        
        for i=1:NodeNumber
            if NodeList(i,8)==2
                
                %%% Remaining energy
                RemainingEnergy=NodeList(i,4);                                                      
                if RemainingEnergy<=MaximumRemainingEnergy
                    Crisp=RemainingEnergy; 
                else
                    Crisp=MaximumRemainingEnergy;
                end;                            
                mu_RemainingEnergy=fuzzifysn(U_RemainingEnergy,Crisp,RemainingEnergy_Type,RemainingEnergy_ShapeFactor); 

                %%% Number of active state
                NumberOfActiveState=NodeList(i,9);
                if NumberOfActiveState<=MaximumActiveState
                    Crisp=NumberOfActiveState; 
                else
                    Crisp=MaximumActiveState;
                end;
                mu_NumberOfActiveState=fuzzifysn(U_NumberOfActiveState,Crisp,NumberOfActiveState_Type,NumberOfActiveState_ShapeFactor);                                       
                    
                %%% Selection priority
                mu_SelectionPriority=ruleresp(R,fuzzyand(mu_RemainingEnergy,mu_NumberOfActiveState));
                SelectionPriority=defuzzyg(U_SelectionPriority,mu_SelectionPriority);
                    
                %%% Update Nodes_SelectionPriority
                Nodes_SelectionPriority_Index=Nodes_SelectionPriority_Index+1;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1)=i;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,2)=SelectionPriority; 
            
            end;
        end;
        
        Nodes_SelectionPriority=Nodes_SelectionPriority(1:Nodes_SelectionPriority_Index,:);
        Nodes_SelectionPriority=sortrows(Nodes_SelectionPriority,2);                                   
        SelectedNode_ID=Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1);
        
        NodeList(SelectedNode_ID,7)=1;
        NodeList(SelectedNode_ID,9)=NodeList(SelectedNode_ID,9)+1;
        
        %\ Section C
        Nodes_SelectionPriority=zeros(NodeNumber,2);
        Nodes_SelectionPriority_Index=0;        
        
        for i=1:NodeNumber
            if NodeList(i,8)==3
                
                %%% Remaining energy
                RemainingEnergy=NodeList(i,4);                                                      
                if RemainingEnergy<=MaximumRemainingEnergy
                    Crisp=RemainingEnergy; 
                else
                    Crisp=MaximumRemainingEnergy;
                end;                            
                mu_RemainingEnergy=fuzzifysn(U_RemainingEnergy,Crisp,RemainingEnergy_Type,RemainingEnergy_ShapeFactor); 

                %%% Number of active state
                NumberOfActiveState=NodeList(i,9);
                if NumberOfActiveState<=MaximumActiveState
                    Crisp=NumberOfActiveState; 
                else
                    Crisp=MaximumActiveState;
                end;
                mu_NumberOfActiveState=fuzzifysn(U_NumberOfActiveState,Crisp,NumberOfActiveState_Type,NumberOfActiveState_ShapeFactor);                                       
                    
                %%% Selection priority
                mu_SelectionPriority=ruleresp(R,fuzzyand(mu_RemainingEnergy,mu_NumberOfActiveState));
                SelectionPriority=defuzzyg(U_SelectionPriority,mu_SelectionPriority);
                    
                %%% Update Nodes_SelectionPriority
                Nodes_SelectionPriority_Index=Nodes_SelectionPriority_Index+1;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1)=i;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,2)=SelectionPriority; 
            
            end;
        end;
        
        Nodes_SelectionPriority=Nodes_SelectionPriority(1:Nodes_SelectionPriority_Index,:);
        Nodes_SelectionPriority=sortrows(Nodes_SelectionPriority,2);                                   
        SelectedNode_ID=Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1);
        
        NodeList(SelectedNode_ID,7)=1;
        NodeList(SelectedNode_ID,9)=NodeList(SelectedNode_ID,9)+1;

        %\ Section D
        Nodes_SelectionPriority=zeros(NodeNumber,2);
        Nodes_SelectionPriority_Index=0;        
        
        for i=1:NodeNumber
            if NodeList(i,8)==4
                
                %%% Remaining energy
                RemainingEnergy=NodeList(i,4);                                                      
                if RemainingEnergy<=MaximumRemainingEnergy
                    Crisp=RemainingEnergy; 
                else
                    Crisp=MaximumRemainingEnergy;
                end;                            
                mu_RemainingEnergy=fuzzifysn(U_RemainingEnergy,Crisp,RemainingEnergy_Type,RemainingEnergy_ShapeFactor); 

                %%% Number of active state
                NumberOfActiveState=NodeList(i,9);
                if NumberOfActiveState<=MaximumActiveState
                    Crisp=NumberOfActiveState; 
                else
                    Crisp=MaximumActiveState;
                end;
                mu_NumberOfActiveState=fuzzifysn(U_NumberOfActiveState,Crisp,NumberOfActiveState_Type,NumberOfActiveState_ShapeFactor);                                       
                    
                %%% Selection priority
                mu_SelectionPriority=ruleresp(R,fuzzyand(mu_RemainingEnergy,mu_NumberOfActiveState));
                SelectionPriority=defuzzyg(U_SelectionPriority,mu_SelectionPriority);
                    
                %%% Update Nodes_SelectionPriority
                Nodes_SelectionPriority_Index=Nodes_SelectionPriority_Index+1;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1)=i;
                Nodes_SelectionPriority(Nodes_SelectionPriority_Index,2)=SelectionPriority; 
            
            end;
        end;
        
        Nodes_SelectionPriority=Nodes_SelectionPriority(1:Nodes_SelectionPriority_Index,:);
        Nodes_SelectionPriority=sortrows(Nodes_SelectionPriority,2);                                   
        SelectedNode_ID=Nodes_SelectionPriority(Nodes_SelectionPriority_Index,1);
        
        NodeList(SelectedNode_ID,7)=1;
        NodeList(SelectedNode_ID,9)=NodeList(SelectedNode_ID,9)+1;        
         
    end;
        
    %%% Send data of the nodes to sink
    if mod(RoundNumber,SendNodeDataIntervalTime)==0
        
        for i=1:NodeNumber
            if (NodeList(i,7)==1)&&(NodeList(i,4)>NodeThresholdEnergy)
                          
                if SinkBuffer_Index<SinkBufferSize
                    SinkBuffer_Index=SinkBuffer_Index+1;
                
                    SinkBuffer(SinkBuffer_Index,1)=NodeList(i,5);                                                                                          
                end;
                
                % Decrease consumption energy of the nodes to sense data              
                NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize); 
            
                % Decrease consumption energy of sended data to sink 
                Distance=sqrt(((NodeList(i,2)-Sink(1))^2)+((NodeList(i,3)-Sink(2))^2));
                if Distance<=d0
                    NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize+10*(10^(-11))*PacketSize*(Distance^2));
                else
                    NodeList(i,4)=NodeList(i,4)-(50*(10^(-9))*PacketSize+13*(10^(-16))*PacketSize*(Distance^4));
                end;                                                                                              
            
            end;
        end;  
        
    end;
    
    %%% Send aggregated data of the sink to base station
    if mod(RoundNumber,SendSinkAggregatedDataIntervalTime)==0
  
        AggregatedData=mean(SinkBuffer(:,1));
        SinkBuffer=zeros(1:SinkBufferSize,1);
        SinkBuffer_Index=0;
        
        if BaseStationBuffer_Index<BaseStationBufferSize
            BaseStationBuffer_Index=BaseStationBuffer_Index+1;
                
            BaseStationBuffer(BaseStationBuffer_Index,1)=AggregatedData;                                                                                          
        end;

    end;    
    
    %%% TotalRoundList
    TotalRoundList(RoundNumber,1)=RoundNumber;    
    % 
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,2)=min(Distance(1,1:Distance_Index)); 
    %
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,3)=max(Distance(1,1:Distance_Index)); 
    %
    Distance=zeros(1,NodeNumber^2);
    Distance_Index=0;
    for i=1:NodeNumber
        for j=1:NodeNumber
            if i<j
                Distance_Index=Distance_Index+1;
                
                Distance_Value=sqrt(((NodeList(i,2)-NodeList(j,2))^2)+((NodeList(i,3)-NodeList(j,3))^2));
                Distance(1,Distance_Index)=Distance_Value;
            end;
        end;
    end;
    TotalRoundList(RoundNumber,4)=round((sum(Distance(1,1:Distance_Index)))/NodeNumber);           
    %
    Sum=0;
    for i=1:NodeNumber
        Sum=Sum+NodeList(i,4);
    end;
    if (Sum/NodeNumber)>NodeThresholdEnergy
        TotalRoundList(RoundNumber,5)=Sum/NodeNumber;    
    else
        TotalRoundList(RoundNumber,5)=NodeThresholdEnergy;
    end;
    %
    for i=1:NodeNumber
        NodeConsumptionEnergy(i,1)=NodeConsumptionEnergy(i,1)-NodeList(i,4);
    end;    
    Sum=0;
    for i=1:NodeNumber
        Sum=Sum+NodeConsumptionEnergy(i,1);
    end;
    TotalRoundList(RoundNumber,6)=Sum;    
    %
    TotalRoundList(RoundNumber,7)=TotalRoundList(RoundNumber,6)/NodeNumber;
    %
    Count=0;
    for i=1:NodeNumber
        if NodeList(i,4)>NodeThresholdEnergy
            Count=Count+1;
        end;
    end;
    TotalRoundList(RoundNumber,8)=Count; 
    %
    TotalRoundList(RoundNumber,9)=NodeNumber-TotalRoundList(RoundNumber,8);        

    %%% RandomRoundList
    if RandomRoundList_Flag(RoundNumber,1)==1
        RandomRoundList_Index=RandomRoundList_Index+1;
        
        RandomRoundList(RandomRoundList_Index,1)=TotalRoundList(RoundNumber,1);        
        RandomRoundList(RandomRoundList_Index,2)=TotalRoundList(RoundNumber,2);
        RandomRoundList(RandomRoundList_Index,3)=TotalRoundList(RoundNumber,3);
        RandomRoundList(RandomRoundList_Index,4)=TotalRoundList(RoundNumber,4);
        RandomRoundList(RandomRoundList_Index,5)=TotalRoundList(RoundNumber,5);
        RandomRoundList(RandomRoundList_Index,6)=TotalRoundList(RoundNumber,6);
        RandomRoundList(RandomRoundList_Index,7)=TotalRoundList(RoundNumber,7);        
        RandomRoundList(RandomRoundList_Index,8)=TotalRoundList(RoundNumber,8);        
        RandomRoundList(RandomRoundList_Index,9)=TotalRoundList(RoundNumber,9);
    end;
    
    %%% Check dead state of the nodes
    for i=1:NodeNumber
        if NodeList(i,4)<NodeThresholdEnergy
            NodeList(i,6)=RoundNumber;    
        end;
    end; 
    
    %%% Check dead state of the all nodes
    if TotalRoundList(RoundNumber,9)==NodeNumber
        Continue_Flag=0;
    end;    
    
    %%% Set zero of the deaded nodes
    for i=1:NodeNumber
        if NodeList(i,4)<NodeThresholdEnergy
            NodeList(i,4)=NodeThresholdEnergy;
        end;
    end;    
    
    %%% Display and increase RoundNumber
    RoundNumber
    RoundNumber=RoundNumber+1;
end;





%%%%% Display summary tables and charts of the rounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (RoundsOutputSelect==1)||(RoundsOutputSelect==3)
    
    %%% Summary table
    TotalRoundList=TotalRoundList(1:(RoundNumber-1),:);
    TotalRoundList
    
    %%% Charts
    % Average remaining energy of the nodes
    figure(1);
    plot(TotalRoundList(:,1),TotalRoundList(:,5),'-b','LineWidth',2);
    title('Average Remaining Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Average Energy (Joule)');
    
    % Total consumption energy of the nodes
    figure(2);
    plot(TotalRoundList(:,1),TotalRoundList(:,6),'-r','LineWidth',2);
    title('Total Consumption Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Total Consumption Energy (Joule)'); 
    
    % Average consumption energy of the nodes
    figure(3);
    plot(TotalRoundList(:,1),TotalRoundList(:,7),'-k','LineWidth',2);
    title('Average Consumption Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Average of Consumption Energy (Joule)');      
    
    % Live nodes count
    figure(4);
    plot(TotalRoundList(:,1),TotalRoundList(:,8),'-m','LineWidth',2);
    title('Number of Live Nodes');
    xlabel('Round Number');
    ylabel('Number of Live Nodes');    
       
end;

if (RoundsOutputSelect==2)||(RoundsOutputSelect==3)

    %%% Summary table
    RandomRoundList=RandomRoundList(1:RandomRoundList_Index,:);
    RandomRoundList
    
    %%% Charts
    % Average remaining energy of the nodes
    figure(5);
    plot(RandomRoundList(:,1),RandomRoundList(:,5),'--sb','LineWidth',2);
    title('Average Remaining Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Average Energy (Joule)');
    
    % Total consumption energy of the nodes
    figure(6);
    plot(RandomRoundList(:,1),RandomRoundList(:,6),'--vr','LineWidth',2);
    title('Total Consumption Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Total Consumption Energy (Joule)'); 
    
    % Average consumption energy of the nodes
    figure(7);
    plot(RandomRoundList(:,1),RandomRoundList(:,7),'--ok','LineWidth',2);
    title('Average Consumption Energy of the Nodes');
    xlabel('Round Number');
    ylabel('Average of Consumption Energy (Joule)');      
    
    % Live nodes count
    figure(8);
    plot(RandomRoundList(:,1),RandomRoundList(:,8),'--sm','LineWidth',2);
    title('Number of Live Nodes');
    xlabel('Round Number');
    ylabel('Number of Live Nodes'); 
    
end;





%%%%% Set NodeThresholdEnergy of the deaded nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:NodeNumber
    if NodeList(i,4)<NodeThresholdEnergy
        NodeList(i,4)=NodeThresholdEnergy;
    end;
end;





%%%%% Display summary tables and charts of the base station
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Summary table
TotalBaseStationDataList=zeros(BaseStationBuffer_Index,2); % 1: Packet Number | 2: Data
for i=1:BaseStationBuffer_Index
    TotalBaseStationDataList(i,1)=i;
    TotalBaseStationDataList(i,2)=BaseStationBuffer(i,1);        
end;
TotalBaseStationDataList
    
%%% Charts
%%% \\\ 2D
% Data
figure(9);
plot(TotalBaseStationDataList(:,1),TotalBaseStationDataList(:,2),'--ob');
title('Temperature of the Received Packets');
xlabel('Packet Number');
ylabel('Temperature (Centigrade)'); 





%%%%% Display summary tables and charts of the nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%% Summary table
NodeList
    
%%% Charts
figure(10);
plot(NodeList(:,2),NodeList(:,3),'o','MarkerEdgeColor','r','MarkerFaceColor','b');
grid on;
title('Position of the Nodes');
xlabel('X');
ylabel('Y');





%%%%% Display Membership functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Input fuzzy
% Remaining energy
U_RemainingEnergy
mu_RemainingEnergy_VeryLow
mu_RemainingEnergy_Low
mu_RemainingEnergy_Middle
mu_RemainingEnergy_High
mu_RemainingEnergy_VeryHigh

% Number of active state
U_NumberOfActiveState
mu_NumberOfActiveState_VeryFew
mu_NumberOfActiveState_Few
mu_NumberOfActiveState_Middle
mu_NumberOfActiveState_Many
mu_NumberOfActiveState_VeryMany

%%% Output fuzzy
% Selection priority
U_SelectionPriority
mu_SelectionPriority_VeryLow
mu_SelectionPriority_Low
mu_SelectionPriority_Middle
mu_SelectionPriority_High
mu_SelectionPriority_VeryHigh





%%%%% Display list and charts of the rules
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% List
R1
R2
R3
R4
R5
R6
R7
R8
R9
R10
R
    
%%% Charts
% Selection Priority and Remaining Energy
figure(11);
surf(U_SelectionPriority,U_RemainingEnergy,R);
title('Rule R Based on the Selection Priority and Remaining Energy');
xlabel('Selection Priority (%)');
ylabel('Remaining Energy (Joule)'); 
zlabel('Rule R'); 

% Selection Priority and Number Of Active State
figure(12);
surf(U_SelectionPriority,U_NumberOfActiveState,R);
title('Rule R Based on the Selection Priority and Number of Active State');
xlabel('Selection Priority (%)');
ylabel('Number of Active State'); 
zlabel('Rule R'); 
 



