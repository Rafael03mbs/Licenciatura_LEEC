// interface.c
// J. Rosas

#include <stdlib.h>
#include <stdio.h>
#include<conio.h>
#include <signal.h>
#include <winsock.h>
#include <interface.h>		
 
//#define _USE_REAL_KIT_  

#define  MG_HTTP_FOLDER "c:/str/simulators"
#define  MG_HTTP_PORT   "8081"


HANDLE mutex_sem=NULL;

void terminar_ligacao(void)
{
					// fazer house-keeping
}

void sighandle(int signum) 
{ 
	if(signum){};  //avoid warning
	// funcoes sig_kill (very nice)
	terminar_ligacao();
	printf("Exiting due to signal(%d)\n",signum);
	exit(0); 		
}


/*****************SIMULATOR ACCESS CODE *******************/
void start_mg_server(void);

void configure_simulator_server() {
	extern char mg_http_folder[512];// = "c:/str/simulators";
	extern char mg_kit_name[128];// = "cs.html";
	extern BOOL mg_start_kit;// = FALSE;
	extern char mg_http_port[128];// = "8081";


#ifdef MG_HTTP_FOLDER 
	strcpy_s(mg_http_folder, sizeof(mg_http_folder), MG_HTTP_FOLDER);
#endif 


#ifdef MG_HTTP_PORT 
	strcpy_s(mg_http_port, sizeof(mg_http_port), MG_HTTP_PORT);
#endif		


	if (mutex_sem==NULL)
		mutex_sem = CreateSemaphore(NULL, 1, 10, NULL);
}

void sim_create_DI_channel(uInt32 port)
{	
	extern int ports_type[10];
	extern int PORTS_VALUES_AVAILABLE;

	//Initilize the critical section
	

	

	ports_type[port] = 0;  //input
	configure_simulator_server();
	start_mg_server();

	

	//ensure updated sensors
	//Sleep(1000);
}


void sim_create_DO_channel(uInt32 port)
{	
	extern int ports_type[10];
	ports_type[port] = 1; //output
	configure_simulator_server();
	start_mg_server();
}


static int previous_value_token = 0;

uInt8 sim_ReadDigitalU8(uInt32 port)
{


	extern char mg_ports[10][10];
	extern int ports_type[10];
	extern int PORTS_VALUES_AVAILABLE;


	uInt8 value = 0;

	//wait for first data
	while (PORTS_VALUES_AVAILABLE < 10)
		Sleep(1);

	
	// wait until the next data is received
	/*if (ports_type[port] == 0) {
		while (PORTS_VALUES_AVAILABLE == previous_value_token)
			Sleep(1);
	}*/
	
	
	
	if (mutex_sem != NULL)
		WaitForSingleObject(mutex_sem, INFINITE);
	
	//ESTA É A QUE CONTA
	value = (uInt8)atoi(mg_ports[port]);


	if (mutex_sem != NULL)
		ReleaseSemaphore(mutex_sem, 1, NULL);


	previous_value_token = PORTS_VALUES_AVAILABLE;

	return((uInt8) value);
}




void sim_WriteDigitalU8(uInt32 port, uInt8 data)
{
	extern char mg_ports[10][10];	
	extern int PORTS_VALUES_AVAILABLE;



	
	// reject the very first 10 data received
	while (PORTS_VALUES_AVAILABLE <10)
		Sleep(1);
	
	// wait until the next data is received
	//while (PORTS_VALUES_AVAILABLE <= previous_value_token)
	//	Sleep(1);
	

	//while (PORTS_VALUES_AVAILABLE <= previous_value_token)
	//	Sleep(1);
	
	if (mutex_sem != NULL)
		WaitForSingleObject(mutex_sem, INFINITE);

	//ESTA É A QUE CONTA
	sprintf_s(mg_ports[port], sizeof(mg_ports[port]), "%d", data);


	if (mutex_sem != NULL)
		ReleaseSemaphore(mutex_sem, 1, NULL);


	//este assign e' usado em close_channels
		
	
	//previous_value_token = PORTS_VALUES_AVAILABLE;
}


void sim_close_channels()
{
	
	void stop_mg_server(void);
	extern int PORTS_VALUES_AVAILABLE;

	while (PORTS_VALUES_AVAILABLE <= previous_value_token)
		Sleep(1);
	stop_mg_server();
	
}



