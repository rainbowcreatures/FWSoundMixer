/**
 * FLASHYWRAPPERS: FWSoundMixer
 *   
 * @author Pavel Langweil
 * @version 1.0
 *
 * A simple sound mixer SWC / ANE to help FlashyWrappers with recording audio. Can be used as standalone too.
 *
 */

#include "FW_exception.h"

MyException::MyException(std::string ss) : s(ss) {}
MyException::~MyException() throw () {} // Updated
const char* MyException::what() const throw() { return s.c_str(); }
