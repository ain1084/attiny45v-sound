#if !defined(PLAYCONTROLLER_H_INCLUDED)
#define PLAYCONTROLLER_H_INCLUDED

#include <inttypes.h>
#include <stdlib.h>
class SPIStream;
#include "Decoder.h"

class PlayController
{
public:
	enum State
	{
		State_Stop,
		State_Play,
		State_End,
	};

	PlayController();
	~PlayController();
	void Sleep(void);
	bool Play(SPIStream* pStream, uint32_t offset);
	void Stop();
	State GetState() const;
	void Timer();

private:

	void stopHardware();
	void startHardware();

	uint32_t _sampleCount;
	volatile State _state;
	DecoderPtr _pDecoder;
};

#endif
