# API Reference

## Test definition

### Building blocks

Test suites are defined by a top-level `describe` block. Each `describe` block takes one lambda function as the main test body, and can have many `it` blocks. All the `it` blocks will be executed when running the test.

Each `describe` block may have multiple nested `describe` blocks. All `describe` blocks will be executed in outside-inside order, starting from the top-level describe block.

For example, with the following set of `describe` and `it` blocks:

!!! note "Nested test suites"
    ```cpp
    describe("Socket", []() {
      describe("send()", []() {
        it("sends data", []() {});
      });

      describe("recv()", []() {
        it("receives data", []() {});
      });

      it("does nothing", []() {});
    });
    ```

The statements in the top-level `describe` block will be executed first (the `does nothing` test case), and then the `send()` and `recv()` describe blocks will be executed consecutively.

!!! warning
    Due to the way `describe` blocks are arranged in compilation-time, Cest does not support having multiple top-level `describe` blocks in a single test file.

Test case execution can be controlled using the `xit` and `fit` keywords:

- `xit` will skip the test.
- `fit` will execute only that specific test.
- `todo` will mark the test as pending, indicating it is not yet implemented.

Similarly, `xdescribe` and `fdescribe` can be used to skip or focus entire test suites:

- `xdescribe` will skip all tests in the suite.
- `fdescribe` will execute only the tests in that suite.

This can be useful if you want to avoid running a test that is not yet ready, or you want to focus in fixing a single test or suite.

!!! note "Basic test definition"
    ```cpp
    describe("each test suite", []() {
      it("may contain", []() {});

      it("multiple test cases", []() {});

      fit("only this test will run", []() {});

      xit("this test will be skipped", []() {});

      todo("this test is not yet implemented");
    });
    ```

!!! note "Skipping and focusing suites"
    ```cpp
    xdescribe("this entire suite is skipped", []() {
      it("will not run", []() {});
    });

    fdescribe("only this suite will run", []() {
      it("will run", []() {});
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

    describe("Behavior of pre and post conditions", [&]() { // (1)
      beforeEach([&]() { // (1)
        data = new int;
        *data = 0;
      });

      afterEach([&]() { // (1)
        delete data;
      });

      it("has no memory leaks", [&]() { // (1)
        expect(*data).toEqual(0);
      });
    });
    ```

    1. Note how the lambda expression is defined with reference capture scope (`&`), as the test is accesing the `data` variable which is defined at the top level.


!!! note "Wrapping each test suite"
    ```cpp
    DatabaseConnection connection;

    describe("Behavior of pre and post conditions", [&]() { // (1)
      beforeAll([&]() { // (1)
        connection.connectTo("localhost");
      });

      afterAll([&]() { // (1)
        connection.close();
      });

      it("can perform queries", [&]() { // (1)
        expect(connection.getById("")).toBeNull();
      });
    });
    ```

    1. Note how the lambda expression is defined with reference capture scope (`&`), as the test is accesing the `data` variable which is defined at the top level.

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

To assert negated values, you can use the `Not` operator. For example:

```cpp
expect("hello").Not->toEqual("bye");
expect(123).Not->toBe(321);
```

### Generic types

These assertions apply to a `value` of any type `T`, including the ones Cest has a specialization for (see next sections).

| Method                         | Description                                                                | Required operator |
| ------------------------------ | -------------------------------------------------------------------------- | ---------------------- |
| `toBe<T>(T expected)`          | Passes if `value` matches `expected`, evaluated through expression `(value == expected)` | `operator==` |
| `toEqual<T>(T expected)`       | An alias to `toBe`, kept for styling purposes. Both are interchangeable | `operator==` |
| `toBeTruthy()`                  | Passes if `value` equals true, evaluated through expression `(value)` | |
| `toBeFalsy()`                  | Passes if `value` equals false, evaluated through expression `(!value)` | |
| `toBeGreaterThan<T>(T expected)` | Passes if `value` is greater than `expected` | `operator>` |
| `toBeLessThan<T>(T expected)` | Passes if `value` is less than `expected` | `operator<` |
| `toBeInRange<T>(T min, T max)` | Passes if `value` is within the inclusive range [`min`, `max`] | `operator>=`, `operator<=` |
| `toEqualBytes<T>(T expected)` | Passes if `value` matches `expected` byte-by-byte using `memcmp`. Useful for C structs without `operator==` | Trivially copyable |
| `toHaveBitsSet<T>(T mask)` | Passes if all bits in `mask` are set in `value`, evaluated through `(value & mask) == mask` | Integral type |
| `toHaveBitsClear<T>(T mask)` | Passes if all bits in `mask` are clear in `value`, evaluated through `(value & mask) == 0` | Integral type |

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
| `toBe<T>(T expected)`          | Passes if `value` matches `expected`, evaluated through expression `(value == expected)` | `operator==` |
| `toEqual<T>(T expected)`       | An alias to `toBe`, kept for styling purposes. Both are interchangeable | `operator==` |
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

