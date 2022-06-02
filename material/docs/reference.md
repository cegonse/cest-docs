# API Reference

## Test definition

### Building blocks

Test suites are defined by the `describe` block. Each `describe` block takes one lambda function as the main test body, and can have many `it` blocks. All the `it` blocks will be executed when running the test.

!!! warning
    Due to how `describe` blocks are built in compilation-time, Cest does not support having multiple `describe` blocks in a single file, be it independently or nested.

Execution can be controlled using the `xit` and `fit` keywords. `xit` will skip the test, while `fit` will execute only that specific test. This can be useful if you want to avoid running a test that is not yet ready, or you want to focus in fixing a single test.

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

These assertions apply to any type `T` which is not included in the following sections.

| Method                         | Description                                                                | Comparation operator |
| ------------------------------ | -------------------------------------------------------------------------- | ---------------------- |
| `toBe<T>(T expected)`          | Passes if `value` matches `expected`, evaluated through expression `(value == expected)` | `operator==` |
| `toEqual<T>(T expected)`       | An alias to `toBe`, kept for styling purposes. Both are interchangeable | `operator==` |
| `toBeTruthy()`                  | Passes if `value` equals true, evaluated through expression `(value)` | `operator==` |
| `toBeFalsy()`                  | Passes if `value` equals false, evaluated through expression `(!value)` | `operator==` |

### Strings

### Collections

### Pointers

### Exceptions

## Parametrized tests

## Extending the assertions

## Cest runner CLI parameters

## Signal behavior
