function [ data, datN ] = GEOS_3R_BIN_DataRead_not_optimum( ncmd, com_port)
%��������� �� ��������� ����� ��������� ����� ncmd
% �������������� �������� cs. �� ������: 
%data  - ������ �������������� ����� (��� ���������, datN,ncmd, cs)
%datN- ����������� ���� � ��������� (� ��� ���������� �� ������ 
%���������, datN,ncmd, cs, ����������� ������ data)
preamble_and_ncmd(1:8,1)=[hex2dec('47'); hex2dec('45'); hex2dec('4f'); hex2dec('53'); ...
    hex2dec('72'); hex2dec('33'); hex2dec('50'); hex2dec('53')]; %��������� GEOS-3R
ncmd=str2num(dec2bin(ncmd)); %��������� � ��������� ����� ��������� (ncmd)
preamble_and_ncmd(9:10,1)=0;%!!! preamble_and_ncmd(10,1)==0 �������� ���������
for(k=1:8)
    preamble_and_ncmd(9,1)=preamble_and_ncmd(9,1)+fix(mod(ncmd,10^k)/10^(k-1))*2^(k-1);
end
poisk(1:10,1)=0; % ������ ������, �� ����� ������������ � preamble_and_ncmd
data=nan;
while(1==1)
    poisk(1:9,1)=poisk(2:10,1);% 1. ������������ ������ ������� ������
    poisk(10,1)=fread(com_port,1,'uint8'); %2. -//-//-
    if(poisk(1:10,1)==preamble_and_ncmd(1:10,1)) %�������� �� ����� � ������ ���������
        datN=fread(com_port,1);
        datN=datN+fread(com_port,1)*16; %����� ���� (�� 32 ����) � ���������
        for(k=1:datN)%�������������� �����
            data(4*(k-1)+1:4*k,1)=fread(com_port,4,'uint8');
        end
%         data(1:datN*4,1)=tmp_data(1:end-4,1);
%         ControlSum(1:4,1)=tmp_data(end-3:end,1);
        ControlSum(1:4,1)=fread(com_port,4,'uint8');%����������� �����
        %���������
        ControlSum(1:4,1)=str2num(dec2bin(ControlSum(1:4,1)));
        for(k=1:4) %����������� ����� �� ����� ������������
            for(m=1:8)
                bit_ControlSum(1,m+8*(k-1))=mod(fix(ControlSum(k)/10^(8-m)),10);
            end
        end
        dataFORbit(1:10,1)=preamble_and_ncmd(1:10,1); %1. �� � ���� ������
        dataFORbit(11,1)=datN-256*fix(datN/256); %????
        dataFORbit(12,1)=fix(datN/256); %????
        dataFORbit(13:12+length(data),1)=data(1:end,1); %2. (��� ��������)
        dataFORbit=str2num(dec2bin(dataFORbit));
        for(k=1:length(dataFORbit)) % ������ �� ������� ����� ������ ��� � ��������� ����� ������
            for(m=1:8)
                stroka=fix((k-1)/4)+1;
                stolb=m+8*(k-1-4*(stroka-1));
                bit_data(stroka,stolb)=mod(fix(dataFORbit(k)/10^(8-m)),10);
            end
        end
        size_bit_data=size(bit_data);
        for(m=1:size_bit_data(2)) %������� ����������� �����
            bit_cs(m)=bit_data(1,m);
            for(k=2:size_bit_data(1))
                bit_cs(m)=xor(bit_cs(m),bit_data(k,m));
            end
        end
        if(bit_cs(:)==bit_ControlSum(:))       
            break;
        end
    end  
end
end

