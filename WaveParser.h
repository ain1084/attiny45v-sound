#if !defined(WAVEPARSER_H_INCLUDED)
#define WAVEPARSER_H_INCLUDED

#include <stdbool.h>
class SPIStream;
struct WaveInfo;

class WaveParser
{
public:
	static bool Parse(SPIStream* pStream, WaveInfo& waveInfo);


private:
	static bool checkFourCC(SPIStream* pStream, const uint8_t fourCC[4]);
	static bool readFourCC(SPIStream* pStream, const uint8_t fourCC[4], uint32_t& size);
};

#endif