Cest supports creating assertions for standard library collections and containers.

!!! warning
    To be able to perform assertions on collection elements, template type `T` must support comparison through the operator `operator==`.

#### `std::vector`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::vector<T> expected)` | Passes if vector `value` contains the same number of items as `expected`, and all items are equal and at the same position |
| `toEqual(std::vector<T> expected)` | An alias to `toBe` |
| `toContain(T item)` | Passes if vector `value` contains an instance of `item` |
| `toHaveLength(size_t length)` | Passes if vector `value` number of items equals `length` |

#### `std::array`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::array<T, N> expected)` | Passes if array `value` matches `expected` element-by-element |
| `toEqual(std::array<T, N> expected)` | An alias to `toBe` |
| `toContain(T item)` | Passes if array `value` contains an instance of `item` |
| `toHaveLength(size_t length)` | Passes if array `value` size equals `length` |

#### C-style arrays

Cest supports assertions on C-style arrays without pointer decay.

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(const T (&expected)[N])` | Passes if array `value` matches `expected` element-by-element |
| `toEqual(const T (&expected)[N])` | An alias to `toBe` |
| `toContain(T item)` | Passes if array `value` contains an instance of `item` |
| `toHaveLength(size_t length)` | Passes if array `value` size equals `length` |

#### `std::list`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::list<T> expected)` | Passes if list `value` matches `expected` element-by-element |
| `toEqual(std::list<T> expected)` | An alias to `toBe` |
| `toContain(T item)` | Passes if list `value` contains an instance of `item` |
| `toHaveSize(size_t size)` | Passes if list `value` number of items equals `size` |

#### `std::forward_list`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::forward_list<T> expected)` | Passes if list `value` matches `expected` element-by-element |
| `toEqual(std::forward_list<T> expected)` | An alias to `toBe` |
| `toContain(T item)` | Passes if list `value` contains an instance of `item` |
| `toHaveSize(size_t size)` | Passes if list `value` number of items equals `size` |

#### `std::deque`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::deque<T> expected)` | Passes if deque `value` matches `expected` element-by-element |
| `toEqual(std::deque<T> expected)` | An alias to `toBe` |
| `toContain(T item)` | Passes if deque `value` contains an instance of `item` |
| `toHaveLength(size_t length)` | Passes if deque `value` number of items equals `length` |

#### `std::set` / `std::unordered_set`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::set<T> expected)` | Passes if set `value` matches `expected` |
| `toEqual(std::set<T> expected)` | An alias to `toBe` |
| `toInclude(T item)` | Passes if set `value` contains `item` |
| `toHaveSize(size_t size)` | Passes if set `value` number of items equals `size` |

The same assertions are available for `std::unordered_set<T>`.

#### `std::multiset` / `std::unordered_multiset`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::multiset<T> expected)` | Passes if multiset `value` matches `expected` |
| `toEqual(std::multiset<T> expected)` | An alias to `toBe` |
| `toInclude(T item)` | Passes if multiset `value` contains `item` |
| `toHaveSize(size_t size)` | Passes if multiset `value` number of items equals `size` |

The same assertions are available for `std::unordered_multiset<T>`.

#### `std::map` / `std::unordered_map`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::map<K, V> expected)` | Passes if map `value` matches `expected` |
| `toEqual(std::map<K, V> expected)` | An alias to `toBe` |
| `toInclude(std::pair<K, V> entry)` | Passes if map `value` contains the given key-value pair |
| `toHaveKey(K key)` | Passes if map `value` contains the given key |
| `toHaveSize(size_t size)` | Passes if map `value` number of entries equals `size` |

The same assertions are available for `std::unordered_map<K, V>`.

#### `std::multimap` / `std::unordered_multimap`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::multimap<K, V> expected)` | Passes if multimap `value` matches `expected` |
| `toEqual(std::multimap<K, V> expected)` | An alias to `toBe` |
| `toInclude(std::pair<K, V> entry)` | Passes if multimap `value` contains the given key-value pair |
| `toHaveKey(K key)` | Passes if multimap `value` contains the given key |
| `toHaveSize(size_t size)` | Passes if multimap `value` number of entries equals `size` |

