clear
clc

fclose(instrfind)
%��������� COM �����
Num_com_port='COM15';
baud=115200;
com_port=serial(Num_com_port, 'BaudRate', baud);

%��� ������������
settings.LatLonData=1; %��������� 0�20. ������� ����� �������������� ���������


Bin.preamble=[hex2dec('47'); hex2dec('45'); hex2dec('4f'); hex2dec('53'); ...
    hex2dec('72'); hex2dec('33'); hex2dec('50'); hex2dec('53')]; %��������� GEOSr3PS

% ����

    %���������� ������� �� �����
    fopen(com_port);
    Bin.data_read=fread(com_port);
    fclose(com_port);
    
    LatLonData.start=0;
    
    Bin.Num_posts=0;% ����������� ���������� ���������
    for(k=1:(length(Bin.data_read)-10)) % ���� ������ ������ ��������� � �� �����������
       logik_Matrix(1:8)=(Bin.data_read(k:k+7)==Bin.preamble(1:8));
       logik=logik_Matrix(1);
       for (ind=2:8)
            logik=logik&logik_Matrix(ind); 
       end
       
       if(logik)
           Bin.Num_posts=Bin.Num_posts+1; %��������� ���������� ���������
           Bin.Num_start(Bin.Num_posts)=k;% ������ ������ ���������
       end
    end
    
    if (Bin.Num_posts>0) % ���� ��������� �������� �� ���������
        Bin.datN=Bin.data_read(Bin.Num_start+11)*256+Bin.data_read(Bin.Num_start+10); %���������� ���� � ��������� 
        Bin.ncmd=Bin.data_read(Bin.Num_start+9)*256+Bin.data_read(Bin.Num_start+8); % ����� ��������� (� ��� ���������)
        
        for(k=1:Bin.Num_posts)
            switch(Bin.ncmd(k)) %����������� ���� ��������� 
                case hex2dec('20')
                    LatLonData.start=Bin.Num_start(k);% ������ ��������� 0�20
            end
        end
        
        
        while(settings.LatLonData==1)
            if(LatLonData.start>0)
                tmp=nan;
                for(k=1:8) %UTC
                    tmp(k)=Bin.data_read(LatLonData.start+11+k);
                end
                LatLonData.UTC=bin2num(tmp,'double');
                fprintf('UTC (c 01.01.2008): %9.0f sec \n', LatLonData.UTC)
                %
                %Lat and Lon
                for(k=1:8) %Lat
                    tmp(k)=Bin.data_read(LatLonData.start+19+k);
                end
                LatLonData.Lat=bin2num(tmp,'double')*180/pi;
                fprintf('Lat: %f \n', LatLonData.Lat)
                
                for(k=1:8) %Lon
                    tmp(k)=Bin.data_read(LatLonData.start+27+k);
                end
                LatLonData.Lon=bin2num(tmp,'double')*180/pi;
                fprintf('Lon: %f \n', LatLonData.Lon)
                plot(LatLonData.Lon,LatLonData.Lat,'.b','MarkerSize',15)
                plot_google_map
            end
            break;
        end
        
    end
    
    