#if !defined(SPISTREAM_H_INCLUDED)
#define SPISTREAM_H_INCLUDED

#include <inttypes.h>

class SPIStream
{
public:
	SPIStream(void);
	void SetPosition(uint32_t position);
	uint32_t GetPosition() const;
	uint8_t ReadByte();
	uint16_t ReadWord();
	uint32_t ReadDoubleWord();
	void Read(uint8_t* buffer, uint16_t count);
	void Skip(uint16_t count);
	void Sleep();
	void Wakeup();

private:
	uint32_t m_position;
};

#endif
