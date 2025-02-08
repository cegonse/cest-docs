# Testing C code

There are many C testing frameworks, such as the excellent [Unity Framework](https://www.throwtheswitch.org/unity). If you wish to be able to create more semantic, expressive test for your C code, you can leverage building your tests in C++ with Cest Framework.

## Setup

To avoid introducing additional complexity to this example, we will invoke the C and C++ compilers directly. We will assume `gcc` and `g++` are available in your system.

If you are using macOS and have installed XCode Build Tools, you will probably have to use CLang by invoking `clang` and `clang++`.

Finally, let's install the latest version of Cest Framework. You can get the latest version from [GitHub](https://github.com/cegonse/cest/releases),
or directly run in the terminal:

```bash title="Installing Cest Framework"
wget https://github.com/cegonse/cest/releases/download/v3/cest
```

## The C code under test

As in the first example, we will create a simple calculator app. Let's start by creating a C file to hold the business logic, along with its header to export the function.

```c title="calculator.c"
#include "calculator.h"

int Sum(int a, int b) {
  return a + b;
}
```

```c title="calculator.h"
#pragma once

int Sum(int a, int b);
```

## The test suite source file

Then, let's create a C++ file to hold the test for our business logic. Check the annotations (:material-plus-circle:) to know
more about each section of the test file.

```cpp title="calculator.test.cpp"
#include <cest>

extern "C" // (1)
{
  #include <calculator.h>
}

describe("Calculator", []() {
  it("performs addition", []() {
    expect(Sum(2, 2)).toEqual(4);
  });
});
```

1. We indicate the `calculator.h` header file should be included following the C naming convention. The compiler would expect mangled symbols otherwise, and compilation would fail.

## Compiling the C++ test with the C code

Now that we have all the source files in place, we can compile both the C code with the business logic, and the C++ test as a stand-alone executable.

To do this, we will compile both source files as object files with their respective compilers (C and C++ compilers). Then, invoke the C++ compiler to link all the object files into a single executable.

```bash title="Compiling and linking sources"
gcc -c calculator.c -o calculator.o
g++ -I. -c calculator.test.cpp -o calculator.test.o
g++ calculator.test.o calculator.o -o test_calculator
```

After compiling the test executable, we can run it to run our test:

```bash title="Running the test"
./test_calculator
 PASS  calculator.test.cpp:9 performs addition
```

## Next reading

After finishing this example, you have learned how to combine Cest Framework with C code to create expressive tests for your C code.

You can combine this example with the CMake example to create a powerful build system, capable of combining your C code with C++ tests while automating building of execution of your tests and applications.

<div class="grid cards" style="padding-top: 24px" markdown>
- [:octicons-arrow-left-24: Integrating with CMake](./cmake.md)
</div>
