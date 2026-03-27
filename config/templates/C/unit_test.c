// ================================================================================
// ================================================================================
// - File:    unit_test.c
// - Purpose: This file contains the cmocka unit test runner for the prjct_name library
//
// Source Metadata
// - Author:  Name
// - Date:    Month Day, Year
// - Version: 1.0
// - Copyright: Copyright Year, Company Inc.
// ================================================================================
// ================================================================================
// Include modules here

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <setjmp.h>
#include <stdint.h>
#include <cmocka.h>
#include "test_suite.h"

// ================================================================================
// ================================================================================
// TEST SUITE REGISTRY

typedef struct {
    const char *name;
    const struct CMUnitTest *tests;
    size_t count;
} TestSuite;

// ================================================================================
// ================================================================================
// MAIN TEST RUNNER

int main(void)
{
    const TestSuite suites[] = {
        {"Example Suite", test_example, test_example_count},
    };

    const size_t num_suites = sizeof(suites) / sizeof(suites[0]);
    int total_failed = 0;

    printf("\n========================================\n");
    printf("  prjct_name Test Suite\n");
    printf("========================================\n");

    for (size_t i = 0; i < num_suites; i++) {
        printf("\n>>> Running: %s\n", suites[i].name);

        int result = _cmocka_run_group_tests(
            suites[i].name,
            suites[i].tests,
            suites[i].count,
            NULL,
            NULL
        );

        if (result != 0) {
            total_failed++;
            printf("FAILED: %s\n", suites[i].name);
        }
    }

    printf("\n========================================\n");
    printf("  Test Summary\n");
    printf("========================================\n");
    printf("Total suites run:    %zu\n", num_suites);
    printf("Suites passed:       %zu\n", num_suites - total_failed);
    printf("Suites failed:       %d\n", total_failed);
    printf("========================================\n\n");

    return (total_failed > 0) ? 1 : 0;
}

// ================================================================================
// ================================================================================
// eof