The same assertions are available for `std::unordered_multimap<K, V>`.

#### `std::pair`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::pair<T, U> expected)` | Passes if pair `value` matches `expected`. Reports whether `first` or `second` differs |
| `toEqual(std::pair<T, U> expected)` | An alias to `toBe` |

#### `std::tuple`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::tuple<Ts...> expected)` | Passes if tuple `value` matches `expected`. Reports the position of the first mismatch |
| `toEqual(std::tuple<Ts...> expected)` | An alias to `toBe` |

#### `std::optional`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::optional<T> expected)` | Passes if optional `value` matches `expected` |
| `toEqual(std::optional<T> expected)` | An alias to `toBe` |
| `toHaveValue()` | Passes if optional `value` contains a value |
| `toHaveValue(T expected)` | Passes if optional `value` contains a value equal to `expected` |
| `toBeEmpty()` | Passes if optional `value` is `std::nullopt` |

#### `std::bitset`

| Method                         | Description                                                                |
| ------------------------------ | -------------------------------------------------------------------------- |
| `toBe(std::bitset<N> expected)` | Passes if bitset `value` matches `expected` |
| `toEqual(std::bitset<N> expected)` | An alias to `toBe` |
| `toHaveBitSet(size_t pos)` | Passes if bit at position `pos` is set |
| `toHaveCount(size_t n)` | Passes if bitset `value` has exactly `n` bits set |
| `toHaveAll()` | Passes if all bits are set |
| `toHaveNone()` | Passes if no bits are set |

### Pointers

These assertions apply to a `value` of any pointer type `T*`.

| Method | Description |
| ------------------- | ---------- |
| `toEqualMemory(T *expected, size_t length)` | Passes if `value` matches byte by byte compared with `expected`, from address `expected` until `expected + length` |
| `toBeNull()` | Passes if `value` equals address `0x0` |
| `toBeNotNull()` | Passes if `value` does not equal address `0x0` |

### Smart pointers

#### `std::shared_ptr`

| Method | Description |
| ------------------- | ---------- |
| `toBeNull()` | Passes if the shared pointer is null |
| `toBeNotNull()` | Passes if the shared pointer is not null |
| `toPointTo(T expected)` | Passes if the pointed-to value equals `expected` |
| `toHaveUseCount(long expected)` | Passes if the reference count equals `expected` |

#### `std::unique_ptr`

| Method | Description |
| ------------------- | ---------- |
| `toBeNull()` | Passes if the unique pointer is null |
| `toBeNotNull()` | Passes if the unique pointer is not null |
| `toPointTo(T expected)` | Passes if the pointed-to value equals `expected` |

### `std::complex`

These assertions apply to a `value` of type `std::complex<T>`.

| Method | Description |
| ------------------- | ---------- |
| `toBe(std::complex<T> expected, T epsilon)` | Passes if both real and imaginary parts match within epsilon tolerance |
| `toEqual(std::complex<T> expected, T epsilon)` | An alias to `toBe` |
| `toHaveReal(T expected, T epsilon)` | Passes if the real part matches `expected` within epsilon tolerance |
| `toHaveImaginary(T expected, T epsilon)` | Passes if the imaginary part matches `expected` within epsilon tolerance |

### `std::chrono::duration`

These assertions apply to a `value` of type `std::chrono::duration`.

| Method | Description |
| ------------------- | ---------- |
| `toBe(duration expected)` | Passes if duration `value` equals `expected` |
| `toEqual(duration expected)` | An alias to `toBe` |
| `toBeGreaterThan(duration expected)` | Passes if duration `value` is greater than `expected` |
| `toBeLessThan(duration expected)` | Passes if duration `value` is less than `expected` |
| `toBeCloseTo(duration expected, duration tolerance)` | Passes if duration `value` falls within `tolerance` of `expected` |

### `std::filesystem::path`

These assertions apply to a `value` of type `std::filesystem::path`.

| Method | Description |
| ------------------- | ---------- |
| `toBe(std::filesystem::path expected)` | Passes if path `value` matches `expected` |
| `toEqual(std::filesystem::path expected)` | An alias to `toBe` |
| `toHaveExtension(std::string ext)` | Passes if the file extension matches `ext` |
| `toHaveFilename(std::string name)` | Passes if the filename component matches `name` |
| `toBeAbsolute()` | Passes if the path is absolute |
| `toBeRelative()` | Passes if the path is relative |

