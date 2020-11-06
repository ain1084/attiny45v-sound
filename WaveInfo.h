#if !defined(WAVEINFO_H_INCLUDED)
#define WAVEINFO_H_INCLUDED

#include <inttypes.h>

struct WaveInfo
{
	uint32_t totalSize;
	uint16_t formatTag;
	uint16_t channels;
	uint16_t samplesPerSec;
	uint16_t bitsPerSample;
	uint16_t blockAlign;
	uint32_t blockCount;
	uint32_t dataSize;
	uint32_t dataOffset;
};

#endif
