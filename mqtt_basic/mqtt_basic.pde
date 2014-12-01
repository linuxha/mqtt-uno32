/*
 Basic MQTT example 
 
  - connects to an MQTT server
  - publishes "hello world" to the topic "outTopic"
  - subscribes to the topic "inTopic"

  - Uses the Ethernet library in the user lib (W5500)
*/

#define WIZ550io_WITH_MACADDRESS 1
int myline;

#include <stdlib.h>

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>

#include <DHT22.h>

// o Pin 2 DHT
// o Pin 1 (Tx)
// o Pin 0 (Rx)
#define DHTPIN   2

DHT22 dht(DHTPIN);

// Update these with values suitable for your network.
byte server[] = { 192, 168, 24, 2 };

/*
*/
void
callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
  Serial.println("handle message arrived");
  Serial.print("Topic/Payload: ");
  Serial.print(topic);
  Serial.print("/");
  for(int i = 0; i< length; i++) {
    Serial.print(payload[i]);
  }
  Serial.println();
}

EthernetClient ethClient;
PubSubClient client(server, 1883, callback, ethClient);

unsigned long old;

float h;
// Read temperature as Celsius
float t;

void
pause() {
    Serial.print("\nPause :");
    while(!Serial.available());
    Serial.print("\n");
}

void
ipPrint(byte ipaddr[])   {
    for(int i = 0; i < 4; i++) {
	Serial.print(ipaddr[i], DEC);
	Serial.print(".");
    }
    Serial.println();
}

void setup() {
    int r;
    Serial.begin(9600);
    //pause();
    Serial.println("\nPubSub");

    //Ethernet.begin(mac, ip);
    Ethernet.begin();
    Serial.print("server is at ");
    Serial.println(Ethernet.localIP(), HEX);
    ipPrint(server);

    if ((r = client.connect("arduinoClient")) || 1==1 ) {
	Serial.print("outTopic: hello world (");
	Serial.print( r );
	Serial.print(") ");
	Serial.println(myline);

	// I wonder how many pub/subs the library can support?
	client.publish("outTopic","hello world");
	client.subscribe("inTopic");
    }

    old = millis();
    h   = -1;
    t   = -1;
    Serial.println("Fall into loop");
}

void loop() {
    char str[64];
    char t[8];
    
    DHT22_ERROR_t errorCode;

    client.loop();

    // -[ DHT ]-----------------------------------------------------------------
    // Deal with reading the DHT22
    if(millis() - old > 30000) {
	old = millis();
    
	errorCode = dht.readData();
	switch(errorCode) {
	    case DHT_ERROR_NONE:
                // Floats don't work too well as float to char * isn't easy
                // and it consumes a lot of storage (32k vs 64k)
                //sprintf(str, "Humidity = %0.2f, Temperature = %0.2f", dht.getTemperatureC(), dht.getHumidity());
                str[0] = '\0';
                strcat(str, "Temperature = ");
                itoa(dht.getTemperatureCInt()/10, t, 10);
                strcat(str, t);
                strcat(str, ".");
                itoa(abs(dht.getTemperatureCInt()%10), t, 10);
                strcat(str, t);

                strcat(str, ", Humidity = ");
                itoa(dht.getHumidityInt()/10, t, 10);
                strcat(str, t);
                strcat(str, ".");
                itoa(dht.getHumidityInt()%10, t, 10);
                strcat(str, t);

                client.publish("outTopic", str);
		break;
	    case DHT_ERROR_CHECKSUM:
		Serial.print("check sum error ");
		break;
	    case DHT_BUS_HUNG:
		Serial.println("BUS Hung ");
		break;
	    case DHT_ERROR_NOT_PRESENT:
		Serial.println("Not Present ");
		break;
	    case DHT_ERROR_ACK_TOO_LONG:
		Serial.println("ACK time out ");
		break;
	    case DHT_ERROR_SYNC_TIMEOUT:
		Serial.println("Sync Timeout ");
		break;
	    case DHT_ERROR_DATA_TIMEOUT:
		Serial.println("Data Timeout ");
		break;
	    case DHT_ERROR_TOOQUICK:
		Serial.println("Polled to quick ");
		break;
	}
    }
}

