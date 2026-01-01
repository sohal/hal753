/*
 * demo.c
 *
 *  Created on: Dec 30, 2025
 *      Author: s
 */
#include "demo.h"
#include <stdbool.h>
#include "stm32h7xx_hal.h"
#define BSP_TICKS_PER_SEC    100U
enum BlinkySignals {
    DUMMY_SIG = Q_USER_SIG,
    //...
    MAX_PUB_SIG, // the last published signal

    TIMEOUT_SIG,
    //...
    MAX_SIG      // the last signal
};

typedef struct {
    QActive super; // QActive superclass (inheritance)

// data members added to the QActive superclass...
    QTimeEvt timeEvt; // private time event generator
    //...
} Blinky;
extern Blinky Blinky_inst; // Blinky instance declaration
void Blinky_ctor(void);
//----------------------------------------------------------------------------
Blinky Blinky_inst; // the Blinky AO instance definition
QActive * const AO_Blinky = &Blinky_inst.super; // global opaque pointer

//............................................................................
void BSP_ledOn(void) {
    HAL_GPIO_WritePin(LDGreen_GPIO_Port, LDGreen_Pin, GPIO_PIN_SET);  // turn LED on
}
//............................................................................
void BSP_ledOff(void) {
    HAL_GPIO_WritePin(LDGreen_GPIO_Port, LDGreen_Pin, GPIO_PIN_RESET);    // turn LED off
}
void application_init(void)
{
    QF_init();       // initialize the framework and the underlying RT kernel
    //BSP_init();      // initialize the BSP
    //BSP_start();     // start the AOs/Threads
    // initialize event pools
    static QF_MPOOL_EL(QEvt) smlPoolSto[10];
    QF_poolInit(smlPoolSto, sizeof(smlPoolSto), sizeof(smlPoolSto[0]));

    // initialize publish-subscribe
    static QSubscrList subscrSto[MAX_PUB_SIG];
    QActive_psInit(subscrSto, Q_DIM(subscrSto));

    // instantiate and start AOs/threads...

    static QEvtPtr blinkyQueueSto[10];
    Blinky_ctor();
    QActive_start(AO_Blinky,
        1U,                          // QP prio. of the AO
        blinkyQueueSto,               // event queue storage
        Q_DIM(blinkyQueueSto),       // queue length [events]
        (void *)0, 0U,               // no stack storage
        (void *)0);                  // no initialization param
    QF_run(); // run the QF application
	do
	{
		HAL_GPIO_TogglePin(LDGreen_GPIO_Port, LDGreen_Pin);
		HAL_GPIO_TogglePin(LDYellow_GPIO_Port, LDYellow_Pin);
		HAL_GPIO_TogglePin(LDRed_GPIO_Port, LDRed_Pin);
		HAL_Delay(200);
	} while (true);
}




// Blinky state machine declaration...
//
// top-most initial transition:
static QState Blinky_initial(Blinky * const me, void const * const par);
// states:
static QState Blinky_off(Blinky * const me, QEvt const * const e);
static QState Blinky_on(Blinky * const me, QEvt const * const e);

//............................................................................
// Blinky "constructor"
void Blinky_ctor(void) {
    Blinky * const me = &Blinky_inst; // 'me' points to the Blinky instance

    // call the superclass' constructor
    QActive_ctor(&me->super, Q_STATE_CAST(&Blinky_initial));

    // call the members' constructors
    QTimeEvt_ctorX(&me->timeEvt, &me->super, TIMEOUT_SIG, 0U);
    //...
}

//----------------------------------------------------------------------------
// Blinky state machine definition...
//
//        +--------------------+             +--------------------+
// O----->|        off         |---TIMEOUT-->|        on          |
//        +--------------------+             +--------------------+
//        |entry: BSP_ledOff() |             |entry: BSP_ledOn()  |
//        |                    |<--TIMEOUT---|                    |
//        +--------------------+             +--------------------+

//............................................................................
// top-most initial transition:
QState Blinky_initial(Blinky * const me, void const * const par) {
    Q_UNUSED_PAR(par); // initialization parameter unused in this case

    // arm the time event to expire in half a second and every half second
    QTimeEvt_armX(&me->timeEvt, BSP_TICKS_PER_SEC/2U, BSP_TICKS_PER_SEC/2U);

    return Q_TRAN(&Blinky_off); // transition to "off"
}
//............................................................................
// the "off" state
QState Blinky_off(Blinky * const me, QEvt const * const e) {
    QState status;
    switch (e->sig) {
        case Q_ENTRY_SIG: {       // state entry action
            BSP_ledOff();         // action to execute
            status = Q_HANDLED(); // entry action handled
            break;
        }
        case TIMEOUT_SIG: { // TIMEOUT event
            status = Q_TRAN(&Blinky_on); // transition to "on"
            break;
        }
        default: {
            status = Q_SUPER(&QHsm_top); // superstate of this state
            break;
        }
    }
    return status;
}
//............................................................................
// the "on" state
QState Blinky_on(Blinky * const me, QEvt const * const e) {
    QState status;
    switch (e->sig) {
        case Q_ENTRY_SIG: {       // state entry action
            BSP_ledOn();          // action to execute
            status = Q_HANDLED(); // entry action handled
            break;
        }
        case TIMEOUT_SIG: { // TIMEOUT event
            status = Q_TRAN(&Blinky_off); // transition to "off"
            break;
        }
        default: {
            status = Q_SUPER(&QHsm_top); // superstate of this state
            break;
        }
    }
    return status;
}

//============================================================================
// QF callbacks...
void QF_onStartup(void) {
    // set up the SysTick timer to fire at BSP_TICKS_PER_SEC rate
    SysTick_Config(SystemCoreClock / BSP_TICKS_PER_SEC);

    // assign all priority bits for preemption-prio. and none to sub-prio.
    NVIC_SetPriorityGrouping(0U);

    // set priorities of ALL ISRs used in the system, see NOTE1
    NVIC_SetPriority(SysTick_IRQn,   QF_AWARE_ISR_CMSIS_PRI + 1U);
    // ...

    // enable IRQs...
#ifdef Q_SPY
    NVIC_EnableIRQ(USART2_IRQn); // UART2 interrupt used for QS-RX
#endif
}
//............................................................................
void QF_onCleanup(void) {
}
//............................................................................
void QK_onIdle(void) {
    // toggle an LED on and then off (not enough LEDs, see NOTE02)
    //QF_INT_DISABLE();
    //GPIOA->BSRR = (1U << LD4_PIN);         // turn LED[n] on
    //GPIOA->BSRR = (1U << (LD4_PIN + 16U)); // turn LED[n] off
    //QF_INT_ENABLE();

#ifdef Q_SPY
    QS_rxParse();  // parse all the received bytes

    // while Transmit Data Register Empty or TX-FIFO Not Full
    if ((USART2->ISR & USART_ISR_TXE_TXFNF_Msk) != 0U) { // TXE empty?
        QF_INT_DISABLE();
        uint16_t b = QS_getByte();
        QF_INT_ENABLE();

        if (b != QS_EOD) {   // not End-Of-Data?
            USART2->TDR = b; // put into the DR register
        }
    }
#elif defined NDEBUG
    // Put the CPU and peripherals to the low-power mode.
    // you might need to customize the clock management for your application,
    // see the datasheet for your particular Cortex-M MCU.
    __WFI(); // Wait-For-Interrupt
#endif
}
