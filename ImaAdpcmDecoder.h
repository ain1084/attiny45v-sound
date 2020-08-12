#if !defined(IMAADPCMDECODER_H_INCLUDED)
#define IMAADPCMDECODER_H_INCLUDED

#include <stdint.h>
#include "Decoder.h"
#include "WaveInfo.h"

extern "C"
{
	DecoderPtr ImaAdpcmDecoder_Create(const WaveInfo& waveInfo);
};

#endif
