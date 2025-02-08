# Using Cest Runner

In the previous guide, we went through how to integrate Cest Framework with your application and run tests bare-bones. However, this isn't the easiest way to run Cest test suites.

In this guide, we are going to see how to use the Cest Runner to simplify running test suites and working interactively with your test cases.

## Setup

This guide starts from the last point of the first guide (_Writing your first test_). If you haven't gone through the first guide, its recommended you go through that content first.

After completing the first guide, the directory structure should look like this:

```title="Directory structure"
/calculator
├ /src
│ ├ main.cpp
│ ├ calculator.cpp
│ └ calculator.h
├ /test
│ └ calculator.test.cpp
├ /lib
│ └ cest
└ /build
  ├ calculator_test
  └ calculator
```

First, we'll download the latest version of cest-runner from [GitHub](https://github.com/cegonse/cest/releases/download/v3/cest-runner-x64-linux). Right now, only Linux x64 builds of the Cest Runner are provided in GitHub. If you are running other platform (such as macOS or FreeBSD) or CPU architecture, you will have to build Cest Runner yourself from sources.

Let's create a `bin` directory to place the `cest-runner` binary:

```bash
mkdir -p bin
cd bin && wget https://github.com/cegonse/cest/releases/download/v3/cest-runner-x64-linux
mv cest-runner-x64-linux cest-runner
chmod +x cest-runner
cd ..
```

After downloading the Cest Runner, the directory structure should look like this:

```title="Directory structure"
/calculator
├ /src
│ ├ main.cpp
│ ├ calculator.cpp
│ └ calculator.h
├ /test
│ └ calculator.test.cpp
├ /bin
│ └ cest-runner
├ /lib
│ └ cest
└ /build
  ├ calculator_test
  └ calculator
```

## Running the test suite

Now that Cest runner is installed, we can run all test suites by just executing `cest-runner`. Cest Runner finds all executable test files named `test_*` in the current working directory (or a directory passed as a command line argument), and executes all of them in sequence.

```bash
./bin/cest-runner
  Calculator
    sum()
      ✓ adds two numbers
      ✓ supports negative numbers

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Time:        0.00165 s
Ran all test suites.
```

Let's force our test to fail. To do so, edit the implementation in `calculator.cpp` and change so the `sum()` function always returns zero.

After compiling the test as we saw in the previous guide, and running `cest-runner`, we will see how the failure is detected:

```bash
./bin/cest-runner
  Calculator
    sum()
      ✕ adds two numbers

   Failed at line 8: Expected 4, was 0
   5 |     it("adds two numbers", []() {
   6 |       auto a = 2, b = 2;
   7 |       auto r = Sum(a, b);
 > 8 |       expect(r).toEqual(4); // (3)
   9 |     });
   10 |
   11 |     it("supports negative numbers", []() {

      ✕ supports negative numbers

   Failed at line 14: Expected 2, was 0
   11 |     it("supports negative numbers", []() {
   12 |       auto a = -2, b = 4;
   13 |       auto r = Sum(a, b);
 > 14 |       expect(r).toEqual(2);
   15 |     });
   16 |   });
   17 | });


Test Suites: 1 failed, 1 total
Tests:       2 failed, 2 total
Time:        0.001543 s
Ran all test suites.
```

You can also run `cest-runner` in watch mode, to debug your tests interactively. You can filter by test suite source file name, or run only failed tests. You can do it as following:

```bash
./bin/cest-runner --watch
  Calculator
    sum()
      ✕ adds two numbers

   Failed at line 8: Expected 4, was 0
   5 |     it("adds two numbers", []() {
   6 |       auto a = 2, b = 2;
   7 |       auto r = Sum(a, b);
 > 8 |       expect(r).toEqual(4); // (3)
   9 |     });
   10 |
   11 |     it("supports negative numbers", []() {

      ✕ supports negative numbers

   Failed at line 14: Expected 2, was 0
   11 |     it("supports negative numbers", []() {
   12 |       auto a = -2, b = 4;
   13 |       auto r = Sum(a, b);
 > 14 |       expect(r).toEqual(2);
   15 |     });
   16 |   });
   17 | });

Test Suites: 1 failed, 1 total
Tests:       2 failed, 2 total
Time:        0.001856 s
Ran all test suites.

Watch Usage
 › Press f to run only failed tests.
 › Press p to filter by a filename regex pattern.
 › Press q to quit watch mode.
 › Press Enter to trigger a test run.
```

Follow the on-screen prompts to apply filters as you need. You will get the hang of it very quickly.

## Next reading

After completing this guide, you have seen how to use the Cest Runner to simplify execution of the test suites of your project. In this guide we only had a single test suite, which made it a bit pointless. But as the number of tests in your project grows, you will see the benefits of using Cest Runner quickly.

In the next guide, we will see how to integrate Cest Framework with a complex build system such as CMake.

<div class="grid cards" style="padding-top: 24px" markdown>
- [:octicons-arrow-left-24: Writing your first test](./first.md)
- [Integrating with CMake :octicons-arrow-right-24:](./cmake.md)
</div>
