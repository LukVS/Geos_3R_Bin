function [ OUT ] = GEOS_3R_BIN_bin2num( IN, format )
%���� ��������� �� ��������� � �������� 
IN=str2num(dec2bin(IN)); % �������� ����� � �������� �������������
 if(length(format)==length('double'))
 while(format=='double')
    A(1:64)=0;
    for(k=0:5)
        for(m=1:8) % ������� 48 ��� ��������
            A(m+8*k)=fix(mod(IN(k+1),10^m)/10^(m-1));
        end
    end
    for(k=1:4) % ������� 4 ���� ��������
        A(48+k)=fix(mod(IN(7),10^k)/10^(k-1));     
    end
    for(k=1:4)%������� ���� �������
        A(52+k)=fix(mod(IN(7),10^(k+4))/10^(k+3));
    end
    for(k=1:7)%������� ���� �������
        A(56+k)=fix(mod(IN(8),10^k)/10^(k-1));
    end
    A(64)=fix(IN(8)/10^7);%����
    
    OUT=(-1)^A(64);
    Man=0;%��������
    for(k=1:52)
        Man=Man+A(53-k)*2^(-k);
    end
    expon=0;%������� (����������)
    for(k=1:11) %������� (����������)
        expon=expon+A(52+k)*2^(k-1);
    end
    OUT=OUT*(1+Man)*2^(expon-1023);
    
    break;
 end
 end
 
 if(length(format)==length('int'))
 while(format=='int')
    A(1:32)=0;
    for(k=1:4) % ������������ ����� �� �����
        for(m=1:8)
            A(m+8*(k-1))=fix(mod(IN(k),10^m)/10^(m-1));
        end
    end
    
    OUT=A(32); %��������� 
    for(k=1:31)% ������ �����             ������=�����(�(k)*2^(k-1)) - ������������� �����
        OUT=OUT+abs(A(k)-A(32))*2^(k-1); % ������=1+�����(|�(k)-1|*2^(k-1)) - ���. �����
    end
    OUT=((-1)^A(32))*OUT; %��������� ����
    
    break;
 end
 end

 if(length(format)==length('float'))
 while(format=='float')
    A(1:32)=0;
    for(k=0:3) % ������������ ����� �� �����
        for(m=1:8)
            A(m+8*k)=fix(mod(IN(k+1),10^m)/10^(m-1));
        end
    end
    
    Man=0; %��������
    for(k=1:23)
        Man=Man+A(24-k)*2^(-k);
    end
    
    expon=0; % �������
    for(k=1:8)
        expon=expon+A(23+k)*2^(k-1);
    end
    
    OUT=(-1)^(A(32))*(1+Man)*2^(expon-127);
 break;
 end
 end
 
end

