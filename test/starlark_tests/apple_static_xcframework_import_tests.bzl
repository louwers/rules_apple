# Copyright 2022 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""apple_static_xcframework_import Starlark tests."""

load(":rules/analysis_failure_message_test.bzl", "analysis_failure_message_test")
load(":rules/common_verification_tests.bzl", "archive_contents_test")

def apple_static_xcframework_import_test_suite(name):
    """Test suite for apple_static_xcframework_import.

    Args:
      name: the base name to be used in things created by this macro
    """

    # Verify importing XCFramework with static frameworks (i.e. not libraries) fails.
    analysis_failure_message_test(
        name = "{}_fails_importing_xcframework_with_static_framework_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/apple:ios_imported_xcframework_with_static_frameworks",
        expected_error = "Importing XCFrameworks with static frameworks is not supported.",
        tags = [name],
    )

    # Verify ios_application with XCFramework with static library dependency contains symbols and
    # does not bundle anything under Frameworks/
    archive_contents_test(
        name = "{}_ios_application_with_imported_static_xcframework_includes_symbols".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_with_imported_xcframework_with_static_library",
        binary_test_file = "$BINARY",
        binary_test_architecture = "x86_64",
        binary_contains_symbols = [
            "-[SharedClass doSomethingShared]",
            "_OBJC_CLASS_$_SharedClass",
        ],
        not_contains = ["$BUNDLE_ROOT/Frameworks/"],
        tags = [name],
    )

    # Verify ios_application with an imported XCFramework that has a Swift static library
    # contains symbols visible to Objective-C, and bundles Swift standard libraries.
    archive_contents_test(
        name = "{}_swift_with_imported_static_fmwk_contains_symbols_and_bundles_swift_std_libraries".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_with_imported_swift_xcframework_with_static_library",
        binary_test_file = "$BINARY",
        binary_test_architecture = "x86_64",
        binary_contains_symbols = [
            "_OBJC_CLASS_$__TtC34generated_swift_static_xcframework11SharedClass",
        ],
        contains = ["$BUNDLE_ROOT/Frameworks/libswiftCore.dylib"],
        tags = [name],
    )

    # Verify Swift standard libraries are bundled for an imported XCFramework that has a Swift
    # static library containing no module interface files (.swiftmodule directory) and where the
    # import rule sets `has_swift` = True.
    archive_contents_test(
        name = "{}_swift_with_no_module_interface_files_and_has_swift_attr_enabled_bundles_swift_std_libraries".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/ios:app_with_imported_swift_xcframework_with_static_library_without_swiftmodule",
        binary_test_file = "$BINARY",
        binary_test_architecture = "x86_64",
        binary_contains_symbols = [
            "_OBJC_CLASS_$__TtC34generated_swift_static_xcframework11SharedClass",
        ],
        contains = ["$BUNDLE_ROOT/Frameworks/libswiftCore.dylib"],
        tags = [name],
    )

    native.test_suite(
        name = name,
        tags = [name],
    )