/*****************REAL KIT CODE *******************/

int _WINDOWS_REAL_TIME_REQUEST_ = 0;

TaskHandle tasks[10];
void createDigitalInput(uInt32 port)
{
	if (_WINDOWS_REAL_TIME_REQUEST_ == 0) {
		BOOL aa = SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS);
		//printf("\naa=%d", aa);
		_WINDOWS_REAL_TIME_REQUEST_ = 1;
	}



	#ifdef _USE_REAL_KIT_
		char taskName[100];
		char portName[100];
		TaskHandle task_handle;
		sprintf(taskName,"task_di__%d",port);
		sprintf(portName,"Dev1/port%d",port);  
   		DAQmxCreateTask(taskName,&task_handle);
		DAQmxCreateDIChan(task_handle,portName,"",DAQmx_Val_ChanForAllLines);
		DAQmxStartTask(task_handle);
		tasks[port]=task_handle;			
			
	#else
		sim_create_DI_channel(port);
#endif 
}



void createDigitalOutput(uInt32 port)
{
	#ifdef _USE_REAL_KIT_
		char taskName[100];
		char portName[100];
		TaskHandle task_handle;	
		sprintf(taskName,"task_di__%d",port);
		sprintf(portName,"Dev1/port%d",port);   
		DAQmxCreateTask(taskName,&task_handle);
		DAQmxCreateDOChan(task_handle,portName,"",DAQmx_Val_ChanForAllLines);
		DAQmxStartTask(task_handle);		
		tasks[port]=task_handle;
#else
		sim_create_DO_channel(port);
#endif
   
}



uInt32 portos[20];


uInt8 readDigitalU8(uInt32 port)
{
	uInt8 data=0;
#ifdef _USE_REAL_KIT_
	int32		error_0=0;			
	char		errBuff_0[2048]={'\0'};
	int32		read_0;
	TaskHandle task_handle = tasks[port];
	DAQmxReadDigitalU8(task_handle,1,10.0,DAQmx_Val_GroupByChannel,&data,1,&read_0,NULL);				
#else 
	data=sim_ReadDigitalU8(port);
#endif

/*
	bool flag_error=false;
	if( (port==0) && !(portos[port] & 1<<2) && (data & 1<<2) && (portos[2]&1<<6))
		{printf("\nATTENTION: XX beyond left limit...\n");flag_error=true;}
	if( (port==0) && !(portos[port] & 1<<0) && (data & 1<<0) && (portos[2]&1<<7))
		{printf("\nATTENTION: XX beyond right limit...\n");flag_error=true;}
	if( (port==1) && !(portos[port] & 1<<3) && (data & 1<<3) && (portos[2]&1<<2))
		{printf("\nATTENTION: ZZ below lower limit...\n");flag_error=true;}
	if( (port==0) && !(portos[port] & 1<<6) && (data & 1<<6) && (portos[2]&1<<3))
		{printf("\nATTENTION: ZZ above upper limit...\n");flag_error=true;}
	if( (port==0) && !(portos[port] & 1<<5) && (data & 1<<5) && (portos[2]&1<<4))
		{printf("\nATTENTION: YY beyond OUTSIDE sensor...\n");	flag_error=true;}
	if( (port==0) && !(portos[port] & 1<<3) && (data & 1<<3) && (portos[2]&1<<5))
		{printf("\nATTENTION: YY beyond INSIDE sensor...\n");flag_error=true;}

	portos[port]=data;	
	if(flag_error) {
		WriteDigitalU8(2, 0);
		exit(0);
	}
	*/
	return(data);
}


void writeDigitalU8(uInt32 port, uInt8 data)
{

	
    portos[port]=data;


#ifdef _USE_REAL_KIT_ 
		int         error_1=0;
		char        errBuff_1[2048]={'\0'};
		int32		written_1;
		TaskHandle task_handle = tasks[port];		
		DAQmxWriteDigitalU8(task_handle,1,1,10.0,DAQmx_Val_GroupByChannel,&data,&written_1,NULL);	
#else 
		sim_WriteDigitalU8(port, data);		
#endif

}


void closeChannels()
{
	sim_close_channels();
	
}


