#if !defined(SPI_H_INCLUDED)
#define SPI_H_INCLUDED

#include <stdint.h>
#include <stdbool.h>

extern "C" void SPI_Initialize(void);
extern "C" void SPI_Uninitialize(void);
extern "C" void SPI_ReadStart(uint32_t address);
extern "C" uint8_t SPI_ReadNext(void);
extern "C" uint16_t SPI_ReadNextWord(void);
extern "C" uint32_t SPI_ReadNextDoubleWord(void);
extern "C" void SPI_ReadEnd(void);
extern "C" uint16_t SPI_ReadId(void);

#endif

