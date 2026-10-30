/*
 * Copyright 2026, UNSW
 *
 * SPDX-License-Identifier: BSD-2-Clause
 */

#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <microkit.h>

bool handle_sysreg_64_fault(size_t vcpu_id, uint64_t hsr, seL4_UserContext *regs);