# Copyright 2019 The Bazel Authors. All rights reserved.
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

"""macos_dynamic_framework Starlark tests."""

load(
    ":common.bzl",
    "common",
)
load(
    ":rules/analysis_failure_message_test.bzl",
    "analysis_failure_message_test",
)
load(
    ":rules/common_verification_tests.bzl",
    "archive_contents_test",
)
load(
    ":rules/infoplist_contents_test.bzl",
    "infoplist_contents_test",
)

def macos_dynamic_framework_test_suite(name):
    """Test suite for macos_dynamic_framework.

    Args:
      name: the base name to be used in things created by this macro
    """

    archive_contents_test(
        name = "{}_archive_contents_test".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework",
        binary_test_file = "$BUNDLE_ROOT/BasicFramework",
        macho_load_commands_contain = ["name @rpath/BasicFramework.framework/BasicFramework (offset 24)"],
        contains = [
            "$BUNDLE_ROOT/BasicFramework",
            "$BUNDLE_ROOT/Headers/BasicFramework.h",
            "$BUNDLE_ROOT/Info.plist",
            "$BUNDLE_ROOT/Modules/module.modulemap",
            "$BUNDLE_ROOT/Modules/BasicFramework.swiftmodule/x86_64.swiftdoc",
            "$BUNDLE_ROOT/Modules/BasicFramework.swiftmodule/x86_64.swiftmodule",
        ],
        tags = [name],
    )

    infoplist_contents_test(
        name = "{}_plist_test".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework",
        expected_values = {
            "BuildMachineOSBuild": "*",
            "CFBundleExecutable": "BasicFramework",
            "CFBundleIdentifier": "com.google.example.framework",
            "CFBundleName": "BasicFramework",
            "CFBundlePackageType": "FMWK",
            "CFBundleSupportedPlatforms:0": "MacOSX",
            "DTCompiler": "com.apple.compilers.llvm.clang.1_0",
            "DTPlatformBuild": "*",
            "DTPlatformName": "macosx",
            "DTPlatformVersion": "*",
            "DTSDKBuild": "*",
            "DTSDKName": "macosx*",
            "DTXcode": "*",
            "DTXcodeBuild": "*",
            "LSMinimumSystemVersion": common.min_os_macos.baseline,
        },
        tags = [name],
    )

    archive_contents_test(
        name = "{}_direct_dependency_archive_contents_test".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_direct_dependency",
        binary_test_file = "$BUNDLE_ROOT/DirectDependencyTest",
        macho_load_commands_contain = ["name @rpath/DirectDependencyTest.framework/DirectDependencyTest (offset 24)"],
        contains = [
            "$BUNDLE_ROOT/DirectDependencyTest",
            "$BUNDLE_ROOT/Headers/DirectDependencyTest.h",
            "$BUNDLE_ROOT/Info.plist",
            "$BUNDLE_ROOT/Modules/module.modulemap",
            "$BUNDLE_ROOT/Modules/DirectDependencyTest.swiftmodule/x86_64.swiftdoc",
            "$BUNDLE_ROOT/Modules/DirectDependencyTest.swiftmodule/x86_64.swiftmodule",
        ],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_transitive_dependency_archive_contents_test".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_transitive_dependency",
        binary_test_file = "$BUNDLE_ROOT/TransitiveDependencyTest",
        macho_load_commands_contain = ["name @rpath/TransitiveDependencyTest.framework/TransitiveDependencyTest (offset 24)"],
        contains = [
            "$BUNDLE_ROOT/TransitiveDependencyTest",
            "$BUNDLE_ROOT/Headers/TransitiveDependencyTest.h",
            "$BUNDLE_ROOT/Info.plist",
            "$BUNDLE_ROOT/Modules/module.modulemap",
            "$BUNDLE_ROOT/Modules/TransitiveDependencyTest.swiftmodule/x86_64.swiftdoc",
            "$BUNDLE_ROOT/Modules/TransitiveDependencyTest.swiftmodule/x86_64.swiftmodule",
        ],
        tags = [name],
    )

    # Tests that libraries that both apps and frameworks depend only have symbols
    # present in the framework.
    archive_contents_test(
        name = "{}_symbols_from_shared_library_in_framework".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app_with_dynamic_framework_and_resources",
        binary_test_architecture = "x86_64",
        binary_test_file = "$CONTENT_ROOT/Frameworks/swift_lib_with_macos_resources.framework/swift_lib_with_macos_resources",
        binary_contains_symbols = ["_$s30swift_lib_with_macos_resources16dontCallMeSharedyyF"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_symbols_from_shared_library_not_in_application".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app_with_dynamic_framework_and_resources",
        binary_test_file = "$CONTENT_ROOT/MacOS/app_with_dynamic_framework_and_resources",
        binary_test_architecture = "x86_64",
        binary_not_contains_symbols = ["_$s30swift_lib_with_macos_resources16dontCallMeSharedyyF"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_symbols_from_shared_library_not_in_framework_with_dynamic_framework_dependency".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_dynamic_framework_dependency",
        binary_test_file = "$BUNDLE_ROOT/DirectDependencyWithDynamicFrameworkTest",
        binary_test_architecture = "x86_64",
        binary_contains_symbols = ["_$s40DirectDependencyWithDynamicFrameworkTestMXM"],
        binary_not_contains_symbols = ["_$s14BasicFrameworkAAC10HelloWorldyyF"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_symbols_from_shared_library_not_in_framework_with_transitive_dependencies_and_dynamic_framework_dependencies".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_transitive_dependency_with_dynamic_frameworks",
        binary_test_file = "$BUNDLE_ROOT/TransitiveDependencyWithDynamicFrameworksTest",
        binary_test_architecture = "x86_64",
        binary_contains_symbols = ["_$s45TransitiveDependencyWithDynamicFrameworksTestMXM"],
        binary_not_contains_symbols = ["_$s14BasicFrameworkAAC10HelloWorldyyF", "_$s40DirectDependencyWithDynamicFrameworkTestMXM"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_app_includes_transitive_framework_test".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app_with_dynamic_framework_with_dynamic_framework",
        binary_test_file = "$CONTENT_ROOT/Frameworks/swift_transitive_lib.framework/swift_transitive_lib",
        binary_test_architecture = "x86_64",
        contains = [
            "$CONTENT_ROOT/Frameworks/swift_transitive_lib.framework/swift_transitive_lib",
            "$CONTENT_ROOT/Frameworks/swift_transitive_lib.framework/Info.plist",
            "$CONTENT_ROOT/Frameworks/swift_shared_lib.framework/swift_shared_lib",
            "$CONTENT_ROOT/Frameworks/swift_shared_lib.framework/Info.plist",
        ],
        not_contains = [
            "$CONTENT_ROOT/Frameworks/swift_transitive_lib.framework/Frameworks/",
            "$CONTENT_ROOT/Frameworks/swift_transitive_lib.framework/nonlocalized.plist",
            "$CONTENT_ROOT/framework_resources/nonlocalized.plist",
        ],
        binary_contains_symbols = ["_$s20swift_transitive_lib21anotherFunctionSharedyyF"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_app_includes_transitive_framework_symbols_not_in_app".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:app_with_dynamic_framework_with_dynamic_framework",
        binary_test_file = "$CONTENT_ROOT/MacOS/app_with_dynamic_framework_with_dynamic_framework",
        binary_test_architecture = "x86_64",
        binary_not_contains_symbols = ["_$s20swift_transitive_lib21anotherFunctionSharedyyF"],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_apple_dynamic_framework_import_in_framework_compiles".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_dynamic_framework_import",
        binary_test_file = "$BUNDLE_ROOT/DynamicFrameworkImportTest",
        macho_load_commands_contain = ["name @rpath/DynamicFrameworkImportTest.framework/DynamicFrameworkImportTest (offset 24)"],
        contains = [
            "$BUNDLE_ROOT/DynamicFrameworkImportTest",
            "$BUNDLE_ROOT/Headers/DynamicFrameworkImportTest.h",
            "$BUNDLE_ROOT/Info.plist",
            "$BUNDLE_ROOT/Modules/module.modulemap",
            "$BUNDLE_ROOT/Modules/DynamicFrameworkImportTest.swiftmodule/x86_64.swiftdoc",
            "$BUNDLE_ROOT/Modules/DynamicFrameworkImportTest.swiftmodule/x86_64.swiftmodule",
        ],
        tags = [name],
    )

    archive_contents_test(
        name = "{}_apple_static_framework_import_in_framework_compiles".format(name),
        build_type = "simulator",
        target_under_test = "//test/starlark_tests/targets_under_test/macos:basic_framework_with_static_framework_import",
        binary_test_file = "$BUNDLE_ROOT/StaticFrameworkImportTest",
        macho_load_commands_contain = ["name @rpath/StaticFrameworkImportTest.framework/StaticFrameworkImportTest (offset 24)"],
        contains = [
            "$BUNDLE_ROOT/StaticFrameworkImportTest",
            "$BUNDLE_ROOT/Headers/StaticFrameworkImportTest.h",
            "$BUNDLE_ROOT/Info.plist",
            "$BUNDLE_ROOT/Modules/module.modulemap",
            "$BUNDLE_ROOT/Modules/StaticFrameworkImportTest.swiftmodule/x86_64.swiftdoc",
            "$BUNDLE_ROOT/Modules/StaticFrameworkImportTest.swiftmodule/x86_64.swiftmodule",
        ],
        tags = [name],
    )

    analysis_failure_message_test(
        name = "{}_multiple_deps_in_dynamic_framework_fail".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/macos:dynamic_fmwk_with_multiple_dependencies",
        expected_error = """\
    error: Swift dynamic frameworks expect a single swift_library dependency.
    """,
        tags = [name],
    )

    analysis_failure_message_test(
        name = "{}_non_swiftlib_dep_in_dynamic_framework_fail".format(name),
        target_under_test = "//test/starlark_tests/targets_under_test/macos:dynamic_fmwk_with_objc_library",
        expected_error = """\
    error: Swift dynamic frameworks expect a single swift_library dependency.
    """,
        tags = [name],
    )

    native.test_suite(
        name = name,
        tags = [name],
    )
