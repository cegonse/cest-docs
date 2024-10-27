# API Reference

## Test definition

### Building blocks

Test suites are defined by the `describe` block. Each `describe` block takes one lambda function as the main test body, and can have many `it` blocks. All the `it` blocks will be executed when running the test.

!!! warning
    Due to how `describe` blocks are built in compilation-time, Cest does not support having multiple `describe` blocks in a single file, be it independently or nested.

Execution can be controlled using the `xit` and `fit` keywords:

- `xit` will skip the test.
- `fit` will execute only that specific test.

This can be useful if you want to avoid running a test that is not yet ready, or you want to focus in fixing a single test.

!!! note "Basic test definition"
    ```cpp
    describe("each test suite", []() {
      it("may contain", []() {});

      it("multiple test cases", []() {});

      fit("only this test will run", []() {});

      xit("this test will be skipped", []() {});
    });
    ```

### Pre-conditions and post-conditions

Execution of test cases and suites can be wrapped to control setup and teardown using the `beforeEach`, `afterEach`, `beforeAll` and `afterAll` keywords. Order of execution of the setup and teardown keywords is `beforeAll` → `beforeEach` → test case → `afterEach` → `afterAll`.

!!! warning
    Even though having multiple pre-condition or post-condition keywords in a single test suite will compile, the actual functions that will be used by Cest is not guaranteed in that case. To avoid problems, each test suite must contain **only** one of each.

Using setup and teardown keywords is the best way to gracefully control post and pre-conditions in your test suites and cases.

!!! note "Wrapping each test case"
    ```cpp
    int *data = nullptr;

    describe("Behavior of pre and post conditions", []() {
      beforeEach([]() {
        data = new int;
        *data = 0;
      });

      afterEach([]() {
        delete data;
      });

      it("has no memory leaks", []() {
        expect(*data).toEqual(0);
      });
    });
    ```

!!! note "Wrapping each test suite"
    ```cpp
    DatabaseConnection connection;

    describe("Behavior of pre and post conditions", []() {
      beforeAll([]() {
        connection.connectTo("localhost");
      });

      afterAll([]() {
        connection.close();
      });

      it("can perform queries", []() {
        expect(connection.getById("")).toBeNull();
      });
    });
    ```

## Assertions

Cest uses matchers to assert values in tests. Assertion keywords are generated through templates, ranging from common assertions to specialization to specific types (like strings, lists, etc...).

An assertion failing to validate its value will stop the test, showing the error through the output. Remaining tests will continue to run.

The basic form of any assertion is:

```cpp
expect<T>(value).[assertion](...);
```

Where assertion can be comparing it to another value, validating its NULL, validating its empty... For example:

```cpp
expect("hello").toEqual("bye"); // This will fail, as hello does not match bye
expect(0x00000000).toBeNull(); // This will pass, as NULL equals zero
```

!!! warning
    Since assertions are generated through templates, asserted type `T` must implement specific operators to match them to the target value. Basic (built-in) types implement them, but if using custom types (like classes or structures), the operators will have to be manually overloaded.

### Generic types

These assertions apply to a `value` of any type `T`, including the ones Cest has a specialization for (see next sections).

| Method                         | Description                                                                | Equivalient operator |
| ------------------------------ | -------------------------------------------------------------------------- | ---------------------- |
| `toBe<T>(T expected)`          | Passes if `value` matches `expected`, evaluated through expression `(value == expected)` | `operator==` |
| `toEqual<T>(T expected)`       | An alias to `toBe`, kept for styling purposes. Both are interchangeable | `operator==` |
| `toBeTruthy()`                  | Passes if `value` equals true, evaluated through expression `(value)` | `operator==` |
| `toBeFalsy()`                  | Passes if `value` equals false, evaluated through expression `(!value)` | `operator==` |

### Floating point types

These assertions apply to a `value` of any type `T` inheriting from `float` or `double`. All assertions which apply to any type `T` also apply to this type.

| Method                              | Description                                                                |
| ----------------------------------- | -------------------------------------------------------------------------- |
| `toBe<T>(T expected, T epsilon)`    | Passes if the absolute distance between `value` and `expected` is less than the specified epsilon (ε), evaluated through expression `fabs(actual - expected) > epsilon`. Default epsilon (ε) is ε=10⁻⁴ for 32 bit float values, and ε=10⁻⁶ for 64 bit float values |
| `toEqual<T>(T expected, T epsilon)` | An alias to `toBe`, kept for styling purposes. Both are interchangeable |

### Strings

