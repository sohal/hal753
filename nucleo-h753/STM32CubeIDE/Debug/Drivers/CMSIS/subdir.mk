################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables
C_SRCS += \
/Volumes/repo/sohal/kodezine/hal753/nucleo-h753/Core/Src/system_stm32h7xx.c

OBJS += \
./Drivers/CMSIS/system_stm32h7xx.o

C_DEPS += \
./Drivers/CMSIS/system_stm32h7xx.d


# Each subdirectory must supply rules for building sources it contributes
Drivers/CMSIS/system_stm32h7xx.o: /Volumes/repo/sohal/kodezine/hal753/nucleo-h753/Core/Src/system_stm32h7xx.c Drivers/CMSIS/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m7 -std=gnu11 -g3 -DDEBUG -DUSE_PWR_LDO_SUPPLY -DUSE_HAL_DRIVER -DSTM32H753xx -c -I../../LWIP/App -I../../LWIP/Target -I../../Core/Inc -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/system -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Drivers/STM32H7xx_HAL_Driver/Inc -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Drivers/BSP/Components/lan8742 -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/netif/ppp -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Drivers/CMSIS/Device/ST/STM32H7xx/Include -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/lwip -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/lwip/apps -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/lwip/priv -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/lwip/prot -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/netif -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/compat/posix -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/compat/posix/arpa -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/compat/posix/net -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/compat/posix/sys -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/src/include/compat/stdc -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Middlewares/Third_Party/LwIP/system/arch -I/Users/s/STM32Cube/Repository/STM32Cube_FW_H7_V1.12.1/Drivers/CMSIS/Include -I/Users/s/STM32Cube/Repository//Packs/QuantumLeaps/qpc/8.1.1/include -I/Users/s/STM32Cube/Repository//Packs/QuantumLeaps/qpc/8.1.1/ports/arm-cm/qk/gnu/ -I/Users/s/STM32Cube/Repository//Packs/QuantumLeaps/qpc/8.1.1/ports/arm-cm/config -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Drivers-2f-CMSIS

clean-Drivers-2f-CMSIS:
	-$(RM) ./Drivers/CMSIS/system_stm32h7xx.cyclo ./Drivers/CMSIS/system_stm32h7xx.d ./Drivers/CMSIS/system_stm32h7xx.o ./Drivers/CMSIS/system_stm32h7xx.su

.PHONY: clean-Drivers-2f-CMSIS
