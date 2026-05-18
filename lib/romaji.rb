# coding: utf-8

require 'nkf'
require 'romaji/string_extension'
require 'romaji/constants'
require 'romaji/version'

module Romaji
  def self.romaji2kana(text, options = {})
    text = hira2kata(self.normalize(text))
    pos = 0
    k = nil
    kana = ''
    chars =  text.split(//u)
    while true
      # ン
      if chars[pos] == 'm' && ['p', 'b', 'm'].include?(chars[pos + 1])
        kana += 'ン'
        pos += 1
        next
      end

      # ッ
      if chars[pos] == chars[pos + 1] && !['a', 'i', 'u', 'e', 'o', 'n'].include?(chars[pos]) && chars[pos] =~ /[a-z]/
        kana += 'ッ'
        pos += 1
        next
      end

      ROMAJI_MAX_LENGTH.downto(1) do |t|
        substr = chars.slice(pos, t).join
        k = ROMAJI2KANA[substr]
        if k
          kana += k
          pos += t
          break
        end
      end
      unless k
        kana += chars.slice(pos, 1).join
        pos += 1
      end
      break if pos >= chars.size
    end

    kana_type = options[:kana_type] || :katakana
    kana = kata2hira(kana) if :hiragana == kana_type.to_sym
      
    return kana
  end

  def self.kana2romaji(text, kunrei = false)
    text = hira2kata(self.normalize(text))
    pos = 0
    k = nil
    romaji = ''
    chars =  text.split(//u)
    while true
      # ン
      if chars[pos] == 'ン'
        next_char_romaji = KANA2ROMAJI[chars[pos + 1]]
        if !kunrei && next_char_romaji && ['p', 'b', 'm'].include?(next_char_romaji[0].slice(0,1))
          romaji += 'm'
        else
          romaji += 'n'
        end
        pos += 1
        next
      end

      # ッ
      if chars[pos] == 'ッ'
        next_char_romaji = KANA2ROMAJI[chars[pos + 1]]
        if ['a', 'i', 'u', 'e', 'o', 'n', nil].include?(chars[pos + 1]) || next_char_romaji.nil?
          romaji += 'tsu'
        else
          romaji += (a = (kunrei ? next_char_romaji.last : next_char_romaji.first).slice(0,1)
            a == 'c' && !kunrei ? 't' : a)
        end
        pos += 1
        next
      end

      # (ウ)ウ, (オ)ウ, (オ)オ
      unless kunrei
        if (chars[pos] == 'ウ' && ['u', 'o'].include?(romaji.last)) ||
            (chars[pos] == 'オ' && chars[pos - 1] != 'ウ' && !chars[pos + 1].nil? && romaji.last == 'o')
          pos += 1
          next
        end
      end

      ROMAJI_MAX_LENGTH.downto(1) do |t|
        substr = chars.slice(pos, t).join
        k = KANA2ROMAJI[substr]
        if k
          romaji += kunrei ? k.last : k.first
          pos += t
          break
        end
      end
      unless k
        romaji += chars.slice(pos, 1).join
        pos += 1
      end
      break if pos >= chars.size
    end
    romaji
  end

  def self.hira2kata(text)
    NKF.nkf("--katakana -Ww", text)
  end

  def self.kata2hira(text)
    NKF.nkf("--hiragana -Ww", text)
  end

  def self.normalize(text)
    NKF.nkf('-mZ0Wwh0', text).downcase
  end
end
