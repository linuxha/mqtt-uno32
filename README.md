mqtt-uno32
==========

This project utilizes the Chipkit Uno32, WIZnet W550io board and a DHT22 temperature and humidity sensor connect to a MQTT server. It's purpose is to publish the humidity and temperature every 30 seconds or so to the 'outTopic'. I also have a subscription to the 'inTopic' which prints various information to the serial port. At the moment I don't have the <abbr name="Home Automation">HA</abbr> software interfaced to MQTT. I'll add that software later, most likely Misterhouse to start with.

I've taken a little bit of time to port the Arduino 1.0 WIZnet Ethernet libraries to the ChipKit Uno32 and MPIDE. I've also added some libraries that were missing such as DNS and DHCP. I don't recall having to make any changes to the MQTT PubSubClient library or the DHT22 library.

The reason for this file structure is so I can download the entire tree to other systems I work with and not hav to worry I'm missing files. I'll probably need to keep an eye out for updates of the MQTT PubSubClient and the DHT22 libraries.

## Installation

Copy the directory structure under mqtt-uno32 to your sketchbook directory. Becareful to backup that directory structure if you have files and directories with the same names.

## Features

  * Publishes to outTopic, the humidity (%) and temperature (Celcius) to MQTT
  * Subscribes to inTopic and write related information to the serial port

## Pins used

 UNO32 | W550io | |
 Pins  | Pins | Asignment | Description
-------|-------|-----------|--------------------
 (4) | - | SS | (SD Card, optional)
 (10) | (6)| SS | (WizNet)
 (11) | (3)| MOSI | (SPI Pin 4)
 (12) | (4)| MISO | (SPI Pin 1)
 (13) | (5)| SCK | (SPI Pin 3)
 (  ) | () | N_RST | (SPI Pin 5)
 (  ) | () | N_RDY |
 (  ) | () | N_INT |
 (  ) | () | GND | (SPI Pin 6)
 (  ) | () | 3v3 | (Power Header)
 - | - | 5v0 | (SPI Pin 2)
 | | |
 (2) | - | DHT22 |


## Sample output
* Command:
** mosquitto_sub -d -t '#'

* Output:
'''
Received PUBLISH (d0, q0, r0, m0, 'outTopic', ... (35 bytes))
Temperature = 21.8, Humidity = 41.2
Received PUBLISH (d0, q0, r0, m0, 'outTopic', ... (35 bytes))   
Temperature = 21.9, Humidity = 41.3
Sending PINGREQ
Received PINGRESP
Received PUBLISH (d0, q0, r0, m0, 'outTopic', ... (35 bytes))
Temperature = 21.9, Humidity = 41.5
Received PUBLISH (d0, q0, r0, m0, 'outTopic', ... (35 bytes))
Temperature = 21.9, Humidity = 41.0
'''
## Philosophy

As with most personal projects, I wanted to play with a few unfamiliar technologies. In this case MQTT, the MicroChip PIC32MX base ChipKit Uno32 (not the larger Mega32) and the WIZnet Ethernet boards. For a long time I've wanted to connect a remote node to my home network and not something connected to a serial port. Almost all the examples are of the larger Arduino Megas or Chipkit Mega32 or serially attached Arduino Unos and Chipkit Uno32. In addition I wanted to get the Arduino's Ethernet library ported to MPIDE. In addition I wanted to experiment with MQTT which should make it easy to publish and subscribe from multiple servers, services and devices.

## Attributions (and thanks)

  * Ethernet - Soohwan Kim - http://github.com/Wiznet/WIZ_Ethernet_Library (Arduino 1.0.x)
  * DHT22 - Trevor's Electonics Blog - http://electronics.trev.id.au/2013/07/11/dht22-rht03-temp-humidity-library-for-chipkit-and-arduino-1-x/
  * MQTT - PubSubClient - http://knolleary.net/arduino-client-for-mqtt/ and https://github.com/knolleary/pubsubclient

## License 

Undecided