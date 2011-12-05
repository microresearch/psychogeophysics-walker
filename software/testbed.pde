/* faking the env board with 7 parameters:

- 1)GPS, 2)high 3) low frequency electromagnetics 4) local temperature 5) light 6) entropy 7) magnetic field gradient

*/

#define GPS_STATUS_NO_COMMS 0
#define GPS_STATUS_BAD_COMMS 1
#define GPS_STATUS_NO_FIX 2
#define GPS_STATUS_FIX 3

void Wait_GPS_Fix(void);
int inByte;

// NMEA parsing from ArduPilot 2.2.3

// also see http://diydrones.com/profiles/blogs/using-the-5hz-locosys-gps-with

/***************************************************************************
 NMEA variables
 **************************************************************************/

/*GPS Pointers*/
char *token; //Some pointers
char *search = ",";
char *brkb, *pEnd;
char gps_buffer[100]; //The tradional buffer.
char lat[24]; char lon[24];

long refresh_rate=0;
int gpsStatus = GPS_STATUS_NO_COMMS;
//float lat=0; // store the Latitude from the gps
//float lon=0;// Store guess what?
char data_update_event=0; 
int numSatellites = 0;

const float t7=1000000.0;

//GPS Locosys configuration strings...
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

//#define LOCOSYS_SELECT_FIELDS "$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n" // this should turn Off all sentences except GGA and RMC
// duplicated by NMEA_OUTPUT_5HZ above

/****************************************************************
 Parsing stuff for NMEA
 ****************************************************************/
void init_gps(void)
{
  //  Serial1.begin(57600); // according to Cool Components this is th default for the LS20031
    Serial1.begin(9600); 
  delay(1000);
  Serial1.print(LOCOSYS_REFRESH_RATE_200);
  delay(500);
  Serial1.print(NMEA_OUTPUT_1HZ);
  delay(500);
  Serial1.print(SBAS_OFF);
  //Wait_GPS_Fix();
  //  Serial1.print(LOCOSYS_BAUD_RATE_9600);
  //  Serial1.begin(9600); 

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


            //Longitude in degrees, decimal minutes. (ej. 4750.1234 degrees decimal minutes = 47.835390 decimal degrees)
            //Where 47 are degrees and 50 the minutes and .1234 the decimals of the minutes.
            //To convert to decimal degrees, devide the minutes by 60 (including decimals), 
            //Example: "50.1234/60=.835390", then add the degrees, ex: "47+.835390=47.835390" decimal degrees
	    //            token = strtok_r(NULL, search, &brkb); //Contains Latitude in degrees decimal minutes... 
            token = strtok_r(NULL, search, &brkb); //Contains Latitude in degrees decimal minutes... 

	    strcpy(lat,token);
            //taking only degrees, and minutes without decimals, 
            //strtol stop parsing till reach the decimal point "."  result example 4750, eliminates .1234
	                temp=strtol (token,&pEnd,10);

            //takes only the decimals of the minutes
            //result example 1234. 
	                temp2=strtol (pEnd+1,NULL,10);

            //joining degrees, minutes, and the decimals of minute, now without the point...
            //Before was 4750.1234, now the result example is 47501234...
	    //            temp3=(temp*10000)+(temp2);
			

            //modulo to leave only the decimal minutes, eliminating only the degrees.. 
            //Before was 47501234, the result example is 501234.
	    //            temp3=temp3%1000000;


            //Dividing to obtain only the de degrees, before was 4750 
            //The result example is 47 (4750/100=47)
	    //            temp/=100;

            //Joining everything and converting to float variable... 
            //First i convert the decimal minutes to degrees decimals stored in "temp3", example: 501234/600000= .835390
            //Then i add the degrees stored in "temp" and add the result from the first step, example 47+.835390=47.835390 
            //The result is stored in "lat" variable... 
            //lat=temp+((float)temp3/600000);
			//			lat=temp+((float)temp2/10000);

            token = strtok_r(NULL, search, &brkb); //lat, north or south?

            //If the char is equal to S (south), multiply the result by -1.. 
            if(*token=='S'){
	      //              lat=lat*-1;
            }

            //This the same procedure use in lat, but now for Lon....
            token = strtok_r(NULL, search, &brkb);
	    //	    lon=token;
	    strcpy(lon,token);

            temp=strtol (token,&pEnd,10); 
            temp2=strtol (pEnd+1,NULL,10); 
	    //            lon=temp+((float)temp2/10000);

            token = strtok_r(NULL, search, &brkb); //lon, east or west?
            if(*token=='W'){
	      //              lon=lon*-1;
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
            else
              gpsStatus = GPS_STATUS_NO_FIX; // got data, at least
              
              
            token = strtok_r(NULL, search, &brkb); //satellites in use!! 
            numSatellites =atoi(token); 
            
            token = strtok_r(NULL, search, &brkb);//HDOP, not needed
	    //            token = strtok_r(NULL, search, &brkb);//ALTITUDE, is the only meaning of this string.. in meters of course. 

            if(gpsStatus != GPS_STATUS_FIX) 
            {

	      //              digitalWrite(13,HIGH); //Status LED...
            }
            else 
            {
               

	      //              digitalWrite(13,LOW);
            }
            data_update_event|=0x02; //Update the flag to indicate the new data has arrived.
          }
          checksum=0; //Restarting the checksum
        }

        for(int a=0; a<=counter; a++)//restarting the buffer
        {
          gps_buffer[a]=0;
        } 
        counter=0; //Restarting the counter
	//        GPS_timer=millis(); //Restarting timer...
      }
      else
      {
        counter++; //Incrementing counter
      }
    }
  }
  
}


void Wait_GPS_Fix(void)//Wait GPS fix...
{
  do
  {
    decode_gps();
    //    delay(250);
    //    Serial.println(gpsStatus);
  }
  while(gpsStatus != GPS_STATUS_FIX);// loop till we get a fix


  do
  {
    decode_gps(); //Reading and parsing GPS data  
    //    delay(250);
  }
  while((data_update_event&0x01!=0x01)&(data_update_event&0x02!=0x02));

}

void print_data(void)
{
  int x;
  if (strlen(lat)>4){
      Serial.print(lat);
      Serial.print(",");
      Serial.print(lon);
      
      //print extra ADC data
      for (x=0;x<7;x++){
	Serial.print(",");
	Serial.print(analogRead(x));
      }

      Serial.println("");
      }
}

void setup() {
  // initialize both serial ports:
  init_gps();
  Serial.begin(57600);
}

void loop() {

  Wait_GPS_Fix();
  print_data();

}

