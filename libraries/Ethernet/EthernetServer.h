#ifndef ethernetserver_h
#define ethernetserver_h

#include "Server.h"

class EthernetClient;

class EthernetServer : 
public Server {
private:
  uint16_t _port;
  void accept();
public:
  EthernetServer(uint16_t);
  EthernetClient available();
  virtual void begin();
#if defined(__PIC32MX__)
  virtual void write(uint8_t);
  virtual void write(const uint8_t *buffer, size_t size);
#else
  virtual size_t write(uint8_t);
  virtual size_t write(const uint8_t *buf, size_t size);
#endif
  using Print::write;
};

#endif
