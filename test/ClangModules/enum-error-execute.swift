// RUN: mkdir -p %t
// RUN: %target-clang %S/Inputs/enum-error.m -c -o %t/enum-error.o
// RUN: %target-build-swift -import-objc-header %S/Inputs/enum-error.h -Xlinker %t/enum-error.o %s -o %t/a.out
// RUN: %target-run %t/a.out | FileCheck %s

// REQUIRES: executable_test
// REQUIRES: OS=macosx

import Foundation

func printError(err: TestError) {
  switch (err) {
    case .TENone:
    print("TestError: TENone")
    break

    case .TEOne:
    print("TestError: TEOne")
    break

    case .TETwo:
    print("TestError: TETwo")
    break
  }
}

func testError() {
  let terr = getErr()
  switch (terr) { case .TENone, .TEOne, .TETwo: break } // ok
  printError(terr)
    // CHECK: TestError: TEOne

  do {
    throw TestError.TETwo
  } catch let error as TestError {
    printError(error)
    // CHECK-NEXT: TestError: TETwo
  } catch {
    assert(false)
  }

  do {
    throw NSError(domain: TestErrorDomain,
                  code: Int(TestError.TENone.rawValue),
                  userInfo: nil)
  } catch let error as TestError {
    printError(error)
    // CHECK-NEXT: TestError: TENone
  } catch _ as NSError {
    print("nserror")
  } catch {
    assert(false)
  }

  do {
    enum LocalError : ErrorProtocol { case Err }
    throw LocalError.Err
  } catch let error as TestError {
    printError(error)
  } catch {
    print("other error found")
    // CHECK-NEXT: other error found
  }

}

testError()