### Exceptions

Cest supports asserting whether the result of an arbitrary expression raises a C++ exception. There are two ways to test exceptions: callable assertions and `assertThrows`.

#### Callable assertions

Pass a lambda to `expect` to use callable assertions:

```cpp
void readFile(std::string path) {
  if (path == "") {
    throw std::runtime_error("Bad path!");
  }
}

describe("File reader", []() {
  it("fails to read files with empty path", []() {
    expect([]() { readFile(""); }).toThrow();
  });

  it("throws the right exception type", []() {
    expect([]() { readFile(""); }).toThrow<std::runtime_error>();
  });

  it("throws with the right message", []() {
    expect([]() { readFile(""); }).toThrowMessage("Bad path!");
  });

  it("does not throw with a valid path", []() {
    expect([]() { readFile("/tmp/file"); }).Not->toThrow();
  });
});
```

| Method | Description |
| ------------------- | ---------- |
| `toThrow()` | Passes if the callable throws any exception |
| `toThrow<E>()` | Passes if the callable throws an exception of type `E` |
| `toThrowMessage(std::string message)` | Passes if the callable throws an exception whose `what()` matches `message` |

#### `assertThrows`

The legacy interface for exception assertions:

```cpp
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
  Assertion(const char *file, int line, MyType value, bool negated = false)
    : negated(false) {
    actual = value;
    assertion_file = std::string(file);
    assertion_line = line;

    if (!negated) {
      this->Not = new Assertion<MyType>(file, line, value, true);
    } else {
      this->Not = nullptr;
      this->negated = true;
    }
  }

  ~Assertion() {
    if (this->Not) delete this->Not;
  }

  void toBeWhatever(MyType other) {
    if ((other.foo() != actual.bar()) ^ negated) {
      throw AssertionError(assertion_file, assertion_line, "The failure message");
    }
  }

  Assertion<MyType> *Not;

private:
  bool negated;
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
    expect(a).Not->toBeWhatever(b);
  });
});
```

!!! note
    Custom assertions no longer require `T` to implement `operator<<` for `std::ostream`. Non-printable types will display as `<non-printable>` in error messages.

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

## Cest test runner CLI parameters

Cest tests are stand-alone executables which have to be compiled and run individually. Execution behavior can be modified through command line options.

| Option | Description |
| ------ | ----------- |
| `-h`/`--help` | Display help information |
| `-r`/`--randomize` | Randomize test execution inside a single suite. Randomization uses `std::default_random_engine` |
| `-s [seed]`/`--seed [seed]` | Inject seed for randomization (should be an unsigned integer value) |
| `-g [pattern]`/`--grep [pattern]` | Filter test cases by name pattern |
| `-o` / `--only-suite-result` | Only output the result of the whole test suite as a single line |
| `-t` / `--tree-suite-result` | Output the result of the test suite in tree format, with indents for each nested suite |
| `-j` / `--json` | Output test results in JSON format |
| `-l` / `--print-test-list` | List all available test cases without running them |

## Cest Runner CLI parameters

Cest runner can be used to launch and operate Cest tests in a simple way. Execution behavior can be modified through command line options.

| Option |  Description |
| ------ | ------------ |
| `[directory]` | Target directory to look for tests to run. Defaults to `$CWD` |
| `--watch` | Run in watch mode. An interactive UI is available to filter which tests should run. |
| `--grep [pattern]` | Only run test files/cases whose name contains `pattern` |

## Signal behavior

The Cest test runner captures signals upon startup and marks tests as failed if any of them are raised during execution. Take this into account when testing code that captures signals, as both could interfere.

On **Linux and macOS**, the following POSIX signals are captured: `SIGSEGV`, `SIGFPE`, `SIGBUS`, `SIGILL`, `SIGTERM`, `SIGXCPU` and `SIGXFSZ`.

On **Win32** (MinGW), a reduced set of signals is captured: `SIGSEGV`, `SIGFPE`, `SIGILL` and `SIGTERM`. The `SIGBUS`, `SIGXCPU` and `SIGXFSZ` signals are not available on Windows.

## Leak Sanitizer integration

The Cest test runner detects whether the test program is being compiled with LSAN enabled by testing against the `__SANITIZE_ADDRESS__` define, which will be defined in all translation units by the compiler if LSAN is enabled. If LSAN is not enabled or not supported, LSAN integration is disabled.
