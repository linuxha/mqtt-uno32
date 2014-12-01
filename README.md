mqtt-uno32
==========

Chipkit Uno32, WIZnet W550io board and a DHT22 temperature and humidity sensor connect to a MQTT server.

## Installation

Copy the directory structure under mqtt-uno32 to your sketchbook directory. Becareful to backup that directory structure if you have files and directories with the same names.

## Features

  * Publishes to outTopic, the humidity (%) and temperature (Celcius) to MQTT
  * Subscribes to inTopic

## Philosophy

I've wanted to get a remote node connected to my home network for a while. Almost all the examples are of the larger Arduino Megas or Chipkit Mega32 or serially attached Arduino Unos and Chipkit Uno32. In addition I wanted to get the Arduino's Ethernet library ported to MPIDE. In addition I wanted to experiment with MQTT which should make it easy to publish and subscribe from multiple servers, services and devices.

## Attributions

  * Ethernet - Soohwan Kim - http://github.com/Wiznet/WIZ_Ethernet_Library (Arduino 1.0.x)
  * DHT22 - Trevor's Electonics Blog - http://electronics.trev.id.au/2013/07/11/dht22-rht03-temp-humidity-library-for-chipkit-and-arduino-1-x/
  * MQTT - PubSubClient - http://knolleary.net/arduino-client-for-mqtt/ and https://github.com/knolleary/pubsubclient

## License 

Undecided