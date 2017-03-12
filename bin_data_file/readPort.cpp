#include <stdio.h>
#include <tchar.h>
#include <SDKDDKVer.h>
#include <Windows.h>
#include <iostream>
#include <cstdio>
#include <fstream>


using namespace std;

HANDLE hSerial;
char FileName[20]=""; // имя файла 

void ReadCOM() ///
{
      DWORD iSize;
      char ComPortData;
      ofstream out(FileName,ios::binary|ios::out);
      while (true)
      {
            ReadFile(hSerial, &ComPortData, 1, &iSize, 0);
			if (iSize > 0){
				out.write((char*)&ComPortData,sizeof ComPortData);
				cout << ComPortData;				
				}
      }
}

int _tmain(int argc, _TCHAR* argv[])
{	
	char NumPort[14] = "";
	LPCTSTR sPortName;
	
	cout << "File Name: test.bin \n";
    cout << "Com port: COM# \n";
	cout << "# = 1,2,...9 \n";
	cout << "Com port: ////.//COM# \n";
	cout << "# >10 \n________\n";
	
	cout << "File Name: ";
	cin >> FileName;
	
	cout << "Com port: ";
	cin >> NumPort;
	
	if (NumPort[0]=='/'){
 		NumPort[0] ='\\';
		NumPort[1]='\\';
		NumPort[2]='\\';
		NumPort[3]='\\';
		NumPort[5]='\\';
		NumPort[6]='\\';
	}

	sPortName=NumPort;

	hSerial = ::CreateFile(sPortName,GENERIC_READ,0,NULL ,OPEN_EXISTING,0 ,NULL); // открыть порт. (имя прта, тоько чтение, стд,стд,стд, режим обработки,стд)

	if(hSerial==INVALID_HANDLE_VALUE) // проверка на правильность открытия порта
	{
		if(GetLastError()==ERROR_FILE_NOT_FOUND)
		{
			cout << "serial port does not exist.\n";
		}
		cout << "some other error occurred.\n";
	}

//настройки
	DCB dcbSerialParams = {0};
	dcbSerialParams.DCBlength=sizeof(dcbSerialParams);
	if (!GetCommState(hSerial, &dcbSerialParams))
	{
		cout << "getting state error\n";
	}
	dcbSerialParams.BaudRate=CBR_115200;
	dcbSerialParams.ByteSize=8;
	dcbSerialParams.StopBits=ONESTOPBIT;
	dcbSerialParams.Parity=NOPARITY;
	if(!SetCommState(hSerial, &dcbSerialParams))
	{
		cout << "error setting serial port state\n";
	}


	while(1) //читаем и записываем файл
	{
		ReadCOM();
	}
	return 0;
}
