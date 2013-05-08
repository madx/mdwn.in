# encoding: utf-8

module Mdwnin
  class Keygen

    def self.generate(time=Time.now)
      flux   = [time.usec, time.to_i].map { |i| i.to_s(36) }.join
      random = (1_000_000 * Kernel.rand).to_i.to_s(36)

      [flux, random].join('.')
    end

  end
end
