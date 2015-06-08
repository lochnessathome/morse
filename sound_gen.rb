module SoundGen
  require 'wavefile'

  SAMPLE_RATE = 44100 # Hz per second
  FREQUENCY = 700.0 # Hz
  CHUNK_DURATION = 120.0 # ms per dot
  WAVE_FUNC = Math::PI * 2

  class << self

    def main(sequence)
      sequence = morse_to_digits(sequence)

      samples = generate_samples(sequence)

      save(samples)
    end

    private

    def generate_samples(sequence)
      position_in_period = 0.0
      position_in_period_delta = FREQUENCY / SAMPLE_RATE

      num_samples = (SAMPLE_RATE * calculate_duration(sequence)).to_i

      samples = [].fill(0.0, 0, num_samples)

      num_samples.times do |i|
        # interpolate position of current sample to position in sequence
        sequence_index = (sequence.length.to_f * i / num_samples).round

        samples[i] = Math::sin(position_in_period * WAVE_FUNC) * (sequence[sequence_index]).to_i

        position_in_period += position_in_period_delta

        if (position_in_period >= 1.0)
          position_in_period -= 1.0
        end
      end

      samples
    end

    def save(samples = [])
      bs_format = WaveFile::Format.new(:mono, :float, SAMPLE_RATE)

      buffer = WaveFile::Buffer.new(samples, bs_format)

      f_name = "morse-sound-#{Time.now.to_i}.wav"
      ws_format = WaveFile::Format.new(:mono, :pcm_16, SAMPLE_RATE)

      WaveFile::Writer.new(f_name, ws_format) { |writer| writer.write(buffer) }
    end

    def morse_to_digits(sequence)
      sequence.gsub!('-', '11110')
      sequence.gsub!('.', '10')
      sequence.gsub!(' ', '00000')

      sequence
    end

    def calculate_duration(sequence)
      (sequence.length * CHUNK_DURATION / 1000)
    end

  end

end
