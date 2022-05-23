# API Reference

## Test definition

### Building blocks

!!! note "Basic test definition"
    ```cpp
    describe("each test suite", []() {
      it("may contain", []() {});

      it("multiple test cases", []() {});
    });
    ```

### Pre-conditions and post-conditions

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

## Assertions

### Basic types

### Strings

### Collections

### Pointers

### Exceptions

## Parametrized tests

## Extending the assertions

## Cest runner CLI parameters

## Signal behavior
