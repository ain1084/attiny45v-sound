#include "SPI.h"
#include "SPIStream.h"

SPIStream::SPIStream(void)
 : m_position(0)
{
}

void SPIStream::SetPosition(uint32_t position)
{
	m_position = position;
	SPI_ReadStart(m_position);
}

uint32_t SPIStream::GetPosition() const
{
	return m_position;
}

uint8_t SPIStream::ReadByte()
{
	m_position++;
	return SPI_ReadNext();
}

uint16_t SPIStream::ReadWord()
{
	m_position += 2;
	return ::SPI_ReadNextWord();
}

uint32_t SPIStream::ReadDoubleWord()
{
	m_position += 4;
	return ::SPI_ReadNextDoubleWord();
}

void SPIStream::Read(uint8_t* buffer, uint16_t count)
{
	for (uint16_t i = 0; i < count; ++i)
	{
		*buffer++ = SPI_ReadNext();
	}
	m_position += count;
}

void SPIStream::Skip(uint16_t count)
{
	for (uint16_t i = 0; i < count; ++i)
	{
		SPI_ReadNext();
	}
	m_position += count;
}

void SPIStream::Sleep()
{
	::SPI_Uninitialize();
}

void SPIStream::Wakeup()
{
	::SPI_Initialize();
}