These assertions apply to a `value` of any type based on `std::string`. All assertions which apply to any type `T` also apply to this type.

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toMatch(std::string expected)` | Passes if string `value` contains substring `expected` |
| `toMatch(Regex(x))` | Passes if string `value` matches with regular expression defined in Regex macro. See example below. |
| `toHaveLength(size_t length)` | Passes if string `value` lexicographical length equals `length` |

#### Using regular expressions for string matchers

Regular expression matchers accept any regular expression accepted by `std::regex`. The following examples are valid regular expression assertions:

```cpp
it("asserts regexs matches", []() {
  expect("Hello world cest").toMatch(Regex("^Hell.*cest$"));
  expect("I have 12 apples").toMatch(Regex(".*\\d+ apples"));
  expect("To match a partial match").toMatch(Regex("\\w match$"));
});
```

### Collections

Cest supports creating assertions for standard library collections. In the current version, `vector` is supported.

#### `std::vector`

These assertions apply to a vector `value` of any type based on `std::vector<T>`. All assertions which apply to any type `T` also apply to this type.

!!! warning
    To be able to perform assertions on objects of type `std::vector<T>`, template type `T` must support comparation through the operator `operator==`.

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toEqual(std::vector<T> expected)` | Passes if vector `value` contains the same number of items as `expected`, and all items contained in both vectors are equal and are at the same position |
| `toContain(T item)` | Passes if vector `value` contains an instance of `item` |
| `toHaveLength(size_t length)` | Passes if vector `value` number of items equals `length` |

### Pointers

These assertions apply to a `value` of any pointer type `T*`.

| Method | Description |
| ------------------- | ---------- |
| `toEqualMemory(T *expected, size_t length)` | Passes if `value` matches byte by byte compared wit `expected`, from address `expected` until `expected + length` |
| `toBeNull()` | Passes if `value` equals address `0x0` |
| `toBeNotNull()` | Passes if `value` does not equal address `0x0` |

### Exceptions

Cest supports asserting whether the result of an arbitrary expression raises a C++ exception based on type `std::exception`. The interface must be executed inside an `it` block, and accepts a lambda function (the asserted expression).

See the following example:

```cpp
void readFile(std::string path) {
  if (path == "") {
    throw std::exception("Bad path!");
  }
}

describe("File reader", []() {
  it("fails to read files with empty path", []() {
    std::string path = "";

    assertThrows<std::exception>([=]() {
      readFile(path);
    });
  });
});
```

### Adding custom assertions

To add custom assertions, the following methods must be implemented as template specializations of the built-in `expectFunction` and `Assertion` classes. You can find a full example in the [GitHub repository](https://github.com/cegonse/cest/blob/master/test/examples/test_custom_assertions.cpp), or follow this structure to get quick-started:

```cpp
#include <cest>

template<>
class Assertion<MyType> {
public:
  Assertion(const char *file, int line, MyType value) {
    actual = value;
    assertion_file = std::string(file);
    assertion_line = line;
  }

  toBeWhatever(MyType other) {
    if (other.foo() != actual.bar()) {
      throw AssertionError(assertion_file, assertion_line, "The failure message")
    }
  }

private:
  MyType actual;
  std::string assertion_file;
  int assertion_line;
};

template<>
Assertion<MyType> expectFunction(const char *file, int line, MyType actual) {
  return Assertion<MyType>(file, line, actual);
}

describe("Custom assertions", []() {
  it("overrides for MyType", []() {
    MyType a, b;
    expect(a).toBeWhatever(b);
  });
});
```

## Parametrized tests

Cest supports parametrizing test execution. Given a defined set of values, a parametrized test will run once for each of the values in the set. The value is passed to the test as a function argument.

This pattern is useful when building tests where the same behaviour has to be validated against a defined set of data (for example, when working with enumerated values or ranged sets).

See the following example to see how to define a parametrized test, which validates summing two integers and validating its result:

```cpp
struct OperandsAndResult {
  int first;
  int second;
  int result;
}

describe("Calculator", []() {
  it("can add numbers", []() {
    withParameter<OperandsAndResult>()
      .withValue(OperandsAndResult(1, 1, 2))
      .withValue(OperandsAndResult(2, 3, 5))
      .thenDo([](OperandsAndResult x) {
        int sum = x.first + x.second;
        expect(sum).toEqual(x.result);
      });
  });
});
```

## Cest runner CLI parameters

Cest tests are stand-alone executables which have to be compiled and run individually. Execution behavior can be modified through command line options.

| Option | Description |
| ------ | ----------- |
| `-r`/`--randomize` | Randomize test execution inside a single suite. Randomization uses `std::default_random_engine` |
| `-s [seed]`/`--seed [seed]` | Inject seed for randomization (should be an unsigned integer value) |
| `-o` / `--only-suite-result` | Only output the result of the whole test suite as a single line |
| `-t` / `--tree-suite-result` | Output the result of the test suite in tree format, with indents for each nested suite |

## Signal behavior

The Cest runner captures the following POSIX signals upon startup: `SIGSEGV`, `SIGFPE`, `SIGBUS`, `SIGILL`, `SIGTERM`, `SIGXCPU` and `SIGXFSZ`. Test are marked as failed if any of them raises during its execution. The POSIX function `signal()` is used for this purpose. Take this into account when testing code that captures signals, as both could interfer.
