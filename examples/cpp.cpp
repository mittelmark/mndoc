// -!- C++ -!- ///////////////////////////////////////////////////////////////
//
// Copyright (C) 2025 MicroEmacs User.
//
// All rights reserved.
//
// Synopsis:    
// Authors:     MicroEmacs User
//
//////////////////////////////////////////////////////////////////////////////
#include <iostream>

/*#'
**hello()**
   
> Say hello to the user!

> ```cpp
hello();
> ```
*/

void hello () {
    std::cout << "Hello C++ World!" << std::endl;
}

int main (int argc, char * argv[]) {
    hello();
    return(0);
}

