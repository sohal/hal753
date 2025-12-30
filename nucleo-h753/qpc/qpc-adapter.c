/*
 * qpc-adapter.c
 *
 *  Created on: Dec 30, 2025
 *      Author: s
 */


#include "qpc.h"
#include "main.h"
//============================================================================
// Error handler and ISRs...

Q_NORETURN Q_onError(char const * const module, int_t const id) {
    // NOTE: this implementation of the assertion handler is intended only
    // for debugging and MUST be changed for deployment of the application
    // (assuming that you ship your production code with assertions enabled).
    Q_UNUSED_PAR(module);
    Q_UNUSED_PAR(id);
    QS_ASSERTION(module, id, 10000U);

#ifndef NDEBUG
    // light all LEDs
    // for debugging, hang on in an endless loop...
    for (;;) {
    }
#endif

    NVIC_SystemReset();
}

void SysTick_Handler(void); // prototype
void SysTick_Handler(void) {
    QK_ISR_ENTRY();   // inform QK about entering an ISR

    QTIMEEVT_TICK_X(0U, &l_SysTick_Handler); // time events for rate 0

    QK_ISR_EXIT();  // inform QK about exiting an ISR
}
