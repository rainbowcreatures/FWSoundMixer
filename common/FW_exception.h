/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#ifndef FW_EXCEPTION_H
#define FW_EXCEPTION_H

#include <stdlib.h>
#include <exception>
#include <string>
#include <signal.h>

class MyException : public std::exception {
   private:
	   std::string s;
   public:
	   MyException(std::string ss);
	   ~MyException() throw ();
	   virtual const char* what() const throw();
};

#endif