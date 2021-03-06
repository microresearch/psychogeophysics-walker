/* env board functions for arduino

// GPS, temp, light, lf, hf, ttt(FGM), accum (RNG)

*/

#include <OneWire.h>
#include <DallasTemperature.h>
 
#define ONE_WIRE_BUS 21
 
OneWire oneWire(ONE_WIRE_BUS);
 
DallasTemperature sensors(&oneWire);
DallasTemperature setWaitForConversion(false);


#define GPS_STATUS_NO_COMMS 0
#define GPS_STATUS_BAD_COMMS 1
#define GPS_STATUS_NO_FIX 2
#define GPS_STATUS_FIX 3

void Wait_GPS_Fix(void);
int inByte;
const int selp=48;
unsigned long ttt;
char *token; 
char *search = ",";
char *brkb, *pEnd;
char gps_buffer[100];
char lat[24]; char lon[24];
long refresh_rate=0;
int gpsStatus = GPS_STATUS_NO_COMMS;
char data_update_event=0; 
int numSatellites = 0;

const float t7=1000000.0;

#define USE_SBAS 0
#define SBAS_ON "$PMTK313,1*2E\r\n"
#define SBAS_OFF "$PMTK313,0*2F\r\n"

#define NMEA_OUTPUT_5HZ "$PMTK314,0,5,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" //Set GGA and RMC to 5HZ  
#define NMEA_OUTPUT_4HZ "$PMTK314,0,4,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" //Set GGA and RMC to 4HZ 
#define NMEA_OUTPUT_3HZ "$PMTK314,0,3,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" //Set GGA and RMC to 3HZ 
#define NMEA_OUTPUT_2HZ "$PMTK314,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" //Set GGA and RMC to 2HZ 
#define NMEA_OUTPUT_1HZ "$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" //Set GGA and RMC to 1HZ

#define LOCOSYS_REFRESH_RATE_200 "$PMTK220,200*2C\r\n" //200 milliseconds 
#define LOCOSYS_REFRESH_RATE_250 "$PMTK220,250*29\r\n" //250 milliseconds
#define LOCOSYS_REFRESH_RATE_250 "$PMTK220,250*29\r\n" //250 milliseconds

#define LOCOSYS_BAUD_RATE_4800 "$PMTK251,4800*14\r\n"
#define LOCOSYS_BAUD_RATE_9600 "$PMTK251,9600*17\r\n"
#define LOCOSYS_BAUD_RATE_19200 "$PMTK251,19200*22\r\n"
#define LOCOSYS_BAUD_RATE_38400 "$PMTK251,38400*27\r\n"
#define LOCOSYS_BAUD_RATE_57600 "$PMTK251,57600*2\r\n"
#define LOCOSYS_BAUD_RATE_115200 "$PMTK251,115200*1F\r\n"

#define LOCOSYS_FACTORY_RESET "$PMTK104*37\r\n"

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

void init_gps(void)
{
  Serial1.begin(57600); // shld be 57600 
    delay(500);
    Serial1.print(LOCOSYS_REFRESH_RATE_200);
    Serial1.print(NMEA_OUTPUT_5HZ);
    delay(500);
    Serial1.print(SBAS_ON);
}

