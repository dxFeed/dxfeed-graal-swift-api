// SPDX-License-Identifier: MPL-2.0

#ifndef DXFEED_GRAAL_NATIVE_API_SYSTEM_H_
#define DXFEED_GRAAL_NATIVE_API_SYSTEM_H_

#ifdef __cplusplus
extern "C" {
#    include <cstdint>
#else
#    include <stdint.h>
#endif

#include "graal_isolate.h"

/** @defgroup System
 *  @{
 */

/**
 * @brief Sets the system property indicated by the specified key.
 * @param[in] thread The pointer to the runtime data structure for a thread.
 * @param[in] key The name of the system property.
 * @param[in] value The value of the system property.
 * @return 0 - if the operation was successful; otherwise, an error code.
 */
int32_t dxfg_system_set_property(graal_isolatethread_t *thread, const char *key, const char *value);

/**
 * @brief Gets the system property indicated by the specified key.
 * @warning Return value must be free by dxfg_system_release_property().
 * @param[in] thread The pointer to the runtime data structure for a thread.
 * @param[in] key The name of the system property.
 * @return The string value of the system property, or null if there is no property with that key or error occur.
 */
const char *dxfg_system_get_property(graal_isolatethread_t *thread, const char *key);

/**
 * @brief Frees pointer that was previously allocated in Java method (by UnmanagedMemory).
 * @param[in] thread The pointer to the runtime data structure for a thread.
 * @param[in] value The pointer to release. Pointer not valid after function call. Pointer can be NULL.
 * @return 0 - if the operation was successful; otherwise, an error code.
 */
int32_t dxfg_system_release_property(graal_isolatethread_t *thread, const char *value);

/** @} */ // end of System

#ifdef __cplusplus
}
#endif

#endif // DXFEED_GRAAL_NATIVE_API_SYSTEM_H_
