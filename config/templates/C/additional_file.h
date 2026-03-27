// ================================================================================
// ================================================================================
// - File:    filename.h
// - Purpose: Describe the file purpose here
//
// Source Metadata
// - Author:  Name
// - Date:    Month Day, Year
// - Version: 1.0
// - Copyright: Copyright Year, Company Inc.
// ================================================================================
// ================================================================================
// Include modules here
#if !defined(__GNUC__) && !defined(__clang__)
#error "This code is only compatible with GCC and Clang"
#endif

#if !defined(__STDC_VERSION__) || __STDC_VERSION__ < 201112L
#error "This code requires C11 or later."
#endif

#ifndef filename_H
#define filename_H

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

int func(); // Replace with correct prototype

#ifdef __cplusplus
}
#endif /* cplusplus */
#endif /* filename_H */
// ================================================================================
// ================================================================================
// eof
