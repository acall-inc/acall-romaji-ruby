# coding: utf-8
#
module Romaji
  module StringExtension
    def normalize
      Romaji.normalize(self)
    end

    def normalize!
      self.replace(self.normalize)
    end

    def kana
      Romaji.romaji2kana(self.normalize)
    end

    def kana!
      self.replace(self.kana)
    end

    def romaji
      Romaji.kana2romaji(self.normalize, false)
    end

    def romaji!
      self.replace(self.romaji)
    end

    def kunrei
      Romaji.kana2romaji(self.normalize, true)
    end

    def kunrei!
      self.replace(self.kunrei)
    end
  end
end

