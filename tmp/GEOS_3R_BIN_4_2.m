clear
clc

%fclose(instrfind)
%��������� COM �����
Num_com_port='COM15';
baud=115200;
com_port=serial(Num_com_port, 'BaudRate', baud);

%��� ������������
phData.NumPointPlot=50; % ������������ ����� ����� �� �������
phData.NumPointPoiskKA=10;    % ����� ����� ��� ������ ������� ��
phData.chisl_spytnicov=96;%  ����� ��������� 

phData.reliable(1:phData.NumPointPlot,1:phData.chisl_spytnicov)=nan; 
phData.SignalToNoise(1:phData.NumPointPoiskKA,1:phData.chisl_spytnicov)=nan;
phData.phase(1:phData.NumPointPlot,1)=nan;
phData.time(1:phData.NumPointPlot,1)=nan;

% Bin.preamble=[hex2dec('47'); hex2dec('45'); hex2dec('4f'); hex2dec('53'); ...
%     hex2dec('72'); hex2dec('33'); hex2dec('50'); hex2dec('53')]; %��������� GEOSr3PS

%��������� ��������� ��������� ���������
% ������ ��������� 0�10
Bin.data_write(1:8,1)=[hex2dec('4F'); 0; 1; 0; 0; 0; hex2dec('01'); 0];
GEOS_3R_BIN_DataWrite(Bin.data_write, com_port);

% ���� ������ (10 ��)
Bin.data_write(1:8,1)=[hex2dec('44'); 0; 1; 0; 0; 0; 0; 0];
GEOS_3R_BIN_DataWrite(Bin.data_write, com_port);

StartTime=-1; % ����� ������ ������

fopen(com_port);
while(1==1) % ���������� ����� ��
    for(cikl_for=1:phData.NumPointPoiskKA)
        %���������� ������� �� �����
        
        [Bin.PH_data, phData.datN]=GEOS_3R_BIN_DataRead(16,com_port);

        
        while(1==1)% ����� ��������. ��������- ����. �/�
            phData.NumKA=bin2num(Bin.PH_data(13:16,1),'int');
            fprintf('NUM KA: %d  \n', phData.NumKA) %print ����� �� � �������
            for(k=1:phData.NumKA)%��������� ������ � "�"-�� ��������
                [phData.tmp_KAnumber, phData.tmp_reliable, phData.tmp_SignalToNoise,...
                    phData.tmp_phase,phData.tmp_Doppler]=GEOS_3R_BIN_DataDecod_0x10(...
                    Bin.PH_data(4*(-9+14*k)-3:4*(4+14*k),1));
                phData.SignalToNoise(cikl_for,phData.tmp_KAnumber)=phData.tmp_SignalToNoise;
            end
            break
        end
        
    end
    %������� ������ �� ����� ������ ��
   [logik,ind_KA]=max(sum(phData.SignalToNoise));%����� ������������� ��������� �/�
   if(logik>40*phData.NumPointPoiskKA) % ��� ���������� ������ ��������� ��������� �/� ������ 40 dBHz
       fprintf('\n ok \n num KA= %d \n max signalTOnoise %f \n', ind_KA, logik/phData.NumPointPoiskKA)
       break
   else
       fprintf('\n not \n max signalTOnoise= %f \n', logik/phData.NumPointPoiskKA)
   end
end
fclose(com_port);
%��������� �����
phData.SignalToNoise(1:phData.NumPointPlot,1:phData.chisl_spytnicov)=nan;

fopen(com_port);
while(1==1) % ��������� ������ � ��������� ��
    
    [Bin.PH_data,phData.datN]=GEOS_3R_BIN_DataRead(16,com_port);
    
    
    while(1==1) %��������� ��������� 0�10
        fprintf('\n ____________0x10___________')
        
        for(m=1:phData.NumPointPlot-1)% ��������� �� ���� ����
            phData.phase(phData.NumPointPlot-m+1,1)=phData.phase(phData.NumPointPlot-m,1);
            phData.SignalToNoise(phData.NumPointPlot-m+1,1)=phData.SignalToNoise(phData.NumPointPlot-m,1);
            phData.reliable(phData.NumPointPlot-m+1,1)=phData.reliable(phData.NumPointPlot-m,1);
            phData.time(phData.NumPointPlot-m+1,1)=phData.time(phData.NumPointPlot-m,1);
        end
        
        [ phData.UTC,  phData.kol_vo_KA, phData.SignalToNoise(1),... 
            phData.phase(1),  phData.Doppler]=...
            GEOS_3R_BIN_KA_data_0x10( Bin.PH_data,  ind_KA);
        if(StartTime<0) %����� ��������� ����� (��� ��������)
            StartTime=phData.UTC;
        end
        phData.time(1,1)=phData.UTC-StartTime; %���������� ���������� � �������� ind_KA
        fprintf('\n UTC (01.01.2008): %9.0f sec', phData.UTC);
        fprintf('\n number KA: %d', phData.kol_vo_KA);
        break;
    end
    
    %��������� ������:
    if(sum(~isnan(phData.phase))>2)
        k=find(isnan(phData.phase)==0);
        apr.phase=phData.phase(k);
        apr.time=phData.time(k);
        apr.p2=polyfit(apr.time,apr.phase,2);
        apr.DataFit = polyval(apr.p2,apr.time);
        apr.DataPhase2=apr.phase-apr.DataFit;
        apr.aprTime=min(apr.time):(max(apr.time)-min(apr.time))/(phData.NumPointPlot*20):max(apr.time);
        if(length(apr.time)>fix(phData.NumPointPlot/10))
            apr.aprP2=polyfit(apr.time,apr.DataPhase2,fix(phData.NumPointPlot/10));
            apr.aprDataPhase2=polyval(apr.aprP2,apr.aprTime);
        else
            apr.aprTime=nan;
            apr.aprDataPhase2=nan;
        end
    else
        apr.DataPhase2=nan;
        apr.DataFit=nan;
        apr.time=nan;
        apr.aprTime=nan;
        apr.aprDataPhase2=nan;
    end
    %
    
    %����� ��������:
    subplot(2,2,1)
    plot(phData.time,phData.phase, 'b', apr.time,apr.DataFit, 'r')
    xlabel('time, sec');
    ylabel('phase, cycles');
    subplot(2,2,2)
    plot(phData.time,phData.SignalToNoise)
    xlabel('time, sec');
    ylabel('signal to noise, dBHz');
    subplot(2,2,3)
    plot(apr.time,apr.DataPhase2)
    xlabel('time, sec');
    ylabel('d phase, cycles');
    subplot(2,2,4)
    plot(apr.aprTime,apr.aprDataPhase2)
    xlabel('time, sec');
    ylabel('d phase, cycles');
    drawnow
    
end
    
        
        
        
       
    


