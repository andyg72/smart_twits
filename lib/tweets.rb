require_relative 'helper'

class Tweets

  include Helper

  REJECT_WORDS = ['rt', 'i','a', 'to', 'the', 'on', 'for', 'am','at', 'of', 'do', 'you', 'be', 'in', 'and', 'he', 'with', 'that', 'what', 'are', 'as', 'an', 'all', 'we', "is", "", "can", "this", "now"]
  
  def find_top_mentions(number, file_path)
    array = read_mentions_file(file_path)
    frequnecy_hash = count_freq(array)
    filter_top_results(number, frequnecy_hash)
  end

  def find_top_links(number, file_path)
    array = read_link_file(file_path)
    frequency_hash = count_freq(array)
    filter_top_results(number, frequency_hash)
  end

  def find_top_words(number, array)
    words = find_words(array)
    useful_words = reject_words(words)
    frequency_hash = count_freq(useful_words)
    filter_top_results(number, frequency_hash)
  end

  def read_link_file(file_path)
    text = File.read(file_path)
    text.scan(/https?:\/\/[A-Za-z0-9._\/&?#]+/).flatten
  end

  def read_mentions_file(file_path)
    text = File.read(file_path)
    text.scan(/@\w+/).flatten
  end

  def find_words(array)
    array.join(" ").split(" ").map{ |w| w.downcase.gsub(/\B[@#]\S+\b|(?:f|ht)tps?:\/[^\s]+|[^a-zA-Z0-9%\s]/, "")}
  end

  def reject_words(array)
    array.reject {|w| REJECT_WORDS.include?(w) }
  end

end

