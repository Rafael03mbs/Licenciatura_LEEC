#include <WiFi.h>
#include "secrets.h"
#include "ThingSpeak.h" // always include thingspeak header file after other header files and custom macros

char ssid[] = SECRET_SSID;   // your network SSID (name)
char pass[] = SECRET_PASS;   // your network password
int keyIndex = 0;            // your network key Index number (needed only for WEP)
WiFiClient  client;

unsigned long myChannelNumber = SECRET_CH_ID;
const char * myWriteAPIKey = SECRET_WRITE_APIKEY;

void setup() {
  Serial.begin(115200);  //Initialize serial
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo native USB port only
  }

  WiFi.mode(WIFI_STA);
  ThingSpeak.begin(client);  // Initialize ThingSpeak
}

// Initialize our values
// Vetores
float ValorTensaoVetor[1000] = {0};
float ValorCorrenteVetor[1000] = {0};

//Variáveis
float mediaTensao = 0;
float mediaCorrente =0;
float tensao_total =0;
float corrente_total=0;
float ValorTensao = 0;
float ValorCorrente = 0;
float PotenciaAtiva = 0;
float PotenciaAparente = 0;
float FatorPotencia = 0;
float FrequenciaTensao = 0;
float FrequenciaCorrente = 0;
unsigned long aux_timer = 0;
int Nr_amostras = 1000;
int i;
unsigned long timer_out = 0;

float Calculo_Valor_Eficaz(float valor[1000]){
  float Valor_eficaz = 0;
  for(i = 0; i < Nr_amostras; i++){
    Valor_eficaz += valor[i]*valor[i];
  }
  Valor_eficaz = Valor_eficaz/1000;
  return sqrt(Valor_eficaz);
}

float analogread(int analog_pin) {
  float x = analogRead(analog_pin);
  float tensao_x = (x / 4095) * 3.3;
  //Serial.println(tensao_x);
  return tensao_x;
}

float calcular_fatorP(float ValorTensaoVetor[1000], float ValorCorrenteVetor[1000], float PotenciaAparente) {
  float potencia_total = 0;
  float potencia_media = 0;

  for(i=0; i<1000; i++) {
    potencia_total += ValorTensaoVetor[i]*ValorCorrenteVetor[i];
  }
  potencia_media = potencia_total/1000;
  return(potencia_media/PotenciaAparente);
}

float calcular_frequencia(float sinal[1000]){
  int B = 0, inicio = 0, fim = 0;
  float Periodo;
  
  for(int i = 0; i < 1000 - 1; i++){
    if((sinal[i] * sinal[i + 1] < 0) || (sinal[i] == 0)){
      if(B == 0) {
        inicio = i;
        B++;
      } else if(B == 1) {
        fim = i;
        B++;
      }
    }
  }
  
  // Verificar se `fim` é maior que `inicio`
  if(fim > inicio) {
    Periodo = (fim - inicio) * 2 * 0.0002;
    // Verificar se o período é diferente de zero antes de retornar a frequência
    if(Periodo != 0){
      return 1 / Periodo;
    }
  }
  
}

void sendFieldThingSpeak() {

  // set the fields with the values
  ThingSpeak.setField(1, ValorTensao);
  ThingSpeak.setField(2, ValorCorrente);
  ThingSpeak.setField(3, PotenciaAtiva);
  ThingSpeak.setField(4, PotenciaAparente);
  ThingSpeak.setField(5, FatorPotencia);
  ThingSpeak.setField(6, FrequenciaTensao);
  ThingSpeak.setField(7, FrequenciaCorrente);

  // write to the ThingSpeak channel
  int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
  if (x == 200) {
    Serial.println("Channel update successful.");
  }
  else {
    Serial.println("Problem updating channel. HTTP error code " + String(x));
  }
}

void loop() {
    for ( i = 0; i< Nr_amostras; i++){
      timer_out = micros();
      ValorTensaoVetor[i] = analogread(34)*2*132;
      ValorCorrenteVetor[i] = analogread(35)*20;
      //Serial.println( ValorTensaoVetor[i]);
      //Serial.println( ValorCorrenteVetor[i]);
      tensao_total += ValorTensaoVetor[i];
      corrente_total += ValorCorrenteVetor[i];
      
      while((micros()-timer_out) < 200);
    }
    aux_timer = micros();
    // Connect or reconnect to WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(SECRET_SSID);
    while (WiFi.status() != WL_CONNECTED) {
      WiFi.begin(ssid, pass);  // Connect to WPA/WPA2 network. Change this line if using open or WEP network
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected.");
  }
  
    mediaTensao = tensao_total/1000;
    mediaCorrente = corrente_total/1000;
    for ( i = 0; i< Nr_amostras; i++){
      ValorTensaoVetor[i] = ValorTensaoVetor[i]-mediaTensao;
      ValorCorrenteVetor[i] = ValorCorrenteVetor[i] - mediaCorrente;
      //Serial.println( ValorCorrenteVetor[i]);
    }

    ValorTensao = Calculo_Valor_Eficaz(ValorTensaoVetor);
    Serial.println("Tensao eficaz");
    Serial.println(ValorTensao);
    ValorCorrente = Calculo_Valor_Eficaz(ValorCorrenteVetor);
    Serial.println("Corrente eficaz");
    Serial.println(ValorCorrente);

    PotenciaAparente = ValorTensao*ValorCorrente;
    Serial.println("Potencia Aparente");
    Serial.println(PotenciaAparente);
    FatorPotencia = calcular_fatorP(ValorTensaoVetor, ValorCorrenteVetor, PotenciaAparente);
    Serial.println("Fator Potencia");
    Serial.println(FatorPotencia);

    PotenciaAtiva = PotenciaAparente*FatorPotencia;
    Serial.println("Potencia Ativa");
    Serial.println(PotenciaAtiva);

    FrequenciaTensao = calcular_frequencia(ValorTensaoVetor);
    Serial.println("Freq. Tensao");
    Serial.println(FrequenciaTensao);
    FrequenciaCorrente = calcular_frequencia(ValorCorrenteVetor);
    Serial.println("Freq. Corrente");
    Serial.println(FrequenciaCorrente);
    
    tensao_total = 0;
    corrente_total = 0;
    
    while (micros() - aux_timer < 60000000 ) {}
      sendFieldThingSpeak();
    
}
