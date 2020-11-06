#include <stdbool.h>
#include "SPIStream.h"
#include <avr/pgmspace.h>
#include "WaveInfo.h"
#include "WaveParser.h"

static const uint8_t PROGMEM fourCC_RIFF[] = { 'R', 'I', 'F', 'F' };
static const uint8_t PROGMEM fourCC_WAVE[] = { 'W', 'A', 'V', 'E' };
static const uint8_t PROGMEM fourCC_FMT[] =  { 'f', 'm', 't', ' ' };
static const uint8_t PROGMEM fourCC_FACT[] = { 'f', 'a', 'c', 't' };
static const uint8_t PROGMEM fourCC_DATA[] = { 'd', 'a', 't', 'a' };

bool WaveParser::Parse(SPIStream* pStream, WaveInfo& waveInfo)
{
	if (!readFourCC(pStream, fourCC_RIFF, waveInfo.totalSize))
	{
		return false;
	}
	waveInfo.totalSize += 8;

	if (!checkFourCC(pStream, fourCC_WAVE))
	{
		return false;
	}

	uint32_t fmtSize;
	if (!readFourCC(pStream, fourCC_FMT, fmtSize))
	{
		return false;
	}

	waveInfo.formatTag = pStream->ReadWord();
	waveInfo.channels = pStream->ReadWord();
	waveInfo.samplesPerSec = pStream->ReadDoubleWord();
	pStream->Skip(4);			// avg bits
	waveInfo.blockAlign = pStream->ReadWord();
	waveInfo.bitsPerSample = pStream->ReadWord();

	pStream->Skip(fmtSize - 16);

	uint32_t factSize = 0;
	if (readFourCC(pStream, fourCC_FACT, factSize))
	{
		/* waveInfo.totalSamples = */ pStream->ReadDoubleWord();
	}
	if (!readFourCC(pStream, fourCC_DATA, waveInfo.dataSize))
	{
		return false;
	}
	waveInfo.dataOffset = pStream->GetPosition();
	waveInfo.blockCount = waveInfo.dataSize / waveInfo.blockAlign;
	return true;
}

bool WaveParser::checkFourCC(SPIStream* pStream, const uint8_t fourCC[4])
{
	uint8_t buffer[4];
	pStream->Read(buffer, sizeof(buffer));
	for (uint8_t i = 0; i < 4; ++i)
	{
		if (buffer[i] != pgm_read_byte(&fourCC[i]))
		{
			return false;
		}
	}
	return true;
}

bool WaveParser::readFourCC(SPIStream* pStream, const uint8_t fourCC[4], uint32_t& size)
{
	if (!checkFourCC(pStream, fourCC))
	{
		return false;
	}
	size = pStream->ReadDoubleWord();
	return true;
}
