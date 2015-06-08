module Console
  require 'io/wait'

  DELAY = 50.0

  def timestamp
    time = Time.now.to_f.round(3).to_s

    if time.length < 14
      time[11] = '0' unless time[11]
      time[12] = '0' unless time[12]
      time[13] = '0' unless time[13]
    end

    time.sub('.', '').to_i
  end

  def delay
    # 50 ms for keyboard polling
    sleep(DELAY / 1000.0)
  end

  def store(c, char_seq)
    value = !c.nil?

    if char_seq[-1] && value == char_seq[-1][0]
      char_seq[-1][1] = timestamp
    else
      char_seq << [value, timestamp]
    end

    char_seq
  end

  def normalize(char_seq)
    ind = 0

    loop do
      ind = ind + 1
      break if ind == char_seq.size

      period = char_seq[ind][1] - char_seq[ind - 1][1]

      if period <= (DELAY * 2 + 1)
        if char_seq[ind][0]
          char_seq.delete_at(ind)
          ind = 0
        end
      end
    end

    ind = 0

    loop do
      ind = ind + 1
      break if ind == char_seq.size

      if char_seq[ind][0] == char_seq[ind - 1][0]
        char_seq.delete_at(ind - 1)
        ind = 0
      end
    end

    char_seq
  end

  def encode(char_seq)
    buf = []

    char_seq = normalize(char_seq)

    # usually the first element is false (nil, empty space)
    buf << '.' if char_seq[0][0]

    (char_seq.count - 1).times do |ind|
      ind = ind + 1
      period = char_seq[ind][1] - char_seq[ind - 1][1]
      value = char_seq[ind][0]

      if !value && period >= 4500
        buf << ' '
      end

      if value
        if period <= 1500
          buf << '.'
        else
          buf << '-'
        end
      end
    end

    buf.join
  end

end
