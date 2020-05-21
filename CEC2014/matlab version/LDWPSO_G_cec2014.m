%**************************************************************************************************
 
%  LDWPSO
%  Writer: Chen Xu
%  Date: 2014/02/24
%**************************************************************************************************


clc;
clear all; 


format long;
 
 
benchmark_cec2014 = str2func('cec14_func'); 
fun = benchmark_cec2014;

for problem = 1:1 

    D = 30;
    problem_range; 
    Xmin = lu(1,:);
    Xmax = lu(2,:); 
    
    Number = 1;
    runNumber = 1;  % The total number of runs 

    while Number <= runNumber

        tic 
        rand('seed', sum(100 * clock));  
 
   
        popsize = 40; 
        % Initialize the main population
        X = repmat(Xmin, popsize, 1) + rand(popsize, n) .* (repmat(Xmax-Xmin, popsize, 1));
        val_X = (fun(X',problem))';  
     
        pBest = X; val_pBest = val_X;
        [~,indexG] = min(val_pBest);
        gBest = pBest(indexG,:); val_gBest = val_pBest(indexG,:);  
         
        wmax = 0.9; wmin = 0.4; 
        c1 = 2; c2 = 2;
        Vmax = (Xmax - Xmin)*0.5;        %�����С�ٶ�
        Vmin = -Vmax;
        V = repmat(Vmin,popsize,1) + rand(popsize,D).*repmat(Vmax-Vmin,popsize,1);
        
        outcome = [];  % record the best results 
        FES = 0; maxFES = 1e4*D;
        while   FES < maxFES
 
               % ���Ĺ���Ȩ��
                w = wmax- FES/(D*10000)*(wmax-wmin);
 
                for i = 1:popsize    
                    %����i�ٶȸ���
                    V(i,:) = w*V(i,:) + c1*rand(1,D).*(pBest(i,:)-X(i,:))+c2*rand(1,D).*(gBest-X(i,:) );              %ע��repmat��ʹ��
                    V(i,:) = boundConstraint_absorb(V(i,:),Vmin,Vmax);  

                    %����iλ�ø���
                    X(i,:) = boundConstraint_reflect(X(i,:)+V(i,:),Xmin,Xmax);   

                    val_X(i,:) = (fun(X(i,:)',problem))';
                    FES = FES+1;

                    %----------------- ���� pBest��
                    if val_X(i,:) < val_pBest(i,:)
                        val_pBest(i,:) = val_X(i,:);
                        pBest(i,:) = X(i,:);
                    end
                     
                    %----------------- ���� gBest ----------------
                    if val_X(i,:) < val_gBest
                        val_gBest = val_X(i,:);
                        gBest = X(i,:); 
                    end

                end 
                
    
                FES
                val_gBest
                outcome = [outcome; val_gBest*ones(popsize,1)]; 


        end

        Number, FES
        val_gBest


%       ��¼ÿһ�����е����
        eval(['record.outcome',num2str(Number),'=','outcome',';']);
        record.FES(Number) = FES;
        record.time(Number) = toc;

        Number = Number + 1; 


    end

%     ��������
    filename = strcat( 'out_f', num2str(problem),'_LDWPSO');  %f1_DE, f2_jDE
    save(filename, 'record');
 
end