void decode_gps(void)
{
  const char head_rmc[]="GPRMC"; //GPS NMEA header to look for
  const char head_gga[]="GPGGA"; //GPS NMEA header to look for
    
  static byte unlock=1; //some kind of event flag
  static byte checksum=0; //the checksum generated
  static byte checksum_received=0; //Checksum received
  static byte counter=0; //general counter

  unsigned long temp=0;
  unsigned long temp2=0;
  unsigned long temp3=0;

  while(Serial1.available() > 0)
  {
      
    if(unlock==0)
    {
      gps_buffer[0]=Serial1.read();//puts a byte in the buffer
  
      if(gps_buffer[0]=='$')//Verify if is the preamble $
      {
        unlock=1; 
      }
    }

    else
    {
      gps_buffer[counter]=Serial1.read();

      if(gps_buffer[counter]==0x0A)//Looks for \F
      {

        unlock=0;

       if( gpsStatus == GPS_STATUS_NO_COMMS )
          gpsStatus = GPS_STATUS_BAD_COMMS;
          

        if (strncmp (gps_buffer,head_rmc,5) == 0)//looking for rmc head, for lat/long, speed, and course
        {

          /*Generating and parsing received checksum, */
          for(int x=0; x<100; x++)
          {
            if(gps_buffer[x]=='*')
            { 
              checksum_received=strtol(&gps_buffer[x+1],NULL,16);//Parsing received checksum...
              break; 
            }
            else
            {
              checksum^=gps_buffer[x]; //XOR the received data... 
            }
          }

          if(checksum_received==checksum)//Checking checksum
          {
            /* Token will point to the data between comma "'", returns the data in the order received */
            /*THE GPRMC order is: UTC, UTC status ,Lat, N/S indicator, Lon, E/W indicator, speed, course, date, mode, checksum*/
            token = strtok_r(gps_buffer, search, &brkb); //Contains the header GPRMC, not used

            token = strtok_r(NULL, search, &brkb); //UTC Time, not used
            //time=  atol (token);
            token = strtok_r(NULL, search, &brkb); //Valid UTC data? maybe not used... 
            token = strtok_r(NULL, search, &brkb); //Contains Latitude in degrees decimal minutes... 

	    strcpy(lat,token);
	    temp=strtol (token,&pEnd,10);
	    temp2=strtol (pEnd+1,NULL,10);

            token = strtok_r(NULL, search, &brkb); //lat, north or south?

            if(*token=='S'){
	      //              lat=lat*-1; // TODO: *FIX*
            }

            token = strtok_r(NULL, search, &brkb);
	    //	    lon=token;
	    strcpy(lon,token);

            temp=strtol (token,&pEnd,10); 
            temp2=strtol (pEnd+1,NULL,10); 

            token = strtok_r(NULL, search, &brkb); //lon, east or west?
            if(*token=='W'){
	      //              lon=lon*-1; // TODO: *FIX*

            }

            if( gpsStatus == GPS_STATUS_NO_COMMS )
              gpsStatus = GPS_STATUS_NO_FIX; // got data, at least
              
            data_update_event|=0x01; //Update the flag to indicate the new data has arrived. 
          }
          checksum=0;
        }//End of the GPRMC parsing

        if (strncmp (gps_buffer,head_gga,5) == 0)//now looking for GPGGA head, for fix quality and altitude
        {
          /*Generating and parsing received checksum, */
          for(int x=0; x<100; x++)
          {
            if(gps_buffer[x]=='*')
            { 
              checksum_received=strtol(&gps_buffer[x+1],NULL,16);//Parsing received checksum...
              break; 
            }
            else
            {
              checksum^=gps_buffer[x]; //XOR the received data... 
            }
          }

          if(checksum_received==checksum)//Checking checksum
          {

            token = strtok_r(gps_buffer, search, &brkb);//GPGGA header, not used anymore
            token = strtok_r(NULL, search, &brkb);//UTC, not used!!
            token = strtok_r(NULL, search, &brkb);//lat, not used!!
            token = strtok_r(NULL, search, &brkb);//north/south, nope...
            token = strtok_r(NULL, search, &brkb);//lon, not used!!
            token = strtok_r(NULL, search, &brkb);//wets/east, nope
            
            token = strtok_r(NULL, search, &brkb);//Position fix, used!!
            
            int fixQuality =atoi(token); 
            if(fixQuality != 0) // 0 - no fix, 1 and up - various sorts of fix
              gpsStatus = GPS_STATUS_FIX; // got a fix
            else {
              gpsStatus = GPS_STATUS_NO_FIX; // got data, at least
              
              
	      token = strtok_r(NULL, search, &brkb); //satellites in use!! 
	      numSatellites =atoi(token); 
            
	      //  Serial.print("e: sats: ");
	      // Serial.println(numSatellites);
	    }

            token = strtok_r(NULL, search, &brkb);//HDOP, not needed

            data_update_event|=0x02; //Update the flag to indicate the new data has arrived.
          }
          checksum=0; //Restarting the checksum
        }

        for(int a=0; a<=counter; a++)//restarting the buffer
        {
          gps_buffer[a]=0;
        } 
        counter=0; //Restarting the counter
      }
      else
      {
        counter++;
      }
    }
  }
  
}


void Wait_GPS_Fix(void)
{
  do
  {
    decode_gps();
    //            delay(25); // TODO: delays! // was 250
  }
  while(gpsStatus != GPS_STATUS_FIX);// loop till we get a fix


  do
  {
    decode_gps();
    //        delay(25); // was 250
  }
  while((data_update_event&0x01!=0x01)&(data_update_event&0x02!=0x02));

}

void setup() {
  Serial.begin(57600);
  init_gps();
  DDRB = (1<<PB1) | (1<<PB0);	 // Set SCK and SS as out
  SPCR = ( (1<<SPE)|(1<<MSTR)|(1<<CPHA));	// Enable SPI, Master, set clock rate fck/128  -- faster
  PORTB|=0x01;

  sbi(ADCSRA,ADPS2) ;
  cbi(ADCSRA,ADPS1) ;
  cbi(ADCSRA,ADPS0) ;

  pinMode(selp, OUTPUT); // SS for slave
  pinMode(17, OUTPUT);

  sensors.begin();
  delay(100);
}

void loop() {
  int light, hf, lf, x, xx, y, accum, alt =0, www, c = 0;
  float temp;
  // temperature and light (ADC0)

  
    sensors.requestTemperatures();
  light=analogRead(0);
  lf=analogRead(1); 
  hf=analogRead(2); // seems in this order

  accum=0;
  for (y=0;y<100;y++){
    decode_gps();

    for (x=0;x<166;x++){
      www = analogRead(3); //??? // speed also???
      c=www&0x01;
      if (c==0) xx++;
    }
    if ((xx&1)==1) x=0;
    else x=1;
    xx=0;
    x= x ^ alt;
    alt= alt ^ 1;
    if (x==1)	accum++;
  }



  // reading the FGM board
    digitalWrite(selp, LOW);
  SPDR=0x01;
  while(!(SPSR & (1<<SPIF)));
  ttt=(unsigned char)SPDR;
  delayMicroseconds(100);
  SPDR=0x01;
  while(!(SPSR & (1<<SPIF)));
  ttt+=(unsigned int)(SPDR)<<8;
  digitalWrite(selp, HIGH);
    

  temp=sensors.getTempCByIndex(0);
  

  // GPS, temp, light, lf, hf, ttt(FGM), accum (RNG)

  //    Wait_GPS_Fix(); // resolve delay issues

  //  decode_gps();
    

      if (strlen(lat)>4){
    Serial.print("e: ");
    Serial.print(lat);
    Serial.print(",");
    Serial.print(lon);
    Serial.print(",");
    Serial.print(temp);
    Serial.print(",");
    Serial.print(light);
    Serial.print(",");
    Serial.print(lf);
    Serial.print(",");
    Serial.print(hf);
    Serial.print(",");
    Serial.print(ttt);
    Serial.print(",");
    Serial.print(accum);
    Serial.println("\r\n");

    // flash PH0
    PORTH ^= _BV(0);

    }

}