// --[ Notes ]----------------------------------------------------------------
/*
ASCII Table

30 40 50 60 70 80 90 100 110 120
-------------      ---------------------------------
0:    (  2  <  F  P  Z  d   n   x
1:    )  3  =  G  Q  [  e   o   y
2:    *  4  >  H  R  \  f   p   z
3: !  +  5  ?  I  S  ]  g   q   {
4: "  ,  6  @  J  T  ^  h   r   |
5: #  -  7  A  K  U  _  i   s   }
6: $  .  8  B  L  V  `  j   t   ~
7: %  /  9  C  M  W  a  k   u  DEL
8: &  0  :  D  N  X  b  l   v
9: ´  1  ;  E  O  Y  c  m   w


  Protocol description

  Note that "board" will always be 'A' as only one board is supported at this time.
  This may change in the future.

  The board reads setup information according to the following rules:
 
  Digital pins available      : 2 - 13 and A0 - A5 if no analog is used
  Analog Input pins available : A0 - A5 
  Analog Output pins          : 3,5,6,9,10,11

  Note: pins 0 - 1 and 10 - 13 have special uses,
	* Pins 0 and 1 are the serial port, 0 - RX, 1 - TX
        * Ethernet shield attached to pins 10, 11, 12, 13

  Pin 13 is connected to the on board LED and can't be used without an external
  pulldown resister 
 
  Every command to the board is three or four characters.
 

  [Board] [I/O direction] [Pin]
  ===========================================================================
  [Board] 	- 'A'
  [I/O]		- 'DN<pin>' Configure as Digital Input no internal pullup (default)
  - 'DI<pin>'     "      " Digital Input uses internal pullup
  - 'DO<pin>'     "      " Digital Output 
  - 'AI<pin>'     "      " Analog Input
  - 'AO<pin>'     "      " Analog Output
  - 'L<pin>'  Set Digital Output to LOW
  - 'H<pin>'  Set Digital Output to HIGH
  - '%<pin><value>'  Set Analog Output to value (0 - 255)
  [Pin]		- Ascii 'C' to 'T'  C = pin 2, R = pin A3, etc
 
  If it's on a multidrop network:
    <Board><Pin><Cmd ...> ,- This is the way I want it
    <Board><Cmd><Pin><args ...> ,- This is the way I want it

  otherwise
    <Board><Cmd><Pin><args ...> ,- This is the way I want it

  <Board> is used as the attention command, so we need something.

  Examples transmitted to board <-  This is where George did odd things:
  ADIF	Configure pin 5 as digital input with pullup (AFDI)
  AAIR	Configure pin A3 as analog input (ARAI)
  AHE	Set digital pin 4 HIGH (AEH)
  A%D75	Set analog output to value of 75 (AD%75)

  Examples received from board:  NOTE the end of message (eom) char '.'
  AHE.	Digital pin 4 is HIGH
  ALE.	Digital pin 4 is LOW
  AP89.	Analog pin A1 has value 89
	
  Available pins, pins with ~ can be analog Output
  pins starting with A can be Analog Input
  All pins can be digital except 0 and 1
  ----------------------------------------------------------------------------
  02 03 04 05 06 07 08 09 10 11 12 13 A0 A1 A2 A3 A4 A5
  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T
  ~     ~  ~        ~  ~  ~
  ============================================================================ 
  The board will return a '?' on error.
  The board will return a '!' on power up or reset.
  The board will return it's name and address if sent a '?'

  The Uno32 will have a different configuration.

Notes:

If I remember correctly, I tought there was some option to reduce code
size by removing some of function of the library, does this apply to
this version too ?  you may reduce by aprox. 5kb by switching off UDP
(and at the same time DNS and DHCP as this requires UDP). This can be
configured in uipethernet-conf.h

If RAM is an issue you may also configure number of concurrent sockets
and number of pakets per socket, but this will not reduce the
foodprint in flash.

void loop() {
    int direction;
    char avalue[5];

    if (Serial.available() > 0) {
	// right now we handle one board which is board 'A'
	char rx_cmd = Serial.read();

	if (rx_cmd == board ) {
	    //Serial.write("Board A\n");
	    while (Serial.available() == 0) {
		delayMicroseconds(100);
	    }

	    cmd = Serial.read();
	    //Serial.write(cmd);
            
	    //Serial.write(" Command\n");
	    //Serial.print(sin);

	    switch (cmd) {
		case 'H':        // 'H' set digital pin HIGH
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }

		    chn = Serial.read();
		    pin = chn - 65;

		    if (pin > 1) {
			if (ioPinsDirection[pin] == 1)                    
			    digitalWrite(pin, HIGH);
		    } else {
			Serial.write(error);  //error, pins 0 and 1 can't be used
		    }
		    break;              

		case 'L':        // 'L' set digital pin LOW
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }
		    chn = Serial.read();
		    pin = chn - 65;
		    if (pin > 1) {
			if (ioPinsDirection[pin] == 1)
			    digitalWrite(pin, LOW);
		    } else {
			Serial.write(error);
		    }
		    break;               

		case '%':        // '%' set analog out value
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }
		    chn = Serial.read();
		    //Serial.write(chn);
                    
		    Serial.readBytesUntil('.', avalue, 4);
		    //Serial.println(avalue);		
		    pin = chn - 65;
		    if (pin > 1) {
			if (ioPinsDirection[pin] == 3) {
			    //Serial.println("analog write...");                        
			    analogWrite(pin, atoi(avalue));
			}
		    } else {
			Serial.write(error);
		    }
		    break;               


		case 'A':	// 'A' configure as analog
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }

		    direction = Serial.read();
        	    
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }

		    chn = Serial.read();
		    
		    pin = chn - 'A';

		    if (pin >= 14 && pin <= 19) {
			if (direction == 'I') {
			    ioPinsDirection[pin] = 2;  // pin is analog input
			    analogRead(pin);
			}
		    } else if (direction == 'O') {
			if (pin == 3 || pin == 5 || pin == 6 | pin == 9 || pin == 10 || pin == 11) {
			    ioPinsDirection[pin] = 3;  // pin is analog output
			} else {
			    Serial.write(error);
			}
		    } else {
			Serial.write(error);  // error
		    }
		    break;

		case 'D':	// 68 'D' configure as Digital pin 
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }
		    direction = Serial.read();
        	    
		    while (Serial.available() == 0) {
			delayMicroseconds(100);
		    }
		    chn = Serial.read();
		    
		    // pin = chn - 65;
		    pin = chn - 'A';
		    if (pin >= 2 && pin <= 19) {
			if (direction == 'I') {
			    ioPinsDirection[pin] = 0;  // pin is digital input with pullup
			    pinMode(pin, INPUT_PULLUP);
			} else if (direction == 'N') {
			    ioPinsDirection[pin] = 0;  // pin is digital input
			    pinMode(pin, INPUT);
			} else if (direction == 'O') {
			    ioPinsDirection[pin] = 1;  // pin is digital output
			    pinMode(pin, OUTPUT);
			    digitalWrite(pin,LOW);
			    //Serial.write(chn);
			    //Serial.write(" Pin set to output");
			}		
		    } else {
			Serial.write(error);
		    }
		    break;
	    }
	} else if (rx_cmd == '?') {
	    Serial.print(id);
	    Serial.write(' ');
	    Serial.write(board);
	}
    }
    // loop through all the inputs
    for (int i=2; i<19; i++) {
	if (ioPinsDirection[i] == 0) { // digital
	    int bit = digitalRead(i);
	    // if the bit is changed transmit otherwise ignore
	    if (ioPinsValue[i] != bit) {
		ioPinsValue[i] = bit;
		Serial.write('A');	//tx board
		Serial.write(i+65);	// tx channel aka pin
		if (bit == LOW) {
		    Serial.write('L');
		}	else {
		    Serial.write('H');
		}
		Serial.write(eom);
	    }
	} else if (ioPinsDirection[i] == 2) { // analog

	    int av = analogRead(i) / 10;
	    
	    // if the value is changed transmit otherwise ignore
	    if (ioPinsValue[i] <= av-2 || ioPinsValue[i] >= av+2) {
		ioPinsValue[i] = av;
		Serial.write('A');	//tx board
		Serial.write(i+65);
		Serial.print(av);	// tx channel aka pin
		Serial.write(eom);		
	    }
	}
    }
}
*/