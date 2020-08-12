#if !defined(DECODER_H_INCLUDED)
#define DECODER_H_INCLUDED

#include <stdint.h>
#include "WaveInfo.h"


extern "C"
{
	typedef void* DecoderPtr;

	DecoderPtr Decoder_Create(const WaveInfo& waveInfo);
	uint32_t Decoder_GetTotalSamples(DecoderPtr pDecoder);
	int16_t Decoder_Decode(DecoderPtr pDecoder);
	void Decoder_Delete(DecoderPtr pDecoder);
}

#endif
