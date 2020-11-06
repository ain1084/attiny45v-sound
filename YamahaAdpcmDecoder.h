#if !defined(YAMAHAADPCMDECODER_H_INCLUDED)
#define YAMAHAADPCMDECODER_H_INCLUDED

#include <stdint.h>
#include "WaveInfo.h"
#include "Decoder.h"

extern "C"
{
	DecoderPtr YamahaAdpcmDecoder_Create(const WaveInfo& waveInfo);
};

#endif
