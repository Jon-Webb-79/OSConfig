// ================================================================================
// ================================================================================
// - File:    filename.cpp
// - Purpose: This file implements google test as a method to test C++ code.
//            Describe the type of testing to be completed
//
// Source Metadata
// - Author:  Name
// - Date:    Month Day, Year
// - Version: 1.0
// - Copyright: Copyright Year, Company Inc.
// ================================================================================
// ================================================================================
// - Begin test

#include <gtest/gtest.h>

TEST(test_suite_name, test_name) {
	// Expect two strings not to be equal.
	EXPECT_STRNE("hello", "world");
	// Expect equality.
	EXPECT_EQ(7 * 6, 42);
}
// ================================================================================
// ================================================================================
// eof
