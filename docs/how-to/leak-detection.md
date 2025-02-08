# Detecting memory leaks

Memory leaks are one of the most common pitfalls C and C++ developers face when developing complex applications. Thankfully, there are many tools that help with detecting and avoiding memory leaks during development.

One such tool is Google's [Leak Sanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer), part of Address Sanitiizer, which comes built-in with new versions of the GNU C Compiler and Clang. Leak Sanitizer instruments calls to memory allocations and deallocations, and generates a report upon program termination if there are any potential leaks.

Cest Framework includes support to call Leak Sanitizer's instrumentation from the test itself, causing tests to fail when a leak is detected.

In this how to guide, we will see how to compile a Cest Framework test with Leak Sanitizer enabled.

## Setup

To avoid introducing additional complexity to this example, we will invoke the C++ compiler directly. We will assume `g++` is available in your system.

If you are using macOS and have installed XCode Build Tools, you will probably have to use CLang by invoking `clang++`.

Finally, let's install the latest version of Cest Framework. You can get the latest version from [GitHub](https://github.com/cegonse/cest/releases),
or directly run in the terminal:

```bash title="Installing Cest Framework"
wget https://github.com/cegonse/cest/releases/download/v3/cest
```

## Test code with a memory leak

To showcase how Leak Sanitizer and Cest Framework work together, we will create a simple test that allocates memory but does not free it.

```cpp title="leak.test.cpp"
#include <cest>

describe("Test with leaks", []() {
  it("does not free its memory", []() {
    int *ptr = new int;
    *ptr = 123;
  });
});
```

## Compiling with Leak Sanitizer support

Now that we have the test file in place, we can compile it with Leak Sanitizer enabled. We will do so by enabling full address sanitization, as Leak Sanitizer is a sub-module of Address Sanitizer. Cest Framework will automatically detect that Leak Sanitizer has been enabled at compile time.

```bash title="Compiling and linking sources"
g++ -g -I. -fsanitize=address leak.test.cpp -o test_leaks
```

After compiling the test executable, we can run it to see the results:

```bash title="Running the test"
./test_leaks
 FAIL  leak.test.cpp:4 does not free its memory
 Failed at line 4: Detected potential memory leaks during test execution.
   1 |
   2 | describe("Test with leaks", []() {
   3 |   it("does not free its memory", []() {
 > 4 |     int *ptr = new int;
   5 |     *ptr = 123;
   6 |   });
   7 | });
AddressSanitizer result:

=================================================================
==14523==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 4 byte(s) in 1 object(s) allocated from:
    #0 0x7fb10bd82647 in operator new(unsigned long) ../../../../src/libsanitizer/asan/asan_new_delete.cpp:99
    #1 0x55ae1c44574f in operator() /tmp/leak.test.cpp:3
    #2 0x55ae1c4473a9 in __invoke_impl<void, <lambda()>::<lambda()>&> /usr/include/c++/10/bits/invoke.h:60
    #3 0x55ae1c446dfc in __invoke_r<void, <lambda()>::<lambda()>&> /usr/include/c++/10/bits/invoke.h:153
    #4 0x55ae1c446696 in _M_invoke /usr/include/c++/10/bits/std_function.h:291
    #5 0x55ae1c44aa07 in std::function<void ()>::operator()() const /usr/include/c++/10/bits/std_function.h:622
    #6 0x55ae1c442584 in cest::runTestSuite(cest::TestSuite*) cest:664
    #7 0x55ae1c445390 in main cest:1366
    #8 0x7fb10b93fd09 in __libc_start_main ../csu/libc-start.c:308

SUMMARY: AddressSanitizer: 4 byte(s) leaked in 1 allocation(s).
```

Understanding Leak Sanitizer's stack traces takes some time to get used to, but we can see how in the frame #1 (corresponding to the leak.test.cpp file), there is a leak detected in line 3. This line matches with our test, which is not releasing the memory as it should.

<div class="grid cards" style="padding-top: 24px" markdown>
- [:octicons-arrow-left-24: Testing C Code](./bare_c.md)
</div>
